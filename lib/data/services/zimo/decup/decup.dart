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
import 'package:Frontend/utils/exor.dart';

/// \todo document
sealed class DecupCommand {
  List<Uint8List> toUint8Lists();
}

/// \todo document
class ZsuPreamble extends DecupCommand {
  static int preambleCount = 0;

  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([(preambleCount++ % 2 == 0) ? 0xBF : 0xEF]),
    ];
  }
}

/// \todo document
class ZsuDecoderId extends DecupCommand {
  final int byte;

  ZsuDecoderId({required this.byte});

  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([byte]),
    ];
  }
}

/// \todo document
class ZsuBlockCount extends DecupCommand {
  final int count;

  ZsuBlockCount({required this.count});

  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([count]),
    ];
  }
}

/// \todo document
class ZsuSecurityByte1 extends DecupCommand {
  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([0x55]),
    ];
  }
}

/// \todo document
class ZsuSecurityByte2 extends DecupCommand {
  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([0xAA]),
    ];
  }
}

/// \todo document
class ZsuBlocks extends DecupCommand {
  final int count;
  final Uint8List chunk;

  ZsuBlocks({required this.count, required this.chunk}) {
    assert(chunk.length == 32 || chunk.length == 64);
  }

  @override
  List<Uint8List> toUint8Lists() {
    List<int> data = [count];
    data.addAll(chunk);
    data.add(exor(data));
    return [Uint8List.fromList(data)];
  }
}

/// \todo document
class ZppPreamble extends DecupCommand {
  static int preambleCount = 0;

  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([(preambleCount++ % 3 == 0) ? 0xBF : 0xEF]),
    ];
  }
}

/// \todo document
class ZppDecoderId extends DecupCommand {
  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([0x04]), // Bit 0
      Uint8List.fromList([0xFF]), // Bit 1
      Uint8List.fromList([0xFF]), // Bit 2
      Uint8List.fromList([0xFF]), // Bit 3
      Uint8List.fromList([0xFF]), // Bit 4
      Uint8List.fromList([0xFF]), // Bit 5
      Uint8List.fromList([0xFF]), // Bit 6
      Uint8List.fromList([0xFF]), // Bit 7
    ];
  }
}

/// \todo document
class ZppReadCv extends DecupCommand {
  final int cvAddress;

  ZppReadCv({required this.cvAddress});

  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([
        0x01, // Command
        (cvAddress >> 8) & 0xFF,
        (cvAddress >> 0) & 0xFF,
      ]), // Bit 0
      Uint8List.fromList([0xFF]), // Bit 1
      Uint8List.fromList([0xFF]), // Bit 2
      Uint8List.fromList([0xFF]), // Bit 3
      Uint8List.fromList([0xFF]), // Bit 4
      Uint8List.fromList([0xFF]), // Bit 5
      Uint8List.fromList([0xFF]), // Bit 6
      Uint8List.fromList([0xFF]), // Bit 7
    ];
  }
}

/// \todo document
class ZppWriteCv extends DecupCommand {
  final int cvAddress;
  final int value;

  ZppWriteCv({required this.cvAddress, required this.value});

  @override
  List<Uint8List> toUint8Lists() {
    List<int> data = [
      0x06, // Command
      0xAA,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      0x00, // CRC placeholder
      value & 0xFF,
    ];
    data[4] = crc8([data[2], data[3], data[5]]);
    return [Uint8List.fromList(data)];
  }
}

/// \todo document
class ZppErase extends DecupCommand {
  @override
  List<Uint8List> toUint8Lists() {
    return [
      Uint8List.fromList([0x03, 0x55, 0xFF, 0xFF]),
    ];
  }
}

/// \todo document
class ZppBlocks extends DecupCommand {
  final int count;
  final Uint8List chunk;

  ZppBlocks({required this.count, required this.chunk}) {
    assert(chunk.length == 256);
  }

  @override
  List<Uint8List> toUint8Lists() {
    List<int> data = [
      0x05, // Command
      0x55,
      (count >> 8) & 0xFF,
      (count >> 0) & 0xFF,
    ];
    data.addAll(chunk);
    data.add(crc8(data.sublist(2), 0x55));
    return [Uint8List.fromList(data)];
  }
}

/// \todo document
abstract interface class DecupService {
  static const int ack = 0x1C;
  static const int nak = 0xFC;
  int? get closeCode;
  String? get closeReason;
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void call(DecupCommand command);
}
