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

import 'package:Frontend/constants/ack.dart';
import 'package:Frontend/constants/nak.dart';
import 'package:Frontend/providers/ota_service.dart';
import 'package:Frontend/services/ota_service.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtaDialog extends ConsumerStatefulWidget {
  final Uint8List _bin;

  const OtaDialog.fromFile(this._bin, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtaDialogState();
}

class _OtaDialogState extends ConsumerState<OtaDialog> {
  static const int _chunkSize = 1024;
  late final Uint8List _bin;
  late final OtaService _ota;
  late final StreamQueue<Uint8List> _events;
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  @override
  void initState() {
    debugPrint('OtaDialog initState');
    super.initState();
    _bin = widget._bin;
    _ota = ref.read(otaServiceProvider);
    _events = StreamQueue(_ota.stream);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  @override
  void dispose() {
    debugPrint('OtaDialog dispose');
    _ota.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Firmware update'),
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
          onPressed: () => Navigator.pop(context),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(_option),
          ),
        ),
      ],
    );
  }

  Future<void> _execute() async {
    await _connect();
    final msg = await _write();
    if (msg.contains(nak)) return;
    await _disconnect();
  }

  Future<void> _connect() async {
    setState(() {
      _status = 'Connecting';
    });
    await _ota.ready;
  }

  Future<Uint8List> _write() async {
    int index = 0;
    while (index < _bin.length) {
      final start = index;
      final end = start + _chunkSize;
      final chunk = _bin.sublist(start, min(end, _bin.length));
      _ota.write(chunk);

      final msg = await _events.next;
      if (msg.contains(nak)) {
        setState(() {
          _status = 'Failed';
        });
        return msg;
      }

      index += chunk.length;
      final done = index ~/ 1024;
      final total = _bin.length ~/ 1024;
      setState(() {
        _status = 'Writing $done / $total kB';
        _progress = index / _bin.length;
      });
    }

    return Uint8List.fromList([ack]);
  }

  Future<void> _disconnect() async {
    setState(() {
      _status = 'Done';
      _option = 'OK';
    });
    await _ota.close();
  }
}
