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

import 'package:Frontend/constant/ws_batch_size.dart';
import 'package:Frontend/model/zpp.dart';
import 'package:Frontend/model/zsu.dart';
import 'package:Frontend/provider/mdu_service.dart';
import 'package:Frontend/service/zimo/mdu_service.dart';
import 'package:Frontend/utility/crc32.dart';
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
    _events.cancel();
    _mdu.close();
    super.dispose();
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('MDU'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: _progress),
          Text(_status),
          AnimatedSize(
            alignment: Alignment.topCenter,
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final tile in _decoders.values) tile],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_option),
        ),
      ],
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
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
      if (msg.contains(MduService.ack)) {
        await _zppExit(); // We can still bail here
        return;
      }
      msg = await _zppLcDcQuery();
      if (msg.contains(MduService.ack)) {
        await _zppExit(); // ... or here
        return;
      }
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
    _updateEphemeralState(status: 'Connecting');
    await _mdu.ready;
  }

  /// \todo document
  Future<Uint8List> _configTransferRate() async {
    _updateEphemeralState(status: 'Config transfer rate');

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
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'No common transfer rate found',
        progress: 0,
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    return msg;
  }

  /// \todo document
  Future<Uint8List> _zppValid() async {
    _updateEphemeralState(status: 'Check if ZPP is valid');
    final msg = await _retryOnFailure(
      () => _mdu.zppValidQuery(widget._zpp!.id, widget._zpp!.flash.length),
    );
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'ZPP not valid',
        progress: 0,
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }
    return msg;
  }

  /// \todo document
  Future<Uint8List> _zppLcDcQuery() async {
    if (!widget._zpp!.coded) {
      return Uint8List.fromList([MduService.nak, MduService.nak]);
    }
    _updateEphemeralState(status: 'Check if load code is valid');
    final msg = await _retryOnFailure(
      () => _mdu.zppLcDcQuery(widget._zpp!.developerCode),
    );
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'Load code not valid',
        progress: 0,
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }
    return msg;
  }

  /// \todo document
  Future<Uint8List> _zppUpdate() async {
    _updateEphemeralState(status: 'Erasing');
    var msg = await _retryOnFailure(
      () => _mdu.zppErase(0, widget._zpp!.flash.length),
    );
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'Erasing failed',
        progress: 0,
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    /// \warning
    /// During erasing busy must be checked periodically within the HTTP receive timeout.
    for (var i = 0; i < (200 / 3).ceil(); ++i) {
      await Future.delayed(const Duration(seconds: 3));
      msg = await _retryOnFailure(() => _mdu.busy());
      if (!msg.contains(MduService.ack)) break;
    }
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'Erasing failed',
        progress: 0,
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    //
    _updateEphemeralState(status: 'Writing');
    msg = await _zppWrite(widget._zpp!.flash);
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'Writing failed',
        progress: 0,
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    //
    msg = await _retryOnFailure(
      () => _mdu.zppUpdateEnd(0, widget._zpp!.flash.length),
    );
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'ZPP update end check failed',
        progress: 0,
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
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
      final n = min(wsBatchSize, blocks.length - i);
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

      // WebSocket closed on the server side
      if (_mdu.closeReason != null) {
        return Uint8List.fromList([MduService.ack, MduService.ack]);
      }

      // Update progress
      _updateEphemeralState(
        status:
            'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        progress: i / blocks.length,
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
    _updateEphemeralState(status: 'Search decoders');

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
          _updateEphemeralState(
            decoder: MapEntry(
              decoderId,
              ListTile(
                leading: const Icon(Icons.circle),
                title: Text(name),
              ),
            ),
          );
        }
      }
    }

    if (_decoders.isEmpty) {
      _updateEphemeralState(status: 'No decoders found', progress: 0);
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  /// \todo document
  Future<Uint8List> _zsuUpdate(int decoderId) async {
    // Ping all decoders
    _updateEphemeralState(
      status: 'Ping',
      decoder: MapEntry(
        decoderId,
        ListTile(
          leading: const Icon(Icons.pending),
          title: _decoders[decoderId]!.title,
        ),
      ),
    );
    await _retryOnFailure(() => _mdu.ping(0, 0));

    // Ping decoder to update
    var msg = await _retryOnFailure(() => _mdu.ping(0, decoderId));
    if (msg[0] == MduService.ack ||
        msg[1] == MduService.nak ||
        _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'Decoder does not respond',
        progress: 0,
        decoder: MapEntry(
          decoderId,
          ListTile(
            leading: const Icon(Icons.error),
            title: _decoders[decoderId]!.title,
          ),
        ),
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    // Salsa20 initialization vector
    final ZsuFirmware zsuFirmware = widget._zsu!.firmwares[decoderId]!;
    msg = await _retryOnFailure(() => _mdu.zsuSalsa20IV(zsuFirmware.iv!));
    if (msg.contains(MduService.ack)) return msg;

    // Erase flash
    _updateEphemeralState(status: 'Erasing');
    msg = await _retryOnFailure(
      () => _mdu.zsuErase(0, zsuFirmware.bin.length - 1),
    );
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'Erasing failed',
        progress: 0,
        decoder: MapEntry(
          decoderId,
          ListTile(
            leading: const Icon(Icons.error),
            title: _decoders[decoderId]!.title,
          ),
        ),
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    // Busy doesn't work for internal memory so don't check the response
    for (var i = 0; i < 5; ++i) {
      await Future.delayed(const Duration(seconds: 1));
      await _retryOnFailure(() => _mdu.busy());
    }

    // Write flash
    _updateEphemeralState(
      status: 'Writing',
      decoder: MapEntry(
        decoderId,
        ListTile(
          leading: const Icon(Icons.download_for_offline),
          title: _decoders[decoderId]!.title,
        ),
      ),
    );
    msg = await _zsuWrite(zsuFirmware.bin);
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'Writing failed',
        progress: 0,
        decoder: MapEntry(
          decoderId,
          ListTile(
            leading: const Icon(Icons.error),
            title: _decoders[decoderId]!.title,
          ),
        ),
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    // CRC32 start
    msg = await _retryOnFailure(
      () => _mdu.zsuCrc32Start(
        0,
        zsuFirmware.bin.length - 1,
        crc32(zsuFirmware.bin),
      ),
    );
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'ZSU update CRC32 check failed',
        progress: 0,
        decoder: MapEntry(
          decoderId,
          ListTile(
            leading: const Icon(Icons.error),
            title: _decoders[decoderId]!.title,
          ),
        ),
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    // CRC32 result
    msg = await _retryOnFailure(() => _mdu.zsuCrc32Result());
    if (msg.contains(MduService.ack) || _mdu.closeReason != null) {
      _updateEphemeralState(
        status: _mdu.closeReason ?? 'ZSU update CRC32 check failed',
        progress: 0,
        decoder: MapEntry(
          decoderId,
          ListTile(
            leading: const Icon(Icons.error),
            title: _decoders[decoderId]!.title,
          ),
        ),
      );
      return Uint8List.fromList([MduService.ack, MduService.ack]);
    }

    // Done with this ID
    _updateEphemeralState(
      decoder: MapEntry(
        decoderId,
        ListTile(
          leading: const Icon(Icons.check_circle),
          title: _decoders[decoderId]!.title,
        ),
      ),
    );

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
      final n = min(wsBatchSize, blocks.length - i);
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

      // WebSocket closed on the server side
      if (_mdu.closeReason != null) {
        return Uint8List.fromList([MduService.ack, MduService.ack]);
      }

      // Update progress
      _updateEphemeralState(
        status:
            'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        progress: i / blocks.length,
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
    _updateEphemeralState(status: 'Done', option: 'OK');
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
  Future<void> _updateEphemeralState({
    String? status,
    String? option,
    double? progress,
    MapEntry<int, ListTile>? decoder,
  }) async {
    setState(
      () {
        if (status != null) _status = status;
        if (option != null) _option = option;
        if (progress != null) _progress = progress;
        if (decoder != null) _decoders[decoder.key] = decoder.value;
      },
    );
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
