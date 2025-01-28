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

import 'package:Frontend/services/decup_service.dart';
import 'package:Frontend/utilities/crc8.dart';
import 'package:Frontend/utilities/exor.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsDecupService implements DecupService {
  late final WebSocketChannel _channel;
  int preambleCount = 0;

  WsDecupService(String domain, String unencodedPath) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://$domain/decup/$unencodedPath'),
    );
  }

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Uint8List> get stream => _channel.stream.cast<Uint8List>();

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  @override
  void zppPreamble() {
    _channel.sink.add(
      Uint8List.fromList([(preambleCount++ % 3 == 0) ? 0xBF : 0xEF]),
    );
  }

  @override
  void zppDecoderId() {
    _channel.sink.add(Uint8List.fromList([0x04])); // Bit 0
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 1
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 2
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 3
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 4
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 5
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 6
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 7
  }

  @override
  void zppReadCv(int cvAddress) {
    List<int> data = [
      0x01, // Command
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
    ];
    _channel.sink.add(Uint8List.fromList(data)); // Bit 0
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 1
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 2
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 3
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 4
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 5
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 6
    _channel.sink.add(Uint8List.fromList([0xFF])); // Bit 7
  }

  @override
  void zppWriteCv(int cvAddress, int byte) {
    List<int> data = [
      0x06, // Command
      0xAA,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      0x00, // CRC placeholder
      byte & 0xFF,
    ];
    data[4] = crc8([data[2], data[3], data[5]]);
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void zppErase() {
    _channel.sink.add(
      Uint8List.fromList([0x03, 0x55, 0xFF, 0xFF]),
    );
  }

  @override
  void zppBlocks(int count, Uint8List chunk) {
    assert(chunk.length == 256);
    List<int> data = [
      0x05, // Command
      0x55,
      (count >> 8) & 0xFF,
      (count >> 0) & 0xFF,
    ];
    data.addAll(chunk);
    data.add(crc8(data.sublist(2), 0x55));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void zsuPreamble() {
    _channel.sink.add(
      Uint8List.fromList([(preambleCount++ % 2 == 0) ? 0xBF : 0xEF]),
    );
  }

  @override
  void zsuDecoderId(int byte) {
    _channel.sink.add(Uint8List.fromList([byte]));
  }

  @override
  void zsuBlockCount(int count) {
    _channel.sink.add(Uint8List.fromList([count]));
  }

  @override
  void zsuSecurityByte1() {
    _channel.sink.add(Uint8List.fromList([0x55]));
  }

  @override
  void zsuSecurityByte2() {
    _channel.sink.add(Uint8List.fromList([0xAA]));
  }

  @override
  void zsuBlocks(int count, Uint8List chunk) {
    assert(chunk.length == 32 || chunk.length == 64);
    List<int> data = [count];
    data.addAll(chunk);
    data.add(exor(data));
    _channel.sink.add(Uint8List.fromList(data));
  }
}
