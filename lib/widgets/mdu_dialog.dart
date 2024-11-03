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
import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/mdu_service.dart';
import 'package:Frontend/services/mdu_service.dart';
import 'package:Frontend/utilities/crc32.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MduDialog extends ConsumerStatefulWidget {
  final Uint8List? _bytes;
  final Uri? _uri;

  const MduDialog.fromFile(this._bytes, {super.key}) : _uri = null;
  const MduDialog.fromUri(this._uri, {super.key}) : _bytes = null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MduDialogState();
}

class _MduDialogState extends ConsumerState<MduDialog> {
  late final Zsu _zsu;
  late final MduService _mdu;
  late final StreamQueue<Uint8List> _events;
  final Map<int, ListTile> _decoders = {};
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  @override
  void initState() {
    debugPrint('MduDialog initState');
    super.initState();
    _mdu = ref.read(mduServiceProvider);
    _events = StreamQueue(_mdu.stream);
    if (widget._bytes != null) _zsu = Zsu(widget._bytes!);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  @override
  void dispose() {
    debugPrint('MduDialog dispose');
    _mdu.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('MDU'),
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
              children: [for (final tile in _decoders.values) tile],
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
    await _download();
    await _connect();

    var msg = await _configTransferRate();
    if (msg.contains(ack)) return;

    msg = await _search();
    if (msg.contains(ack)) return;

    for (final decoderId in _decoders.keys) {
      msg = await _update(decoderId);
      if (msg[0] == ack) return;
    }

    await _disconnect();
  }

  Future<void> _download() async {
    // TODO (see ZUSI)
  }

  Future<void> _connect() async {
    setState(() {
      _status = 'Connecting';
    });
    await _mdu.ready;
  }

  Future<Uint8List> _configTransferRate() async {
    setState(() {
      _status = 'Config transfer rate';
    });

    if (_zsu.firmwares.length > 1) {
      for (int tf = 1; tf <= 4; ++tf) {
        final msg = await _repeatOnFailure(() => _mdu.configTransferRate(tf));
        debugPrint('Set transfer rate $tf $msg');
        if (msg[0] == nak && msg[1] == nak) return msg;
      }
    }
    final msg = await _repeatOnFailure(() => _mdu.configTransferRate(0));
    debugPrint('Set transfer rate fallback $msg');
    return msg;
  }

  Future<Uint8List> _search() async {
    setState(() {
      _status = 'Search decoders';
    });

    for (final entry in _zsu.firmwares.entries) {
      final decoderId = entry.key;
      await _repeatOnFailure(() => _mdu.ping(0, 0));
      final msg =
          await _repeatOnFailure(() => _mdu.ping(0, decoderId), repeat: 1);
      if (msg[0] == nak && msg[1] == ack) {
        final exp = RegExp(r'\w{5,}-[0-9]');
        final match = exp.firstMatch(entry.value.name);
        if (match != null && match[0] != null) {
          final String name = match[0]!;
          setState(() {
            _decoders[decoderId] = ListTile(
              leading: const Icon(Icons.circle_outlined),
              title: Text(name),
            );
          });
        }
      }
    }

    return Uint8List.fromList([_decoders.isEmpty ? ack : nak, nak]);
  }

  Future<Uint8List> _update(int decoderId) async {
    // Ping all decoders
    setState(() {
      _decoders[decoderId] = ListTile(
        leading: const Icon(Icons.pending_outlined),
        title: _decoders[decoderId]!.title,
      );
      _status = 'Ping';
      _progress = null;
    });
    await _repeatOnFailure(() => _mdu.ping(0, 0));

    // Ping decoder to update
    var msg = await _repeatOnFailure(() => _mdu.ping(0, decoderId));
    debugPrint('Ping $decoderId $msg');
    if (msg[0] == ack || msg[1] == nak) return msg;

    final ZsuFirmware zsuFirmware = _zsu.firmwares[decoderId]!;
    msg = await _repeatOnFailure(() => _mdu.firmwareSalsa20IV(zsuFirmware.iv!));
    if (msg.contains(ack)) return msg;

    // Erase flash
    setState(() {
      _status = 'Erasing';
    });
    msg = await _repeatOnFailure(
      () => _mdu.firmwareErase(0, zsuFirmware.bin.length - 1),
    );
    if (msg.contains(ack)) return msg;

    // Busy doesn't work for internal memory so don't check the response
    for (var i = 0; i < 5; ++i) {
      await Future.delayed(const Duration(seconds: 1));
      await _repeatOnFailure(() => _mdu.busy());
    }

    // Write flash
    setState(() {
      _decoders[decoderId] = ListTile(
        leading: const Icon(Icons.downloading_outlined),
        title: _decoders[decoderId]!.title,
      );
    });
    msg = await _write(zsuFirmware.bin);
    if (msg.contains(ack)) return msg;

    // CRC32 check
    msg = await _repeatOnFailure(
      () => _mdu.firmwareCrc32Start(
        0,
        zsuFirmware.bin.length - 1,
        crc32(zsuFirmware.bin),
      ),
    );
    if (msg.contains(ack)) return msg;
    msg = await _repeatOnFailure(() => _mdu.firmwareCrc32Result());
    if (msg.contains(ack)) return msg;

    // Done with this ID
    setState(() {
      _decoders[decoderId] = ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: _decoders[decoderId]!.title,
      );
    });
    return Uint8List.fromList([nak, nak]);
  }

  Future<Uint8List> _write(Uint8List bin) async {
    int index = 0;
    int backstep = 0;
    while (index < bin.length) {
      final start = index;
      final end = index + 64;
      final chunk = bin.sublist(start, min(end, bin.length));
      final msg =
          await _repeatOnFailure(() => _mdu.firmwareUpdate(index, chunk));
      // Go either forward
      if (msg[0] == nak && msg[1] == nak) {
        backstep = 0;
        index += chunk.length;
      }
      // Or back (limited number of times)
      else if (backstep < 10) {
        ++backstep;
        index = min(index - chunk.length, 0);
        debugPrint('going back...?');
      }
      // If backstep didn't work either, cancel
      else {
        return msg;
      }
      final done = index ~/ 1024;
      final total = bin.length ~/ 1024;
      setState(() {
        _status = 'Writing $done / $total kB';
        _progress = index / bin.length;
      });
    }
    return Uint8List.fromList([nak, nak]);
  }

  Future<Uint8List> _disconnect() async {
    setState(() {
      _status = 'Done';
      _option = 'OK';
    });
    await _repeatOnFailure(() => _mdu.ping(0, 0));
    await _repeatOnFailure(() => _mdu.firmwareCrc32ResultExit());
    await _mdu.close();
    return Uint8List.fromList([nak, nak]);
  }

  Future<Uint8List> _repeatOnFailure(Function() f, {int repeat = 10}) async {
    var msg = Uint8List.fromList([ack, nak]);
    for (int i = 0; i < repeat; i++) {
      f();
      msg = await _events.next;
      if (msg[0] == nak) return msg;
    }
    return msg;
  }
}
