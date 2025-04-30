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

import 'package:Frontend/services/zusi_service.dart';
import 'package:Frontend/utilities/crc8.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsZusiService implements ZusiService {
  late final WebSocketChannel _channel;
  late final Stream<Uint8List> _stream;

  WsZusiService(String domain) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$domain/zusi/'));
    _stream = _channel.stream.asBroadcastStream().cast<Uint8List>();
  }

  @override
  int? get closeCode => _channel.closeCode;

  @override
  String? get closeReason => closeCode != null ? 'Timeout' : null;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Uint8List> get stream => _stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  @override
  void cvRead(int cvAddress) {
    List<int> data = [
      0x01, // Command
      0x00, // Count
      (cvAddress >> 24) & 0xFF, // CV address
      (cvAddress >> 16) & 0xFF,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void cvWrite(int cvAddress, int byte) {
    List<int> data = [
      0x02, // Command
      0x00, // Count
      (cvAddress >> 24) & 0xFF, // CV address
      (cvAddress >> 16) & 0xFF,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      byte & 0xFF, // CV value
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void zppErase() {
    List<int> data = [
      0x04, // Command
      0x55,
      0xAA,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void zppWrite(int address, Uint8List chunk) {
    assert(chunk.length <= 256);
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
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void features() {
    List<int> data = [
      0x06, // Command
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void exit({bool cv8Reset = false, bool restart = false}) {
    List<int> data = [
      0x07, // Command
      0x55,
      0xAA,
      0xFC | (cv8Reset ? 0 : 1) << 1 | (restart ? 0 : 1) << 0,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void zppLcDcQuery(Uint8List developerCode) {
    assert(developerCode.length == 4);
    List<int> data = [
      0x0D, // Command
    ];
    data.addAll(developerCode);
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
  }
}
