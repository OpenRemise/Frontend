import 'dart:math';
import 'dart:typed_data';

import 'package:Frontend/providers/ota_service.dart';
import 'package:Frontend/services/ota_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtaDialog extends ConsumerStatefulWidget {
  final Uint8List _bin;

  const OtaDialog.fromFile(this._bin, {super.key});

  @override
  ConsumerState<OtaDialog> createState() => _OtaDialogState();
}

class _OtaDialogState extends ConsumerState<OtaDialog> {
  static const int _chunkSize = 1024;
  late final Uint8List _bin;
  late final OtaService _ota;
  String _status = 'Connecting';
  String _option = 'Cancel';
  int? _index;

  @override
  void initState() {
    super.initState();
    _bin = widget._bin;
    _ota = ref.read(otaServiceProvider);
    _update();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Firmware update'),
      children: [
        _statusWidget(),
        SimpleDialogOption(
          onPressed: _cancel,
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
    debugPrint('OtaDialog dispose');
    _ota.close();
    super.dispose();
  }

  Widget _statusWidget() {
    return SimpleDialogOption(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _index != null ? _index! / _bin.length : null,
          ),
          Text(_status),
        ],
      ),
    );
  }

  Future<void> _update() async {
    // Wait for WebSocket to be come ready
    await _ota.ready();

    // Transmit data
    _index = 0;
    while (_index! < _bin.length) {
      final start = _index!;
      final end = _index! + _chunkSize;
      final chunk = _bin.sublist(start, min(end, _bin.length));
      final msg = await _ota.write(chunk);
      if (msg[0] == OtaService.ack) {
        setState(() {
          final done = _index! ~/ 1024;
          final total = _bin.length ~/ 1024;
          _index = _index! + chunk.length;
          _status = 'Writing $done / $total kB';
        });
      } else {
        setState(() {
          _status = 'Failed';
        });
        break;
      }
    }

    setState(() {
      _status = 'Done';
      _option = 'OK';
    });

    // Close WebSocket
    _ota.close();
  }

  void _cancel() {
    _ota.close();
    Navigator.pop(context);
  }
}
