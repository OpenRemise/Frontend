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

import 'dart:convert';
import 'dart:typed_data';

import 'package:Frontend/utils/crc32.dart';
import 'package:Frontend/utils/crc8.dart';

/// \todo document
sealed class MduCommand {
  Uint8List toUint8List();
}

/// \todo document
class Ping extends MduCommand {
  final int serialNumber;
  final int decoderId;

  Ping({required this.serialNumber, required this.decoderId});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFF,
      (serialNumber >> 24) & 0xFF,
      (serialNumber >> 16) & 0xFF,
      (serialNumber >> 8) & 0xFF,
      (serialNumber >> 0) & 0xFF,
      (decoderId >> 24) & 0xFF,
      (decoderId >> 16) & 0xFF,
      (decoderId >> 8) & 0xFF,
      (decoderId >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ConfigTransferRate extends MduCommand {
  final int transferRate;

  ConfigTransferRate({required this.transferRate});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFE,
      transferRate & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class BinaryTreeSearch extends MduCommand {
  final int byte;

  BinaryTreeSearch({required this.byte});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFA,
      byte & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class Busy extends MduCommand {
  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF2,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppValidQuery extends MduCommand {
  final String id;
  final int flashSize;

  ZppValidQuery({required this.id, required this.flashSize}) {
    assert(id.length == 2);
  }

  @override
  Uint8List toUint8List() {
    final tmp = const AsciiEncoder().convert(id);
    assert(tmp.length == 2);
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0x06,
      tmp[0],
      tmp[1],
      (flashSize >> 24) & 0xFF,
      (flashSize >> 16) & 0xFF,
      (flashSize >> 8) & 0xFF,
      (flashSize >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppLcDcQuery extends MduCommand {
  final Uint8List developerCode;

  ZppLcDcQuery({required this.developerCode}) {
    assert(developerCode.length == 4);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0x07,
    ];
    data.addAll(developerCode);
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppErase extends MduCommand {
  final int beginAddress;
  final int endAddress;

  ZppErase({required this.beginAddress, required this.endAddress});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0x05,
      (beginAddress >> 24) & 0xFF,
      (beginAddress >> 16) & 0xFF,
      (beginAddress >> 8) & 0xFF,
      (beginAddress >> 0) & 0xFF,
      (endAddress >> 24) & 0xFF,
      (endAddress >> 16) & 0xFF,
      (endAddress >> 8) & 0xFF,
      (endAddress >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppUpdate extends MduCommand {
  final int address;
  final Uint8List chunk;

  ZppUpdate({required this.address, required this.chunk}) {
    assert(chunk.length == 256);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0x08,
      (address >> 24) & 0xFF,
      (address >> 16) & 0xFF,
      (address >> 8) & 0xFF,
      (address >> 0) & 0xFF,
    ];
    data.addAll(chunk);
    final int crc = crc32(data);
    data.addAll([
      (crc >> 24) & 0xFF,
      (crc >> 16) & 0xFF,
      (crc >> 8) & 0xFF,
      (crc >> 0) & 0xFF,
    ]);
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppUpdateEnd extends MduCommand {
  final int beginAddress;
  final int endAddress;

  ZppUpdateEnd({required this.beginAddress, required this.endAddress});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0x0B,
      (beginAddress >> 24) & 0xFF,
      (beginAddress >> 16) & 0xFF,
      (beginAddress >> 8) & 0xFF,
      (beginAddress >> 0) & 0xFF,
      (endAddress >> 24) & 0xFF,
      (endAddress >> 16) & 0xFF,
      (endAddress >> 8) & 0xFF,
      (endAddress >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppExit extends MduCommand {
  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0x0C,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppExitReset extends MduCommand {
  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0x0D,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZsuSalsa20IV extends MduCommand {
  final Uint8List iv;

  ZsuSalsa20IV({required this.iv}) {
    assert(iv.length == 8);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF7,
    ];
    data.addAll(iv);
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZsuErase extends MduCommand {
  final int beginAddress;
  final int endAddress;

  ZsuErase({required this.beginAddress, required this.endAddress});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF5,
      (beginAddress >> 24) & 0xFF,
      (beginAddress >> 16) & 0xFF,
      (beginAddress >> 8) & 0xFF,
      (beginAddress >> 0) & 0xFF,
      (endAddress >> 24) & 0xFF,
      (endAddress >> 16) & 0xFF,
      (endAddress >> 8) & 0xFF,
      (endAddress >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZsuUpdate extends MduCommand {
  final int address;
  final Uint8List chunk;

  ZsuUpdate({required this.address, required this.chunk}) {
    assert(chunk.length == 64);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF8,
      (address >> 24) & 0xFF,
      (address >> 16) & 0xFF,
      (address >> 8) & 0xFF,
      (address >> 0) & 0xFF,
    ];
    data.addAll(chunk);
    final int crc = crc32(data);
    data.addAll([
      (crc >> 24) & 0xFF,
      (crc >> 16) & 0xFF,
      (crc >> 8) & 0xFF,
      (crc >> 0) & 0xFF,
    ]);
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZsuCrc32Start extends MduCommand {
  final int beginAddress;
  final int endAddress;
  final int crc32;

  ZsuCrc32Start(
      {required this.beginAddress,
      required this.endAddress,
      required this.crc32});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFB,
      (beginAddress >> 24) & 0xFF,
      (beginAddress >> 16) & 0xFF,
      (beginAddress >> 8) & 0xFF,
      (beginAddress >> 0) & 0xFF,
      (endAddress >> 24) & 0xFF,
      (endAddress >> 16) & 0xFF,
      (endAddress >> 8) & 0xFF,
      (endAddress >> 0) & 0xFF,
      (crc32 >> 24) & 0xFF,
      (crc32 >> 16) & 0xFF,
      (crc32 >> 8) & 0xFF,
      (crc32 >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZsuCrc32Result extends MduCommand {
  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFC,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZsuCrc32ResultExit extends MduCommand {
  @override
  Uint8List toUint8List() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFD,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

abstract interface class MduService {
  static const int ack = 0x06;
  static const int nak = 0x15;
  int? get closeCode;
  String? get closeReason;
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void call(MduCommand command);
}
