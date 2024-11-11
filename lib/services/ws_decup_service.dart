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
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsDecupService implements DecupService {
  late final WebSocketChannel _channel;

  WsDecupService(String domain) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$domain/decup/zpp/'));
  }

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Uint8List> get stream => _channel.stream.cast<Uint8List>();

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  @override
  void preamble(int count) {
    // TODO: implement preamble
  }

  @override
  void startByte(int byte) {
    // TODO: implement startByte
  }

  @override
  void blockCount(int count) {
    // TODO: implement blockCount
  }

  @override
  void securityByte1() {
    // TODO: implement securityByte1
  }

  @override
  void securityByte2() {
    // TODO: implement securityByte2
  }

  @override
  void block(int count, Uint8List chunk) {
    // TODO: implement block
  }
}
