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

import 'dart:async';

import 'package:Frontend/constants/fake_initial_cvs.dart';
import 'package:Frontend/services/zusi_service.dart';
import 'package:Frontend/utilities/crc8.dart';
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
  void cvRead(int cvAddress) async {
    await Future.delayed(const Duration(milliseconds: 10), () {
      if (_controller.isClosed) return;
      _controller.sink.add(
        Uint8List.fromList(
          [
            ZusiService.ack,
            fakeInitialLocoCvs[cvAddress],
            crc8([fakeInitialLocoCvs[cvAddress]]),
          ],
        ),
      );
    });
  }

  @override
  void cvWrite(int cvAddress, int byte) async {
    await Future.delayed(const Duration(milliseconds: 10), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
    });
  }

  @override
  void zppErase() async {
    await Future.delayed(const Duration(seconds: 10), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
    });
  }

  @override
  void zppWrite(int address, Uint8List chunk) async {
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
  void exit({bool cv8Reset = false, bool restart = false}) async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
    });
  }

  @override
  void zppLcDcQuery(Uint8List developerCode) async {
    await Future.delayed(const Duration(milliseconds: 10), () {
      if (_controller.isClosed) return;
      _controller.sink.add(
        Uint8List.fromList(
          [
            ZusiService.ack,
            0x01,
            crc8([0x01]),
          ],
        ),
      );
    });
  }
}
