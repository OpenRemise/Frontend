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

import 'package:Frontend/constant/zimo/mx_decoder_ids.dart';
import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/service/zimo/decup_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeDecupService implements DecupService {
  final ProviderContainer ref;

  /// Random ID
  final _decoderId = () {
    final shuffledIds = mxDecoderIds.toList();
    shuffledIds.shuffle();
    return shuffledIds.first;
  }();
  final _controller = StreamController<Uint8List>();

  FakeDecupService(this.ref) {
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
  void call(DecupCommand command) {
    if (_controller.isClosed) return;

    switch (command) {
      case ZppPreamble():
        Future.delayed(
          const Duration(milliseconds: 25),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(Uint8List.fromList([]));
          },
        );
        break;

      case ZppDecoderId():
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            if (_controller.isClosed) return;
            for (int i = 0; i < 8; ++i) {
              _controller.sink.add(
                Uint8List.fromList(
                  [
                    _decoderId & (1 << i) > 0
                        ? DecupService.ack
                        : DecupService.nak,
                  ],
                ),
              );
            }
          },
        );
        break;

      case ZppReadCv():
        throw UnimplementedError();

      case ZppWriteCv():
        Future.delayed(
          const Duration(milliseconds: 50),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(Uint8List.fromList([DecupService.ack]));
          },
        );
        break;

      case ZppErase():
        Future.delayed(
          const Duration(seconds: 10),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(Uint8List.fromList([DecupService.nak]));
          },
        );
        break;

      case ZppBlocks(chunk: final chunk):
        Future.delayed(
          Duration(milliseconds: 10 * chunk.length),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(Uint8List.fromList([DecupService.ack]));
          },
        );
        break;

      case ZsuPreamble():
        Future.delayed(
          const Duration(milliseconds: 25),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(Uint8List.fromList([]));
          },
        );
        break;

      case ZsuDecoderId(byte: final byte):
        _controller.sink.add(
          Uint8List.fromList(
            byte == _decoderId ? [DecupService.ack] : [],
          ),
        );
        break;

      case ZsuBlockCount():
        _controller.sink.add(Uint8List.fromList([DecupService.nak]));
        break;

      case ZsuSecurityByte1():
        _controller.sink.add(Uint8List.fromList([DecupService.nak]));
        break;

      case ZsuSecurityByte2():
        _controller.sink.add(Uint8List.fromList([DecupService.nak]));
        break;

      case ZsuBlocks(chunk: final chunk):
        Future.delayed(
          Duration(milliseconds: 50 * chunk.length),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(Uint8List.fromList([DecupService.ack]));
          },
        );
        break;
    }
  }
}
