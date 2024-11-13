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

import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/decup_service.dart';
import 'package:Frontend/services/decup_service.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DecupDialog extends ConsumerStatefulWidget {
  final Uint8List? _bytes;
  final Uri? _uri;

  const DecupDialog.fromFile(this._bytes, {super.key}) : _uri = null;
  const DecupDialog.fromUri(this._uri, {super.key}) : _bytes = null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DecupDialogState();
}

class _DecupDialogState extends ConsumerState<DecupDialog> {
  late final Zsu _zsu;
  late final DecupService _decup;
  late final StreamQueue<Uint8List> _events;
  final Map<int, ListTile> _decoder = {};
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  @override
  void initState() {
    debugPrint('DecupDialog initState');
    super.initState();
    _decup = ref.read(decupServiceProvider);
    _events = StreamQueue(_decup.stream);
    if (widget._bytes != null) _zsu = Zsu(widget._bytes!);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  @override
  void dispose() {
    debugPrint('DecupDialog dispose');
    _decup.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('DECUP'),
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
              children: [for (final tile in _decoder.values) tile],
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

  Future<void> _execute() async {
    await _connect();

    for (var i = 0; i < 100; ++i) {
      await _preamble();
    }

    var msg = await _search();
    if (msg.contains(DecupService.nak)) return;

    msg = await _blockCount();
    if (msg.contains(DecupService.nak)) return;

    msg = await _securityByte1();
    if (msg.contains(DecupService.nak)) return;

    msg = await _securityByte2();
    if (msg.contains(DecupService.nak)) return;

    msg = await _update();
    if (msg[0] == DecupService.nak) return;

    await _disconnect();
  }

  Future<void> _connect() async {
    setState(() {
      _status = 'Connecting';
    });
    await _decup.ready;
  }

  Future<void> _preamble() async {
    _decup.preamble();
    final msg = await _events.next;
    debugPrint('preamble $msg');
  }

  Future<Uint8List> _search() async {
    setState(() {
      _status = 'Search decoder';
    });

    for (final entry in _zsu.firmwares.entries) {
      final decoderId = entry.key;
      _decup.startByte(decoderId);
      final msg = await _events.next;
      if (msg.isNotEmpty && msg.first == DecupService.ack) {
        setState(() {
          _decoder[decoderId] = ListTile(
            leading: const Icon(Icons.circle_outlined),
            title: Text(entry.value.name),
          );
        });
      }
    }

    return Uint8List.fromList(
      [_decoder.isNotEmpty ? DecupService.ack : DecupService.nak],
    );
  }

  Future<Uint8List> _blockCount() async {
    final blockCount =
        (_zsu.firmwares[_decoder.keys.first]!.bin.length ~/ 256 + 8 - 1);
    _decup.blockCount(blockCount);
    return await _events.next;
  }

  Future<Uint8List> _securityByte1() async {
    _decup.securityByte1();
    return await _events.next;
  }

  Future<Uint8List> _securityByte2() async {
    _decup.securityByte1();
    return await _events.next;
  }

  Future<Uint8List> _update() async {
    final decoderId = _decoder.keys.first;

    // Write flash
    setState(() {
      _decoder[decoderId] = ListTile(
        leading: const Icon(Icons.downloading_outlined),
        title: _decoder[decoderId]!.title,
      );
    });

    final blockSize =
        decoderId == 200 || (decoderId >= 202 && decoderId <= 205) ? 32 : 64;
    final blocks = _zsu.firmwares[decoderId]!.bin.slices(blockSize);

    int blockCount = 0;
    for (final block in blocks) {
      _decup.block(blockCount++, Uint8List.fromList(block));
      await _events.next;
      setState(() {
        _status =
            'Writing ${blockCount * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB';
        _progress = blockCount / blocks.length;
      });
    }

    // Done
    setState(() {
      _decoder[decoderId] = ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: _decoder[decoderId]!.title,
      );
    });

    return Uint8List.fromList([DecupService.ack]);
  }

  Future<Uint8List> _disconnect() async {
    setState(() {
      _status = 'Done';
      _option = 'OK';
    });
    await _decup.close();
    return Uint8List.fromList([DecupService.ack]);
  }
}
