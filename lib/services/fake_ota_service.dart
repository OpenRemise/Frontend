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

import 'package:Frontend/services/ota_service.dart';
import 'package:flutter/foundation.dart';

class FakeOtaService implements OtaService {
  final _controller = StreamController<Uint8List>();

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _controller.sink.close();

  @override
  void write(Uint8List chunk) async {
    await Future.delayed(const Duration(milliseconds: 50), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([OtaService.ack]));
    });
  }
}
