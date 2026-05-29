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

import 'dart:typed_data';

import 'package:Frontend/utils/crc8.dart';

/// \todo document
sealed class ZusiCommand {
  Uint8List toUint8List();
}

/// \todo document
class CvRead extends ZusiCommand {
  final int cvAddress;

  CvRead({required this.cvAddress});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x01, // Command
      0x00, // Count
      (cvAddress >> 24) & 0xFF, // CV address
      (cvAddress >> 16) & 0xFF,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class CvWrite extends ZusiCommand {
  final int cvAddress;
  final int value;

  CvWrite({required this.cvAddress, required this.value});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x02, // Command
      0x00, // Count
      (cvAddress >> 24) & 0xFF, // CV address
      (cvAddress >> 16) & 0xFF,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      value & 0xFF, // CV value
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppErase extends ZusiCommand {
  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x04, // Command
      0x55,
      0xAA,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppWrite extends ZusiCommand {
  final int address;
  final Uint8List chunk;

  ZppWrite({required this.address, required this.chunk}) {
    assert(chunk.isNotEmpty && chunk.length <= 256);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x05, // Command
      chunk.length - 1, // Count
      (address >> 24) & 0xFF, // Address
      (address >> 16) & 0xFF,
      (address >> 8) & 0xFF,
      (address >> 0) & 0xFF,
    ];
    data.addAll(chunk);
    data.addAll(List<int>.filled(263 - 1 - data.length, 0xFF));
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class Features extends ZusiCommand {
  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x06, // Command
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class Exit extends ZusiCommand {
  final bool cv8Reset;
  final bool restart;

  Exit({this.cv8Reset = false, this.restart = false});

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x07, // Command
      0x55,
      0xAA,
      0xFC | (cv8Reset ? 0 : 1) << 1 | (restart ? 0 : 1) << 0,
    ];
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
class ZppLcDcQuery extends ZusiCommand {
  final Uint8List developerCode;

  ZppLcDcQuery({required this.developerCode}) {
    assert(developerCode.length == 4);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x0D, // Command
    ];
    data.addAll(developerCode);
    data.add(crc8(data));
    return Uint8List.fromList(data);
  }
}

/// \todo document
abstract interface class ZusiService {
  static const int ack = 0x06;
  static const int nak = 0x15;
  int? get closeCode;
  String? get closeReason;
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void call(ZusiCommand command);
}
