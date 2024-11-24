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

import 'package:Frontend/services/zusi_service.dart';
import 'package:flutter/foundation.dart';

class FakeZusiService implements ZusiService {
  final _controller = StreamController<Uint8List>();

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      Future.delayed(Duration.zero);

  @override
  void readCv(int address) {
    // TODO: implement readCv
    throw UnimplementedError();
  }

  @override
  void writeCv(int address, int value) {
    // TODO: implement writeCv
    throw UnimplementedError();
  }

  @override
  void eraseZpp() async {
    await Future.delayed(const Duration(seconds: 10), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
    });
  }

  @override
  void writeZpp(int address, Uint8List chunk) async {
    await Future.delayed(Duration(milliseconds: 2 * chunk.length), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
    });
  }

  @override
  void features() async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([6, 251, 255, 255, 127, 147]));
    });
  }

  @override
  void exit(int flags) async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
    });
  }

  @override
  void encrypt() {
    // TODO: implement encrypt
    throw UnimplementedError();
  }
}
