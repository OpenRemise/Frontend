// Copyright (C) 2024 Vincent Hamp
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

import 'package:Frontend/providers/zusi_service.dart';
import 'package:Frontend/services/zusi_service.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class ZusiDialog extends ConsumerStatefulWidget {
  final Uint8List? _bytes;

  const ZusiDialog(this._bytes, {super.key});

  @override
  ConsumerState<ZusiDialog> createState() => _ZusiDialogState();
}

/// \todo document
class _ZusiDialogState extends ConsumerState<ZusiDialog> {
  late final Uint8List _bytes;
  late final Uint8List _flash;
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
    if (widget._bytes != null) _bytes = widget._bytes!;
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
    if (msg.contains(ZusiService.nak)) return;

    msg = await _erase();
    if (msg.contains(ZusiService.nak)) return;

    msg = await _write();
    if (msg.contains(ZusiService.nak)) return;

    await _exit();
  }

  /// \todo document
  Future<void> _download() async {
    final int flashStart =
        _bytes[5] << 24 | _bytes[6] << 16 | _bytes[7] << 8 | _bytes[8] << 0;
    final int flashLength =
        _bytes[9] << 24 | _bytes[10] << 16 | _bytes[11] << 8 | _bytes[12] << 0;
    final int flashEnd = flashStart + flashLength;
    _flash = Uint8List.sublistView(_bytes, flashStart, flashEnd);
  }

  /// \todo document
  Future<void> _connect() async {
    setState(() {
      _status = 'Connecting';
    });
    await _zusi.ready;
  }

  /// \todo document
  Future<Uint8List> _features() async {
    final msg = await _repeatOnFailure(() => _zusi.features());
    debugPrint('ZUSI features $msg');
    return msg;
  }

  /// \todo document
  Future<Uint8List> _erase() async {
    setState(() {
      _status = 'Erasing';
    });
    final msg = await _repeatOnFailure(() => _zusi.eraseZpp());
    debugPrint('ZUSI erase $msg');
    return msg;
  }

  /// \todo document
  Future<Uint8List> _write() async {
    setState(() {
      _status = 'Writing';
    });

    const int blockSize = 256;
    final blocks = _flash.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Transmit 256 (or less) blocks
      final n = min(blockSize, blocks.length - i);
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
        else if (failCount < 10) {
          ++failCount;
          i = max(i - 1, 0);
          debugPrint('ZUSI zusiUpdate failed $failCount');
          break;
        }
        // Or bail
        else {
          return msg;
        }
      }

      //
      setState(() {
        _status =
            'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB';
        _progress = i / blocks.length;
      });
    }

    return Uint8List.fromList([ZusiService.ack]);
  }

  /// \todo document
  Future<Uint8List> _exit() async {
    setState(() {
      _status = 'Done';
      _option = 'OK';
    });
    final msg = await _repeatOnFailure(() => _zusi.exit(0x00));
    debugPrint('ZUSI exit $msg');
    return msg;
  }

  /// \todo document
  Future<Uint8List> _repeatOnFailure(Function() f, {int repeat = 10}) async {
    var msg = Uint8List.fromList([ZusiService.nak]);
    for (int i = 0; i < repeat; i++) {
      f();
      msg = await _events.next;
      if (msg[0] == ZusiService.ack) return msg;
    }
    return msg;
  }
}
