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

import 'package:Frontend/data/services/ota/ota.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeOtaService implements OtaService {
  final ProviderContainer ref;
  final _controller = StreamController<Uint8List>();

  FakeOtaService(this.ref) {
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
  void call(OtaCommand command) {
    if (_controller.isClosed) return;

    switch (command) {
      case Write():
        Future.delayed(const Duration(milliseconds: 50), () {
          if (_controller.isClosed) return;
          _controller.sink.add(Uint8List.fromList([OtaService.ack]));
        });
        break;
    }
  }
}
