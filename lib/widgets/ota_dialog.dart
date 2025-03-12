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

import 'package:Frontend/providers/ota_service.dart';
import 'package:Frontend/services/ota_service.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class OtaDialog extends ConsumerStatefulWidget {
  final Uint8List _bin;

  const OtaDialog.fromFile(this._bin, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtaDialogState();
}

/// \todo document
class _OtaDialogState extends ConsumerState<OtaDialog> {
  static const int _chunkSize = 1024;
  late final Uint8List _bin;
  late final OtaService _ota;
  late final StreamQueue<Uint8List> _events;
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  /// \todo document
  @override
  void initState() {
    super.initState();
    _bin = widget._bin;
    _ota = ref.read(otaServiceProvider);
    _events = StreamQueue(_ota.stream);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  /// \todo document
  @override
  void dispose() {
    _events.cancel();
    _ota.close();
    super.dispose();
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('OTA'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: _progress),
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
  Future<void> _execute() async {
    await _connect();

    final msg = await _write();
    if (!msg.contains(OtaService.ack)) return;

    await _disconnect();
  }

  /// \todo document
  Future<void> _connect() async {
    _setStatusState('Connecting');
    await _ota.ready;
  }

  /// \todo document
  Future<Uint8List> _write() async {
    _setStatusState('Writing');

    int i = 0;
    while (i < _bin.length) {
      final start = i;
      final end = start + _chunkSize;
      final chunk = _bin.sublist(start, min(end, _bin.length));
      _ota.write(chunk);

      final msg = await _events.next;
      if (!msg.contains(OtaService.ack)) {
        return _setErrorState('Writing failed');
      }

      i += chunk.length;

      // Update progress
      _setProgressState(
        'Writing ${i ~/ 1024} / ${_bin.length ~/ 1024} kB',
        i / _bin.length,
      );
    }

    return Uint8List.fromList([OtaService.ack]);
  }

  /// \todo document
  Future<void> _disconnect() async {
    _setStatusState('Done', 'OK');
    await _ota.close();
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
    return Uint8List.fromList([OtaService.nak]);
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
