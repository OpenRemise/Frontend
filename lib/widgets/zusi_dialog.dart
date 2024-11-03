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

import 'package:Frontend/constants/ack.dart';
import 'package:Frontend/constants/nak.dart';
import 'package:Frontend/providers/zusi_service.dart';
import 'package:Frontend/services/zusi_service.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZusiDialog extends ConsumerStatefulWidget {
  final Uint8List? _bytes;
  final Uri? _uri;

  const ZusiDialog.fromFile(this._bytes, {super.key}) : _uri = null;
  const ZusiDialog.fromUri(this._uri, {super.key}) : _bytes = null;

  @override
  ConsumerState<ZusiDialog> createState() => _ZusiDialogState();
}

class _ZusiDialogState extends ConsumerState<ZusiDialog> {
  late final Uint8List _bytes;
  late final Uint8List _flash;
  late final ZusiService _zusi;
  late final StreamQueue<Uint8List> _events;
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

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

  @override
  void dispose() {
    debugPrint('ZusiDialog dispose');
    _zusi.close();
    super.dispose();
  }

  Future<void> _execute() async {
    await _download();
    await _connect();

    var msg = await _features();
    if (msg.contains(nak)) return;

    msg = await _erase();
    if (msg.contains(nak)) return;

    msg = await _write();
    if (msg.contains(nak)) return;

    await _exit();
  }

  Future<void> _download() async {
    /*
    setState(() {
      _status = 'Downloading';
    });

    // Download file
    if (widget._uri != null) {
      debugPrint('start Download!');
      final client = ref.read(httpClientProvider);
      final response = await client.get(widget._uri!);
      debugPrint('finished Download ${response.bodyBytes.length}');
      _bytes = response.bodyBytes;
    }
    */

    final int flashStart =
        _bytes[5] << 24 | _bytes[6] << 16 | _bytes[7] << 8 | _bytes[8] << 0;
    final int flashLength =
        _bytes[9] << 24 | _bytes[10] << 16 | _bytes[11] << 8 | _bytes[12] << 0;
    final int flashEnd = flashStart + flashLength;
    _flash = Uint8List.sublistView(_bytes, flashStart, flashEnd);
  }

  Future<void> _connect() async {
    setState(() {
      _status = 'Connecting';
    });
    await _zusi.ready;
  }

  Future<Uint8List> _features() async {
    final msg = await _repeatOnFailure(() => _zusi.features());
    debugPrint('features $msg');
    return msg;
  }

  Future<Uint8List> _erase() async {
    setState(() {
      _status = 'Erasing';
    });
    final msg = await _repeatOnFailure(() => _zusi.eraseZpp());
    debugPrint('erase $msg');
    return msg;
  }

  Future<Uint8List> _write() async {
    setState(() {
      _status = 'Writing';
    });

    int index = 0;
    while (index < _flash.length) {
      // Prepare up to 64 chunks
      int i = 0;
      for (; i < 64; ++i) {
        final start = index + 256 * i;
        final end = start + 256;
        final chunk = _flash.sublist(
          min(start, _flash.length),
          min(end, _flash.length),
        );
        if (chunk.isEmpty) break;
        _zusi.writeZpp(start, chunk);
      }

      // Wait for all responses
      final msgs = await _events.take(i);
      for (final msg in msgs) {
        if (msg[0] == nak) break;
        index += 256;
        final done = index ~/ 1024;
        final total = _flash.length ~/ 1024;
        setState(() {
          _status = 'Writing $done / $total kB';
          _progress = index / _flash.length;
        });
      }
    }

    return Uint8List.fromList([ack]);
  }

  Future<Uint8List> _exit() async {
    setState(() {
      _status = 'Done';
      _option = 'OK';
    });
    final msg = await _repeatOnFailure(() => _zusi.exit(0x00));
    debugPrint('exit $msg');
    return msg;
  }

  Future<Uint8List> _repeatOnFailure(Function() f, {int repeat = 10}) async {
    var msg = Uint8List.fromList([nak]);
    for (int i = 0; i < repeat; i++) {
      f();
      msg = await _events.next;
      if (msg[0] == ack) return msg;
    }
    return msg;
  }
}
