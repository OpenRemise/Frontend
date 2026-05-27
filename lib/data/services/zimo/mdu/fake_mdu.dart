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
import 'dart:math';

import 'package:Frontend/data/services/roco/provider.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/data/services/zimo/mdu/mdu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeMduService implements MduService {
  final ProviderContainer ref;

  final _controller = StreamController<Uint8List>();

  /// Up to 3 random IDs
  final _decoderIds = () {
    final shuffledIds = Set.unmodifiable({
      0x7C114600,
      0x7F115000,
      0x7D130000,
      0x7E131E00,
      0x7B132800,
      0x04042800,
      0x06043200,
      0x02045000,
      0x03045A00,
      0x0C045B00,
      0x01050000,
      0x0A053C00,
      0x05055000,
      0x0D055100,
      0x08055A00,
      0x09093200,
      0x07095A00,
      0x04042801,
      0x06043201,
      0x02045001,
      0x03045A01,
      0x01050001,
      0x0A053C01,
      0x05055001,
      0x08055A01,
      0x09093201,
      0x07095A01,
      0x04042802,
      0x06043202,
      0x02045002,
      0x03045A02,
      0x01050002,
      0x0A053C02,
      0x05055002,
      0x08055A02,
      0x09093202,
      0x07095A02,
      0x06043203,
      0x0B000100,
      0x0B000101,
    }).toList();
    shuffledIds.shuffle();
    return shuffledIds.sublist(0, Random().nextInt(3) + 1);
  }();

  FakeMduService(this.ref) {
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
  void call(MduCommand command) {
    if (_controller.isClosed) return;

    switch (command) {
      case Ping(decoderId: final decoderId):
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(
              Uint8List.fromList(
                [
                  MduService.nak,
                  _decoderIds.contains(decoderId)
                      ? MduService.ack
                      : MduService.nak,
                ],
              ),
            );
          },
        );
        break;

      case ConfigTransferRate(transferRate: final transferRate):
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(
              Uint8List.fromList(
                [
                  MduService.nak,
                  transferRate < 3 ? MduService.ack : MduService.nak,
                ],
              ),
            );
          },
        );
        break;

      case BinaryTreeSearch():
        throw UnimplementedError();

      case Busy():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZppValidQuery():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZppLcDcQuery():
        Future.delayed(const Duration(milliseconds: 50), () {
          if (_controller.isClosed) return;
          _controller.sink
              .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        });
        break;

      case ZppErase():
        Future.delayed(const Duration(seconds: 20), () {
          if (_controller.isClosed) return;
          _controller.sink
              .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        });
        break;

      case ZppUpdate(chunk: final chunk):
        Future.delayed(Duration(milliseconds: 10 * chunk.length), () {
          if (_controller.isClosed) return;
          _controller.sink
              .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        });
        break;

      case ZppUpdateEnd():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZppExit():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZppExitReset():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZsuSalsa20IV():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZsuErase():
        Future.delayed(const Duration(milliseconds: 5), () {
          if (_controller.isClosed) return;
          _controller.sink
              .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        });
        break;

      case ZsuUpdate(chunk: final chunk):
        Future.delayed(Duration(milliseconds: 20 * chunk.length), () {
          if (_controller.isClosed) return;
          _controller.sink
              .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        });
        break;

      case ZsuCrc32Start():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZsuCrc32Result():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;

      case ZsuCrc32ResultExit():
        _controller.sink
            .add(Uint8List.fromList([MduService.nak, MduService.nak]));
        break;
    }
  }
}
