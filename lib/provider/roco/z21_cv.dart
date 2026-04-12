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

import 'dart:collection';

import 'package:Frontend/model/config.dart';
import 'package:Frontend/model/decoder.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/provider/settings.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_cv.g.dart';

typedef CvKey = (int, int, int);
typedef CvMap = Map<CvKey, Z21Command?>;

/// \todo document
@riverpod
class Z21Cv extends _$Z21Cv {
  final Queue<Z21Command> _queue = Queue();
  late final Z21Service _z21;
  late final Decoder _decoder;
  Z21Command? _active;
  int? _cv31 = 0;
  int? _cv32 = 1;

  /// \todo document
  @override
  CvMap build(Decoder decoder) {
    _z21 = ref.read(z21ServiceProvider);
    final sub = _z21.stream
        .where(
          (command) => switch (command) {
            LanXCvNackSc() => true,
            LanXCvNack() => true,
            LanXCvResult() => true,
            _ => false
          },
        )
        .listen(response);
    ref.onDispose(() {
      sub.cancel();
    });
    _decoder = decoder;
    return {};
  }

  /// \todo document
  void read(int cvAddress) {
    _queue.addLast(
      _decoder.address == null
          ? LanXCvRead(cvAddress: cvAddress)
          : _decoder.type == Loco
              ? LanXCvPomReadByte(
                  locoAddress: _decoder.address!,
                  cvAddress: cvAddress,
                )
              : LanXCvPomAccessoryReadByte(
                  accyAddress: _decoder.address!,
                  cvAddress: cvAddress,
                ),
    );
    _execute();
  }

  /// \todo document
  void write(int cvAddress, int value) {
    _queue.addLast(
      _decoder.address == null
          ? LanXCvWrite(cvAddress: cvAddress, value: value)
          : _decoder.type == Loco
              ? LanXCvPomWriteByte(
                  locoAddress: _decoder.address!,
                  cvAddress: cvAddress,
                  value: value,
                )
              : LanXCvPomAccessoryWriteByte(
                  accyAddress: _decoder.address!,
                  cvAddress: cvAddress,
                  value: value,
                ),
    );
    _execute();
  }

  /// \todo document
  void response(Z21Command command) {
    if (_active == null) return;
    state = {
      ...state,
      ((_active as dynamic).cvAddress, _cv31!, _cv32!): command,
    };
    _active = null;
    _execute();
  }

  /// \todo document
  Future<void> _execute() async {
    if (_active != null || _queue.isEmpty) return;
    _active = _queue.removeFirst();
    final int cvAddress = (_active as dynamic).cvAddress;
    state = {...state, (cvAddress, _cv31!, _cv32!): null};
    _z21(_active!);

    //
    if (_active is LanXCvPomWriteByte ||
        _active is LanXCvPomAccessoryWriteByte) {
      final int value = (_active as dynamic).value;
      state = {
        ...state,
        (cvAddress, _cv31!, _cv32!):
            LanXCvResult(cvAddress: cvAddress, value: value),
      };

      // Throttle
      final progCount = ref.read(
        settingsProvider.select(
          (config) =>
              config.value?.dccProgramPacketCount ??
              Config().dccProgramPacketCount,
        ),
      );
      await Future.delayed(Duration(milliseconds: 20 * progCount));
      _active = null;
      _execute();
    }
  }
}
