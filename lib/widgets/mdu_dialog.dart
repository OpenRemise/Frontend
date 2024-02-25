import 'dart:async';
import 'dart:math';

import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/http_client.dart';
import 'package:Frontend/providers/mdu_service.dart';
import 'package:Frontend/services/mdu_service.dart';
import 'package:Frontend/utilities/crc32.dart';
import 'package:archive/archive.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _UpdateableDecoders = Map<int, Set<int>>;
typedef _DecoderTiles = Map<int, ListTile>;

// ignore: constant_identifier_names
const _UpdateableDecoders _FAKE_SERVICES_updateableDecoders = {
  // MS450-2
  0x06043202: {0x11111111},
  // MS950-1
  0x09093201: {
    0x11111111,
    0x22222222,
    0x33333333,
  },
  // Non existing
  0x7D020000 | 0x00100000: {
    0x11111111,
  },
  // MN330-0
  0x7E031E00 | 0x00100000: {
    0x11111111,
    0x22222222,
  },
};

class MduDialog extends ConsumerStatefulWidget {
  final Uint8List? _bytes;
  final Uri? _uri;

  const MduDialog.fromFile(this._bytes, {super.key}) : _uri = null;
  const MduDialog.fromUri(this._uri, {super.key}) : _bytes = null;

  @override
  ConsumerState<MduDialog> createState() => _MduDialogState();
}

class _MduDialogState extends ConsumerState<MduDialog> {
  static const int _repeat = 10;
  late final Zsu _zsu;
  late final MduService _mdu;
  final _UpdateableDecoders _updateableDecoders = {};
  final _DecoderTiles _decoderTiles = {};
  String _status = 'Downloading';
  String _option = 'Cancel';
  double? _progress;

  @override
  void initState() {
    super.initState();
    _mdu = ref.read(mduServiceProvider);
    if (widget._bytes != null) _zsu = Zsu(widget._bytes!);
    _execute();
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
        _statusWidget(),
        if (_updateableDecoders.isNotEmpty) _decoderListWidget(),
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

  Widget _statusWidget() {
    return SimpleDialogOption(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: _progress),
          Text(_status),
        ],
      ),
    );
  }

  Widget _decoderListWidget() {
    return SimpleDialogOption(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final tile in _decoderTiles.entries) tile.value],
      ),
    );
  }

  Future<void> _execute() async {
    await _download();
    // TODO error handling
    await _connect();
    // TODO error handling
    await _configTransferRate();
    // TODO error handling

    // ZSU contains multiple firmwares, search decoders
    if (_zsu.entries.length > 1) {
      await _binaryTreeSearch();
      // TODO error handling
    }
    // ZSU contains only single firmware, flash it
    else {
      _zsu.entries.forEach((decoderId, value) {
        _addDecoder(decoderId, 0);
      });
    }

    for (final MapEntry<int, Set<int>> updateableDecoder
        in _updateableDecoders.entries) {
      final int decoderId = updateableDecoder.key;
      final ZsuDecoder zsuDecoder = _zsu.entries[decoderId]!;

      setState(() {
        _decoderTiles[decoderId] = ListTile(
          title: _decoderTiles[decoderId]!.title,
          trailing: const Icon(Icons.pending_outlined),
        );
      });

      await _ping(0, decoderId);
      // TODO error handling
      await _salsa20IV(zsuDecoder.iv!);
      // TODO error handling
      await _erase(0, zsuDecoder.bin.length - 1); // Closed interval
      // TODO error handling

      // Just wait 5s...
      await Future.delayed(const Duration(seconds: 5));

      setState(() {
        _decoderTiles[decoderId] = ListTile(
          title: _decoderTiles[decoderId]!.title,
          trailing: const Icon(Icons.downloading_outlined),
        );
      });

      await _write(zsuDecoder.bin);
      // TODO error handling

      await _crc32Start(
        0,
        zsuDecoder.bin.length - 1, // Closed interval
        crc32(zsuDecoder.bin),
      );
      // TODO error handling

      await _crc32Result();
      // TODO error handling}

      setState(() {
        _decoderTiles[decoderId] = ListTile(
          title: _decoderTiles[decoderId]!.title,
          trailing: const Icon(Icons.check_circle_outline),
        );
      });
    }

    await _ping(0, 0);
    // TODO error handling
    await _crc32ResultExit();
    // TODO error handling}

    // TODO error handling}
    setState(() {
      _status = 'Done';
      _option = 'OK';
      _progress = 1.0;
    });
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
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      if (archive.files.length == 1) {
        _zsu = Zsu(archive.first.content as Uint8List);
      } else {
        // TODO error!
      }
    }
  }

  Future<void> _connect() async {
    setState(() {
      _status = 'Connecting';
    });
    debugPrint('connect');
    await _mdu.ready();
    debugPrint('connected');
  }

  Future<void> _configTransferRate() async {
    setState(() {
      _status = 'Config transfer rate';
    });

    if (_zsu.entries.length > 1) {
      for (int tf = 1; tf <= 4; ++tf) {
        final msg = await _repeatOnFailure(() => _mdu.configTransferRate(tf));
        debugPrint('Set transfer rate $tf $msg');
        if (msg[0] == MduService.nak && msg[1] == MduService.nak) return;
      }
    }
    final msg = await _repeatOnFailure(() => _mdu.configTransferRate(0));
    debugPrint('Set transfer rate fallback $msg');
  }

  Future<void> _binaryTreeSearch() async {
    setState(() {
      _status = 'Search decoders';
    });

    // For fake services start adding decoders from prepared map
    if (const String.fromEnvironment('FAKE_SERVICES') == 'true') {
      for (final MapEntry<int, Set<int>> updateableDecoder
          in _FAKE_SERVICES_updateableDecoders.entries) {
        final int decoderId = updateableDecoder.key;
        final Set<int> serialNumbers = updateableDecoder.value;
        for (final int serialNumber in serialNumbers) {
          await Future.delayed(const Duration(seconds: 2));
          _addDecoder(
            decoderId,
            serialNumber,
          );
        }
      }
    }
    // On WebSocket do binary tree search
    else {
      Int64 uniqueId = Int64.ZERO;
      int lastDiscrepancy = 0;
      bool lastDevice = false;
      bool searchDirection;

      while (!lastDevice) {
        var msg = await _mdu.binaryTreeSearch(255);

        int lastZero = 0;

        for (int idBitNumber = 1; idBitNumber < 64; ++idBitNumber) {
          final int i = idBitNumber - 1;
          final Int64 bitMask = Int64.ONE << i;

          // Read bit
          msg = await _repeatOnFailure(() => _mdu.binaryTreeSearch(i));
          // TODO error handling
          final bool idBit = msg[1] == MduService.ack ? true : false;

          // Read complement bit
          msg = await _repeatOnFailure(() => _mdu.binaryTreeSearch(i + 64));
          // TODO error handling
          final bool cmpIdBit = msg[1] == MduService.ack ? true : false;

          // Set search_direction to id_bit
          if (idBit != cmpIdBit) {
            searchDirection = idBit;
          } else {
            // Set search_direction to id_bit_number in ROM_NO
            if (idBitNumber < lastDiscrepancy) {
              searchDirection = (uniqueId & bitMask) > 0;
            } else {
              searchDirection = idBitNumber == lastDiscrepancy;
            }

            // Set last_zero to current id_bit_number
            if (!searchDirection) lastZero = idBitNumber;
          }

          // Set id_bit_number in ROM_NO to search_direction and send to 1-Wire
          if (searchDirection) {
            uniqueId |= bitMask;
            msg = await _repeatOnFailure(() => _mdu.binaryTreeSearch(i + 192));
            // TODO error handling
          } else {
            uniqueId &= ~bitMask;
            msg = await _repeatOnFailure(() => _mdu.binaryTreeSearch(i + 128));
            // TODO error handling
          }
        }

        // Found decoder
        final int decoderId = (uniqueId >> 32).toInt();
        final int serialNumber = uniqueId.toInt32().toInt();
        _addDecoder(
          decoderId,
          serialNumber,
        );

        lastDiscrepancy = lastZero;
        if (lastDiscrepancy == 0) lastDevice = true;
      }
    }
  }

  Future<Uint8List> _ping(int serialNumber, int decoderId) async {
    setState(() {
      _status = 'Ping';
      _progress = null;
    });
    final msg =
        await _repeatOnFailure(() => _mdu.ping(serialNumber, decoderId));
    // TODO error handling
    debugPrint('Ping $serialNumber $decoderId $msg');
    return msg;
  }

  Future<void> _salsa20IV(Uint8List iv) async {
    setState(() {
      _status = 'Salsa20 initialization';
    });
    final msg = await _repeatOnFailure(() => _mdu.firmwareSalsa20IV(iv));
    // TODO error handling
    debugPrint('Salsa20 $iv $msg');
  }

  Future<void> _erase(int beginAddress, int endAddress) async {
    setState(() {
      _status = 'Erasing';
    });
    final msg = await _repeatOnFailure(
      () => _mdu.firmwareErase(beginAddress, endAddress),
    );
    // TODO error handling}
    debugPrint('Erase $beginAddress $endAddress $msg');
  }

  Future<void> _write(Uint8List bin) async {
    int index = 0;
    while (index < bin.length) {
      final start = index;
      final end = index + 64;
      final chunk = bin.sublist(start, min(end, bin.length));
      final msg =
          await _repeatOnFailure(() => _mdu.firmwareUpdate(index, chunk));
      // Go either forward or back, depending on error
      if (msg[0] == MduService.nak && msg[1] == MduService.nak) {
        index += chunk.length;
      } else {
        debugPrint('going back...?');
        index = min(index - chunk.length, 0);
      }
      setState(() {
        final done = index ~/ 1024;
        final total = bin.length ~/ 1024;
        _status = 'Writing $done / $total kB';
        _progress = index / bin.length;
      });
    }
  }

  Future<void> _crc32Start(int beginAddress, int endAddress, int crc32) async {
    final msg = await _repeatOnFailure(
      () => _mdu.firmwareCrc32Start(beginAddress, endAddress, crc32),
    );
    // TODO error handling
    debugPrint('CRC32 start $beginAddress $endAddress $crc32 $msg');
  }

  Future<void> _crc32Result() async {
    final msg = await _repeatOnFailure(() => _mdu.firmwareCrc32Result());
    // TODO error handling
    debugPrint('CRC32 result $msg');
  }

  Future<void> _crc32ResultExit() async {
    final msg = await _repeatOnFailure(() => _mdu.firmwareCrc32ResultExit());
    // TODO error handling
    debugPrint('CRC32 result exit $msg');
  }

  Future<Uint8List> _repeatOnFailure(Future<Uint8List> Function() f) async {
    for (int i = 0; i < _repeat; i++) {
      final msg = await f();
      if (msg[0] == MduService.nak) return msg;
    }
    return Uint8List.fromList([MduService.ack, MduService.nak]);
  }

  void _addDecoder(int decoderId, int serialNumber) {
    //
    if (_zsu.entries.containsKey(decoderId)) {
      debugPrint('Found decoder $decoderId $serialNumber');
      setState(() {
        _updateableDecoders.update(
          decoderId,
          (Set<int> serialNumbers) => {...serialNumbers, serialNumber},
          ifAbsent: () => {serialNumber},
        );
        final String name = _zsu.entries[decoderId]!.name.substring(0, 7);
        final String count = _updateableDecoders[decoderId]!.length.toString();
        _decoderTiles[decoderId] = ListTile(
          title: Text('$name ($count)'),
          trailing: const Icon(Icons.circle_outlined),
        );
      });
    }
    //
    else {
      debugPrint('Found decoder unknown (or not part of .zsu)');
    }
  }
}
