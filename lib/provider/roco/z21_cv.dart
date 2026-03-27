// Copyright (C) 2026 Vincent Hamp
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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_cv.g.dart';

/// \todo document
@riverpod
class Z21Cv extends _$Z21Cv {
  late final Z21Service _z21;
  late final StreamSubscription _sub;

  /// \todo document
  @override
  List<int> build() {
    _z21 = ref.read(z21ServiceProvider);
    _sub = _z21.stream
        .where(
          (command) => switch (command) {
            LanXCvNackSc() => true,
            LanXCvNack() => true,
            LanXCvResult() => true,
            _ => false
          },
        )
        .listen(
          (event) {},
        );
    ref.onDispose(() {
      _sub.cancel();
    });
    return [ ] ;
  }

  /// \todo document
  void lanXCvRead(int cvAddress) {
    _z21.lanXCvRead(cvAddress);
  }

  /// \todo document
  void lanXCvWrite(int cvAddress, int byte) {
    _z21.lanXCvWrite(cvAddress, byte);
  }

  /// \todo document
  void lanXCvPomWriteByte(int locoAddress, int cvAddress, int byte) {
    _z21.lanXCvPomWriteByte(locoAddress, cvAddress, byte);
  }

  /// \todo document
  void lanXCvPomReadByte(int locoAddress, int cvAddress) {
    _z21.lanXCvPomReadByte(locoAddress, cvAddress);
  }

  /// \todo document
  void lanXCvPomAccessoryWriteByte(int accyAddress, int cvAddress, int byte) {
    _z21.lanXCvPomAccessoryWriteByte(accyAddress, cvAddress, byte);
  }

  /// \todo document
  void lanXCvPomAccessoryReadByte(int accyAddress, int cvAddress) {
    _z21.lanXCvPomAccessoryReadByte(accyAddress, cvAddress);
  }
}
