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

import 'package:Frontend/constants/mx_decoder_ids.dart';
import 'package:Frontend/services/decup_service.dart';
import 'package:flutter/foundation.dart';

class FakeDecupService implements DecupService {
  /// Random ID
  final _decoderId = () {
    final shuffledIds = mxDecoderIds.toList();
    shuffledIds.shuffle();
    return shuffledIds.first;
  }();
  final _controller = StreamController<Uint8List>();

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _controller.sink.close();

  @override
  void preamble() async {
    await Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList(List.empty()));
      },
    );
  }

  @override
  void startByte(int byte) {
    if (_controller.isClosed) return;
    _controller.sink.add(
      Uint8List.fromList(
        byte == _decoderId ? [DecupService.ack] : List.empty(),
      ),
    );
  }

  @override
  void blockCount(int count) {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([DecupService.ack]));
  }

  @override
  void securityByte1() {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([DecupService.ack]));
  }

  @override
  void securityByte2() {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([DecupService.ack]));
  }

  @override
  void block(int count, Uint8List chunk) async {
    assert(chunk.length == 32 || chunk.length == 64);
    await Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList([DecupService.ack]));
      },
    );
  }
}
