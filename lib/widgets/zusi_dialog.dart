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
    return SimpleDialog(
      title: const Text('ZUSI'),
      children: [
        SimpleDialogOption(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: _progress,
              ),
              Text(_status),
            ],
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
  @override
  void dispose() {
    _zusi.close();
    super.dispose();
  }

  /// \todo document
  Future<void> _execute() async {
    await _download();
    await _connect();

    var msg = await _features();
    if (!msg.contains(ZusiService.ack)) return;
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
  Future<void> _download() async {}

  /// \todo document
  Future<void> _connect() async {
    _setStatusState('Connecting');
    await _zusi.ready;
  }

  /// \todo document
  Future<Uint8List> _features() async {
    final msg = await _retryOnFailure(() => _zusi.features());
    if (!msg.contains(ZusiService.ack)) {
      return _setErrorState('No decoder found');
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _zppErase() async {
    _setStatusState('Erasing');
    final msg = await _retryOnFailure(() => _zusi.eraseZpp());
    if (!msg.contains(ZusiService.ack)) {
      return _setErrorState('Erasing failed');
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _zppUpdate() async {
    _setStatusState('Writing');

    const int blockSize = 256;
    final blocks = widget._zpp.flash.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(256, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _zusi.writeZpp((i + j) * blockSize, Uint8List.fromList(blocks[i + j]));
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
          return _setErrorState('Writing failed');
        }
      }

      // Update progress
      _setProgressState(
        'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        i / blocks.length,
      );
    }

    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _zppCvs() async {
    int i = 0;
    for (final entry in widget._zpp.cvs.entries) {
      final msg =
          await _retryOnFailure(() => _zusi.writeCv(entry.key, entry.value));
      if (!msg.contains(ZusiService.ack)) {
        return _setErrorState('Writing CVs failed');
      }

      // Update progress
      _setProgressState(
        'Writing ${++i} / ${widget._zpp.cvs.length} CVs',
        i / widget._zpp.cvs.length,
      );
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _exit() async {
    final msg = await _retryOnFailure(() => _zusi.exit(1 << 1));
    if (!msg.contains(ZusiService.ack)) {
      return _setErrorState('Exit failed');
    }
    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<void> _disconnect() async {
    _setStatusState('Done', 'OK');
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
  Future<Uint8List> _setErrorState(String status) async {
    setState(() {
      _status = status;
      _progress = 0;
    });
    return Uint8List.fromList([ZusiService.nak]);
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
