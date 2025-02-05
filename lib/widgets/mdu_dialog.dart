// Copyright (C) 2025 Vincent Hamp
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math';

import 'package:Frontend/models/zpp.dart';
import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/mdu_service.dart';
import 'package:Frontend/services/mdu_service.dart';
import 'package:Frontend/utilities/crc32.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class MduDialog extends ConsumerStatefulWidget {
  final Zpp? _zpp;
  final Zsu? _zsu;

  const MduDialog.zpp(this._zpp, {super.key}) : _zsu = null;
  const MduDialog.zsu(this._zsu, {super.key}) : _zpp = null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MduDialogState();
}

/// \todo document
class _MduDialogState extends ConsumerState<MduDialog> {
  static const int _retries = 10;
  late final MduService _mdu;
  late final StreamQueue<Uint8List> _events;
  final Map<int, ListTile> _decoders = {};
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  /// \todo document
  @override
  void initState() {
    super.initState();
    _mdu = ref.read(mduServiceProvider(widget._zpp != null ? 'zpp/' : 'zsu/'));
    _events = StreamQueue(_mdu.stream);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  /// \todo document
  @override
  void dispose() {
    _mdu.close();
    super.dispose();
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('MDU'),
      children: [
        SimpleDialogOption(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: _progress),
              Text(_status),
            ],
          ),
        ),
        SimpleDialogOption(
          child: AnimatedSize(
            alignment: Alignment.topCenter,
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final tile in _decoders.values) tile],
            ),
          ),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(_option),
          ),
        ),
      ],
    );
  }

  /// \todo document
  Future<void> _execute() async {
    await _connect();

    var msg = await _configTransferRate();
    if (msg.contains(MduService.ack)) return;

    // ZPP
    if (widget._zpp != null) {
      msg = await _zppValid();
      if (msg.contains(MduService.ack)) return;
      msg = await _zppUpdate();
      if (msg.contains(MduService.ack)) return;
      msg = await _zppExit();
      if (msg.contains(MduService.ack)) return;
    }
    // ZSU
    else {
      msg = await _zsuSearch();
      if (msg.contains(MduService.ack)) return;
      for (final decoderId in _decoders.keys) {
        msg = await _zsuUpdate(decoderId);
        if (msg.contains(MduService.ack)) return;
      }
      msg = await _zsuExit();
      if (msg.contains(MduService.ack)) return;
    }

    await _disconnect();
  }

  /// \todo document
  Future<void> _connect() async {
    _setStatusState('Connecting');
    await _mdu.ready;
  }

  /// \todo document
  Future<Uint8List> _configTransferRate() async {
    _setStatusState('Config transfer rate');

    // Workaround for special bootloader update software
    if ((widget._zsu?.firmwares.length ?? 0) == 1) {
      return Uint8List.fromList([MduService.nak, MduService.nak]);
    }

    // zsu -> TF starts at 3
    // zpp -> TF starts at 1
    final tfStart = widget._zpp != null ? 1 : 3;
    for (int tf = tfStart; tf <= 4; ++tf) {
      final msg = await _retryOnFailure(() => _mdu.configTransferRate(tf));
      if (!msg.contains(MduService.ack)) return msg;
    }

    final msg = await _retryOnFailure(() => _mdu.configTransferRate(0));
    if (msg.contains(MduService.ack)) {
      return _setErrorState('No common transfer rate found');
    }

    return msg;
  }

  /// \todo document
  Future<Uint8List> _zppValid() async {
    _setStatusState('Check if ZPP is valid');
    final msg = await _retryOnFailure(
      () => _mdu.zppValidQuery(widget._zpp!.id, widget._zpp!.flash.length),
    );
    if (msg.contains(MduService.ack)) return _setErrorState('ZPP not valid');
    return msg;
  }

  /// \todo document
  Future<Uint8List> _zppUpdate() async {
    _setStatusState('Erasing');
    var msg = await _retryOnFailure(
      () => _mdu.zppErase(0, widget._zpp!.flash.length),
    );
    if (msg.contains(MduService.ack)) return _setErrorState('Erasing failed');

    /// \warning
    /// During erasing busy must be checked periodically within the HTTP receive timeout.
    for (var i = 0; i < (200 / 3).ceil(); ++i) {
      await Future.delayed(const Duration(seconds: 3));
      msg = await _retryOnFailure(() => _mdu.busy());
      if (!msg.contains(MduService.ack)) break;
    }
    if (msg.contains(MduService.ack)) return _setErrorState('Erasing failed');

    //
    _setStatusState('Writing');
    msg = await _zppWrite(widget._zpp!.flash);
    if (msg.contains(MduService.ack)) return _setErrorState('Writing failed');

    //
    msg = await _retryOnFailure(
      () => _mdu.zppUpdateEnd(0, widget._zpp!.flash.length),
    );
    if (msg.contains(MduService.ack)) {
      return _setErrorState('ZPP update end check failed');
    }

    return msg;
  }

  /// \todo document
  Future<Uint8List> _zppWrite(Uint8List bin) async {
    const int blockSize = 256;
    final blocks = bin.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(256, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _mdu.zppUpdate((i + j) * blockSize, Uint8List.fromList(blocks[i + j]));
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (!msg.contains(MduService.ack)) {
          failCount = 0;
          ++i;
        }
        // Or back (limited number of times)
        else if (failCount < _retries) {
          ++failCount;
          i = max(i - 1, 0);
          break;
        }
        // Or bail
        else {
          return msg;
        }
      }

      // Update progress
      _setProgressState(
        'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        i / blocks.length,
      );
    }

    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  /// \todo document
  Future<Uint8List> _zppExit() async {
    // Don't leave any decoder in MDU
    await _retryOnFailure(() => _mdu.ping(0, 0));
    return await _retryOnFailure(() => _mdu.zppExitReset());
  }

  /// \todo document
  Future<Uint8List> _zsuSearch() async {
    _setStatusState('Search decoders');

    for (final entry in widget._zsu!.firmwares.entries) {
      final decoderId = entry.key;
      await _retryOnFailure(() => _mdu.ping(0, 0));
      final msg =
          await _retryOnFailure(() => _mdu.ping(0, decoderId), retries: 1);
      if (msg[0] == MduService.nak && msg[1] == MduService.ack) {
        final exp = RegExp(r'\w{5,}-[0-9]');
        final match = exp.firstMatch(entry.value.name);
        if (match != null && match[0] != null) {
          final String name = match[0]!;
          setState(() {
            _decoders[decoderId] = ListTile(
              leading: const Icon(Icons.circle_outlined),
              title: Text(name),
            );
          });
        }
      }
    }

    if (_decoders.isEmpty) return _setErrorState('No decoders found');

    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  /// \todo document
  Future<Uint8List> _zsuUpdate(int decoderId) async {
    // Ping all decoders
    _setStatusState('Ping');
    setState(() {
      _decoders[decoderId] = ListTile(
        leading: const Icon(Icons.pending_outlined),
        title: _decoders[decoderId]!.title,
      );
    });
    await _retryOnFailure(() => _mdu.ping(0, 0));

    // Ping decoder to update
    var msg = await _retryOnFailure(() => _mdu.ping(0, decoderId));
    if (msg[0] == MduService.ack || msg[1] == MduService.nak) {
      return _setErrorState('Decoder does not respond', decoderId);
    }

    // Salsa20 initialization vector
    final ZsuFirmware zsuFirmware = widget._zsu!.firmwares[decoderId]!;
    msg = await _retryOnFailure(() => _mdu.zsuSalsa20IV(zsuFirmware.iv!));
    if (msg.contains(MduService.ack)) return msg;

    // Erase flash
    _setStatusState('Erasing');
    msg = await _retryOnFailure(
      () => _mdu.zsuErase(0, zsuFirmware.bin.length - 1),
    );
    if (msg.contains(MduService.ack)) {
      return _setErrorState('Erasing failed', decoderId);
    }

    // Busy doesn't work for internal memory so don't check the response
    for (var i = 0; i < 5; ++i) {
      await Future.delayed(const Duration(seconds: 1));
      await _retryOnFailure(() => _mdu.busy());
    }

    // Write flash
    _setStatusState('Writing');
    setState(() {
      _decoders[decoderId] = ListTile(
        leading: const Icon(Icons.downloading_outlined),
        title: _decoders[decoderId]!.title,
      );
    });
    msg = await _zsuWrite(zsuFirmware.bin);
    if (msg.contains(MduService.ack)) {
      return _setErrorState('Writing failed', decoderId);
    }

    // CRC32 start
    msg = await _retryOnFailure(
      () => _mdu.zsuCrc32Start(
        0,
        zsuFirmware.bin.length - 1,
        crc32(zsuFirmware.bin),
      ),
    );
    if (msg.contains(MduService.ack)) {
      return _setErrorState('ZSU update CRC32 check failed', decoderId);
    }

    // CRC32 result
    msg = await _retryOnFailure(() => _mdu.zsuCrc32Result());
    if (msg.contains(MduService.ack)) {
      return _setErrorState('ZSU update CRC32 check failed', decoderId);
    }

    // Done with this ID
    setState(() {
      _decoders[decoderId] = ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: _decoders[decoderId]!.title,
      );
    });
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  /// \todo document
  Future<Uint8List> _zsuWrite(Uint8List bin) async {
    const int blockSize = 64;
    final blocks = bin.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(64, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _mdu.zsuUpdate((i + j) * blockSize, Uint8List.fromList(blocks[i + j]));
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (!msg.contains(MduService.ack)) {
          failCount = 0;
          ++i;
        }
        // Or back (limited number of times)
        else if (failCount < _retries) {
          ++failCount;
          i = max(i - 1, 0);
          break;
        }
        // Or bail
        else {
          return msg;
        }
      }

      // Update progress
      _setProgressState(
        'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        i / blocks.length,
      );
    }

    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  /// \todo document
  Future<Uint8List> _zsuExit() async {
    // Don't leave any decoder in MDU
    await _retryOnFailure(() => _mdu.ping(0, 0));
    return _retryOnFailure(() => _mdu.zsuCrc32ResultExit());
  }

  /// \todo document
  Future<void> _disconnect() async {
    _setStatusState('Done', 'OK');
    await _mdu.close();
  }

  /// \todo document
  Future<Uint8List> _retryOnFailure(
    Function() f, {
    int retries = _retries,
  }) async {
    var msg = Uint8List.fromList([MduService.ack, MduService.nak]);
    for (int i = 0; i < retries; i++) {
      f();
      msg = await _events.next;
      if (msg[0] == MduService.nak) return msg;
    }
    return msg;
  }

  /// \todo document
  Future<void> _setStatusState(String status, [String? option]) async {
    setState(() {
      _status = status;
      if (option != null) {
        _option = option;
        _progress = 0;
      } else {
        _progress = null;
      }
    });
  }

  /// \todo document
  Future<void> _setProgressState(String status, double progress) async {
    setState(() {
      _status = status;
      _progress = progress;
    });
  }

  /// \todo document
  Future<Uint8List> _setErrorState(String status, [int? decoderId]) async {
    setState(() {
      if (decoderId != null) {
        _decoders[decoderId] = ListTile(
          leading: const Icon(Icons.error_outlined),
          title: _decoders[decoderId]!.title,
        );
      }
      _status = status;
      _progress = 0;
    });
    return Uint8List.fromList([MduService.ack, MduService.ack]);
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
