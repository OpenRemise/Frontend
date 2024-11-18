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

import 'package:Frontend/services/mdu_service.dart';
import 'package:Frontend/utilities/crc32.dart';
import 'package:Frontend/utilities/crc8.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsMduService implements MduService {
  late final WebSocketChannel _channel;

  WsMduService(String domain, String unencodedPath) {
    _channel =
        WebSocketChannel.connect(Uri.parse('ws://$domain/mdu/$unencodedPath'));
  }

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Uint8List> get stream => _channel.stream.cast<Uint8List>();

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  @override
  void ping(int serialNumber, int decoderId) {
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
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void configTransferRate(int transferRate) {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFE,
      transferRate & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void binaryTreeSearch(int byte) {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFA,
      byte & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void busy() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF2,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void firmwareSalsa20IV(Uint8List iv) {
    assert(iv.length == 8);
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF7,
    ];
    data.addAll(iv);
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void firmwareErase(int beginAddress, int endAddress) {
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
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void firmwareUpdate(int address, Uint8List chunk) {
    assert(chunk.length == 64);
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
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void firmwareCrc32Start(int beginAddress, int endAddress, int crc32) {
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
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void firmwareCrc32Result() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFC,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void firmwareCrc32ResultExit() {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFD,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }
}
