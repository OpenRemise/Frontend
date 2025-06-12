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
import 'package:Frontend/constants/mx_decoder_ids.dart';
import 'package:Frontend/services/zimo/decup_service.dart';
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
  int? get closeCode => _controller.isClosed ? 1005 : null;

  @override
  String? get closeReason => closeCode != null ? 'Timeout' : null;

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _controller.sink.close();

  @override
  void zppPreamble() async {
    await Future.delayed(
      const Duration(milliseconds: 25),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList([]));
      },
    );
  }

  @override
  void zppDecoderId() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (_controller.isClosed) return;
        for (var i = 0; i < 8; ++i) {
          _controller.sink.add(
            Uint8List.fromList(
              [_decoderId & (1 << i) > 0 ? DecupService.ack : DecupService.nak],
            ),
          );
        }
      },
    );
  }

  @override
  void zppReadCv(int cvAddress) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (_controller.isClosed) return;
        final cv = fakeInitialLocoCvs[cvAddress];
        for (var i = 0; i < 8; ++i) {
          _controller.sink.add(
            Uint8List.fromList(
              [cv & (1 << i) > 0 ? DecupService.ack : DecupService.nak],
            ),
          );
        }
      },
    );
  }

  @override
  void zppWriteCv(int cvAddress, int byte) async {
    await Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList([DecupService.ack]));
      },
    );
  }

  @override
  void zppErase() async {
    await Future.delayed(
      const Duration(seconds: 10),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList([]));
      },
    );
  }

  @override
  void zppBlocks(int count, Uint8List chunk) async {
    assert(chunk.length == 256);
    await Future.delayed(
      Duration(milliseconds: 10 * chunk.length),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList([DecupService.ack]));
      },
    );
  }

  @override
  void zsuPreamble() async {
    await Future.delayed(
      const Duration(milliseconds: 25),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList([]));
      },
    );
  }

  @override
  void zsuDecoderId(int byte) {
    if (_controller.isClosed) return;
    _controller.sink.add(
      Uint8List.fromList(
        byte == _decoderId ? [DecupService.ack] : [],
      ),
    );
  }

  @override
  void zsuBlockCount(int count) {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([DecupService.nak]));
  }

  @override
  void zsuSecurityByte1() {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([DecupService.nak]));
  }

  @override
  void zsuSecurityByte2() {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([DecupService.nak]));
  }

  @override
  void zsuBlocks(int count, Uint8List chunk) async {
    assert(chunk.length == 32 || chunk.length == 64);
    await Future.delayed(
      Duration(milliseconds: 50 * chunk.length),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(Uint8List.fromList([DecupService.ack]));
      },
    );
  }
}
