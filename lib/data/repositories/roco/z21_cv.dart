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
import 'dart:collection';

import 'package:Frontend/data/repositories/settings.dart';
import 'package:Frontend/data/services/roco/provider.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/domain/models/config.dart';
import 'package:Frontend/domain/models/decoder.dart';
import 'package:Frontend/domain/models/loco.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_cv.g.dart';

typedef CvKey = (int, int, int);
typedef CvMap = Map<CvKey, Z21Command?>;

/// \todo document
@Riverpod(keepAlive: true)
class Z21Cv extends _$Z21Cv {
  final Queue<(Z21Command, Completer<Z21Command>)> _queue = Queue();
  late final Z21Service _z21;
  late final Decoder _decoder;
  (Z21Command, Completer<Z21Command>)? _active;
  final int _cv31 = 0;
  final int _cv32 = 1;

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
  Future<Z21Command> read(int cvAddress) {
    final completer = Completer<Z21Command>();
    _queue.addLast(
      (
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
        completer,
      ),
    );
    _execute();
    return completer.future;
  }

  /// \todo document
  Future<Z21Command> write(int cvAddress, int value) {
    final completer = Completer<Z21Command>();
    _queue.addLast(
      (
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
        completer,
      ),
    );
    _execute();
    return completer.future;
  }

  /// \todo document
  void response(Z21Command command) {
    if (_active == null) return;
    final (cmd, completer) = _active!;
    state = {
      ...state,
      ((cmd as dynamic).cvAddress, _cv31, _cv32): command,
    };
    completer.complete(command);
    _active = null;
    _execute();
  }

  /// \todo document
  Future<void> _execute() async {
    if (_active != null || _queue.isEmpty) return;
    _active = _queue.removeFirst();
    final (cmd, completer) = _active!;
    final int cvAddress = (cmd as dynamic).cvAddress;
    state = {...state, (cvAddress, _cv31, _cv32): null};
    _z21(cmd);

    //
    if (cmd is LanXCvPomWriteByte || cmd is LanXCvPomAccessoryWriteByte) {
      final int value = (cmd as dynamic).value;
      final result = LanXCvResult(cvAddress: cvAddress, value: value);
      state = {
        ...state,
        (cvAddress, _cv31, _cv32): result,
      };
      completer.complete(result);

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
