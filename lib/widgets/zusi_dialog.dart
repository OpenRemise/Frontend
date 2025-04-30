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
import 'dart:typed_data';

import 'package:Frontend/constants/ws_batch_size.dart';
import 'package:Frontend/models/zpp.dart';
import 'package:Frontend/providers/zusi_service.dart';
import 'package:Frontend/services/zusi_service.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class ZusiDialog extends ConsumerStatefulWidget {
  final Zpp _zpp;

  const ZusiDialog.zpp(this._zpp, {super.key});

  @override
  ConsumerState<ZusiDialog> createState() => _ZusiDialogState();
}

/// \todo document
class _ZusiDialogState extends ConsumerState<ZusiDialog> {
  static const int _retries = 10;
  late final ZusiService _zusi;
  late final StreamQueue<Uint8List> _events;
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  /// \todo document
  @override
  void initState() {
    super.initState();
    _zusi = ref.read(zusiServiceProvider);
    _events = StreamQueue(_zusi.stream);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ZUSI'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _progress,
          ),
          Text(_status),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_option),
        ),
      ],
    );
  }

  /// \todo document
  @override
  void dispose() {
    _events.cancel();
    _zusi.close();
    super.dispose();
  }

  /// \todo document
  Future<void> _execute() async {
    await _connect();

    var msg = await _features();
    if (!msg.contains(ZusiService.ack)) {
      await _exit(); // We can still bail here
      return;
    }
    msg = await _zppLcDcQuery();
    if (!msg.contains(ZusiService.ack)) {
      await _exit(); // ... or here
      return;
    }
    msg = await _zppErase();
    if (!msg.contains(ZusiService.ack)) return;
    msg = await _zppUpdate();
    if (!msg.contains(ZusiService.ack)) return;
    msg = await _zppCvs();
    if (!msg.contains(ZusiService.ack)) return;
    msg = await _exit();
    if (!msg.contains(ZusiService.ack)) return;

    await _disconnect();
  }

  /// \todo document
  Future<void> _connect() async {
    _updateEphemeralState(status: 'Connecting');
    await _zusi.ready;
  }

  /// \todo document
  Future<Uint8List> _features() async {
    final msg = await _retryOnFailure(() => _zusi.features());
    if (!msg.contains(ZusiService.ack) || _zusi.closeReason != null) {
      _updateEphemeralState(
        status: _zusi.closeReason ?? 'No decoder found',
        progress: 0,
      );
      return Uint8List.fromList([ZusiService.nak]);
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _zppLcDcQuery() async {
    if (!widget._zpp.coded) return Uint8List.fromList([ZusiService.ack]);
    _updateEphemeralState(status: 'Check if load code is valid', progress: 0);
    final msg = await _retryOnFailure(
      () => _zusi.zppLcDcQuery(widget._zpp.developerCode),
    );
    if (!msg.contains(ZusiService.ack) ||
        _zusi.closeReason != null ||
        msg[1] == 0x00) {
      _updateEphemeralState(
        status: _zusi.closeReason ?? 'Load code not valid',
        progress: 0,
      );
      return Uint8List.fromList([ZusiService.nak]);
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _zppErase() async {
    _updateEphemeralState(status: 'Erasing');
    final msg = await _retryOnFailure(() => _zusi.zppErase());
    if (!msg.contains(ZusiService.ack) || _zusi.closeReason != null) {
      _updateEphemeralState(
        status: _zusi.closeReason ?? 'Erasing failed',
        progress: 0,
      );
      return Uint8List.fromList([ZusiService.nak]);
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _zppUpdate() async {
    _updateEphemeralState(status: 'Writing');

    const int blockSize = 256;
    final blocks = widget._zpp.flash.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(wsBatchSize, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _zusi.zppWrite((i + j) * blockSize, Uint8List.fromList(blocks[i + j]));
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (msg.contains(ZusiService.ack)) {
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
          _updateEphemeralState(status: 'Writing failed', progress: 0);
          return Uint8List.fromList([ZusiService.nak]);
        }
      }

      // WebSocket closed on the server side
      if (_zusi.closeReason != null) {
        _updateEphemeralState(status: _zusi.closeReason, progress: 0);
        return Uint8List.fromList([ZusiService.nak]);
      }

      // Update progress
      _updateEphemeralState(
        status:
            'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        progress: i / blocks.length,
      );
    }

    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _zppCvs() async {
    int i = 0;
    for (final entry in widget._zpp.cvs.entries) {
      final msg =
          await _retryOnFailure(() => _zusi.cvWrite(entry.key, entry.value));
      if (!msg.contains(ZusiService.ack) || _zusi.closeReason != null) {
        _updateEphemeralState(
          status: _zusi.closeReason ?? 'Writing CVs failed',
          progress: 0,
        );
        return Uint8List.fromList([ZusiService.nak]);
      }

      // Update progress
      _updateEphemeralState(
        status: 'Writing ${++i} / ${widget._zpp.cvs.length} CVs',
        progress: i / widget._zpp.cvs.length,
      );
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  ///
  /// \note
  /// Unfortunately, we cannot check the return value because the command is not implemented in MX decoders.
  Future<Uint8List> _exit() async {
    await _retryOnFailure(() => _zusi.exit(cv8Reset: true));
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<void> _disconnect() async {
    _updateEphemeralState(status: 'Done', option: 'OK');
    await _zusi.close();
  }

  /// \todo document
  Future<Uint8List> _retryOnFailure(
    Function() f, {
    int retries = _retries,
  }) async {
    var msg = Uint8List.fromList([ZusiService.nak]);
    for (int i = 0; i < retries; i++) {
      f();
      msg = await _events.next;
      if (msg.contains(ZusiService.ack)) return msg;
    }
    return msg;
  }

  /// \todo document
  Future<void> _updateEphemeralState({
    String? status,
    String? option,
    double? progress,
  }) async {
    setState(
      () {
        if (status != null) _status = status;
        if (option != null) _option = option;
        if (progress != null) _progress = progress;
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
