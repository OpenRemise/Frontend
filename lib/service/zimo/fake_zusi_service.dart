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

import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/service/zimo/zusi_service.dart';
import 'package:Frontend/utility/crc8.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeZusiService implements ZusiService {
  final ProviderContainer ref;
  final _controller = StreamController<Uint8List>();

  FakeZusiService(this.ref) {
    ref.read(z21ServiceProvider)(LanXBcProgrammingMode());
  }

  @override
  int? get closeCode => _controller.isClosed ? 1005 : null;

  @override
  String? get closeReason => closeCode != null ? 'Timeout' : null;

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) {
    ref.read(z21ServiceProvider)(LanXBcTrackPowerOn());
    ref.read(z21ServiceProvider)(LanXBcTrackPowerOff());
    return _controller.sink.close();
  }

  @override
  void call(ZusiCommand command) {
    if (_controller.isClosed) return;

    switch (command) {
      case CvRead():
        throw UnimplementedError();

      case CvWrite():
        Future.delayed(const Duration(milliseconds: 10), () {
          if (_controller.isClosed) return;
          _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
        });
        break;

      case ZppErase():
        Future.delayed(const Duration(seconds: 10), () {
          if (_controller.isClosed) return;
          _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
        });
        break;

      case ZppWrite(chunk: final chunk):
        Future.delayed(Duration(milliseconds: 2 * chunk.length), () {
          if (_controller.isClosed) return;
          _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
        });
        break;

      case Features():
        Future.delayed(const Duration(seconds: 2), () {
          if (_controller.isClosed) return;
          _controller.sink
              .add(Uint8List.fromList([6, 251, 255, 255, 127, 147]));
        });
        break;

      case Exit():
        Future.delayed(const Duration(seconds: 2), () {
          if (_controller.isClosed) return;
          _controller.sink.add(Uint8List.fromList([ZusiService.ack]));
        });
        break;

      case ZppLcDcQuery():
        Future.delayed(const Duration(milliseconds: 10), () {
          if (_controller.isClosed) return;
          _controller.sink.add(
            Uint8List.fromList([
              ZusiService.ack,
              0x01,
              crc8([0x01]),
            ]),
          );
        });
        break;
    }
  }
}
