import 'dart:math';
import 'dart:typed_data';

import 'package:Frontend/providers/http_client.dart';
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
  static const int _repeat = 10;
  late final Uint8List _bytes;
  late final Uint8List _flash;
  late final ZusiService _zusi;
  String _status = 'Downloading';
  String _option = 'Cancel';
  int? _index;

  @override
  void initState() {
    super.initState();
    _zusi = ref.read(zusiServiceProvider);
    if (widget._bytes != null) _bytes = widget._bytes!;
    _execute();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('ZUSI'),
      children: [
        _statusWidget(),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
          },
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

  Widget _statusWidget() {
    return SimpleDialogOption(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _index != null ? _index! / _flash.length : null,
          ),
          Text(_status),
        ],
      ),
    );
  }

  Future<void> _execute() async {
    await _download();
    // TODO error handling
    await _connect();
    // TODO error handling
    await _features();
    // TODO error handling
    await _erase();
    // TODO error handling
    await _write();
    // TODO error handling
    await _exit();
    // TODO error handling
  }

  Future<void> _download() async {
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
    debugPrint('connect');
    await _zusi.ready();
    debugPrint('connected');
  }

  Future<void> _features() async {
    final msg = await _repeatOnFailure(() => _zusi.features());
    // TODO error handling
    debugPrint('features $msg');
  }

  Future<void> _erase() async {
    setState(() {
      _status = 'Erasing';
    });
    final msg = await _repeatOnFailure(() => _zusi.eraseZpp());
    // TODO error handling
    debugPrint('erase $msg');
  }

  Future<void> _write() async {
    setState(() {
      _status = 'Writing';
    });
    debugPrint('write');

    _index = 0;
    while (_index! < _flash.length) {
      final List<Future<Uint8List>> futs = List.generate(
        64,
        (index) {
          final start = _index! + 256 * index;
          final end = start + 256;
          final chunk = _flash.sublist(
              min(start, _flash.length), min(end, _flash.length));
          return chunk.isNotEmpty
              ? _zusi.writeZpp(start, chunk)
              : Future.value(Uint8List.fromList([ZusiService.ack]));
        },
      );
      FutureGroup<Uint8List> futureGroup = FutureGroup();
      for (final Future<Uint8List> fut in futs) {
        futureGroup.add(fut);
      }
      futureGroup.close();
      final List<Uint8List> results = await futureGroup.future;
      for (final msg in results) {
        if (msg[0] == ZusiService.ack) {
          setState(() {
            final done = _index! ~/ 1024;
            final total = _flash.length ~/ 1024;
            _status = 'Writing $done / $total kB';
            _index = _index! + 256;
          });
        } else {
          break;
        }
      }
      debugPrint('$_index / ${_flash.length}');
    }
  }

  Future<void> _exit() async {
    setState(() {
      _status = 'Done';
      _option = 'OK';
    });
    final msg = await _repeatOnFailure(() => _zusi.exit(0x00));
    // TODO error handling
    debugPrint('exit $msg');
  }

  Future<Uint8List> _repeatOnFailure(Future<Uint8List> Function() f) async {
    for (int i = 0; i < _repeat; i++) {
      final msg = await f();
      if (msg[0] == ZusiService.ack) return msg;
    }
    return Uint8List.fromList([ZusiService.nak]);
  }
}
