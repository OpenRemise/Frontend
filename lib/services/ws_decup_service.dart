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

import 'dart:async';

import 'package:Frontend/services/decup_service.dart';
import 'package:Frontend/utilities/exor.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsDecupService implements DecupService {
  late final WebSocketChannel _channel;
  bool preambleToggle = false;

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
  void preamble() {
    _channel.sink.add(
      Uint8List.fromList([(preambleToggle = !preambleToggle) ? 0xEF : 0xBF]),
    );
  }

  @override
  void startByte(int byte) {
    _channel.sink.add(Uint8List.fromList([byte]));
  }

  @override
  void blockCount(int count) {
    _channel.sink.add(Uint8List.fromList([count]));
  }

  @override
  void securityByte1() {
    _channel.sink.add(Uint8List.fromList([0x55]));
  }

  @override
  void securityByte2() {
    _channel.sink.add(Uint8List.fromList([0xAA]));
  }

  @override
  void block(int count, Uint8List chunk) {
    assert(chunk.length == 32 || chunk.length == 64);
    List<int> data = [count];
    data.addAll(chunk);
    data.add(exor(data));
    _channel.sink.add(Uint8List.fromList(data));
  }
}
