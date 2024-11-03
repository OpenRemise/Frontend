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

import 'package:Frontend/constants/ack.dart';
import 'package:Frontend/constants/nak.dart';
import 'package:Frontend/services/mdu_service.dart';
import 'package:flutter/foundation.dart';

class FakeMduService implements MduService {
  final _decoderIds = Set.of({
    0x06043202, // MS450-2
    0x09093201, // MS950-1
    0x7E031E00 | 0x00100000, // MN330-0
    0x7F015000 | 0x00100000, // MN180-0
  });
  final _controller = StreamController<Uint8List>();

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      Future.delayed(Duration.zero);

  @override
  void ping(int serialNumber, int decoderId) async {
    await Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(
          Uint8List.fromList(
            [nak, _decoderIds.contains(decoderId) ? ack : nak],
          ),
        );
      },
    );
  }

  @override
  void configTransferRate(int transferRate) async {
    await Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (_controller.isClosed) return;
        _controller.sink.add(
          Uint8List.fromList(
            [nak, transferRate < 3 ? ack : nak],
          ),
        );
      },
    );
  }

  @override
  void binaryTreeSearch(int byte) {
    throw UnimplementedError();
  }

  @override
  void busy() {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([nak, nak]));
  }

  @override
  void firmwareSalsa20IV(Uint8List iv) {
    assert(iv.length == 8);
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([nak, nak]));
  }

  @override
  void firmwareErase(int beginAddress, int endAddress) {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([nak, nak]));
  }

  @override
  void firmwareUpdate(int address, Uint8List chunk) async {
    assert(chunk.length == 64);
    await Future.delayed(const Duration(milliseconds: 5), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([nak, nak]));
    });
  }

  @override
  void firmwareCrc32Start(
    int beginAddress,
    int endAddress,
    int crc32,
  ) {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([nak, nak]));
  }

  @override
  void firmwareCrc32Result() {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([nak, nak]));
  }

  @override
  void firmwareCrc32ResultExit() {
    if (_controller.isClosed) return;
    _controller.sink.add(Uint8List.fromList([nak, nak]));
  }
}