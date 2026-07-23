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

import 'package:Frontend/data/models/config.dart';
import 'package:Frontend/data/models/loco.dart';
import 'package:Frontend/data/repositories/settings.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/domain/models/decoder.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_cv.g.dart';

typedef CvKey = (int, int, int);
typedef CvMap = Map<CvKey, Z21Command?>;

/// \todo document
@Riverpod(keepAlive: true)
class Z21Cv extends _$Z21Cv {
  late final Z21Service _z21;
  late final Decoder _decoder;
  Completer<Z21Command>? _responseCompleter;
  final _mutex = Mutex();
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
        .listen(_onResponse);
    ref.onDispose(() => sub.cancel());
    _decoder = decoder;
    return {};
  }

  /// \todo document
  Future<Z21Command> read(int cvAddress) {
    final cmd = _decoder.address == null
        ? LanXCvRead(cvAddress: cvAddress)
        : _decoder.type == Loco
            ? LanXCvPomReadByte(
                locoAddress: _decoder.address!,
                cvAddress: cvAddress,
              )
            : LanXCvPomAccessoryReadByte(
                accyAddress: _decoder.address!,
                cvAddress: cvAddress,
              );
    return _mutex.protect(() => _execute(cmd, cvAddress));
  }

  /// \todo document
  Future<Z21Command> write(int cvAddress, int value) {
    final cmd = _decoder.address == null
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
              );

    return _mutex.protect(() => _execute(cmd, cvAddress));
  }

  /// \todo document
  Future<Z21Command> _execute(Z21Command cmd, int cvAddress) async {
    final completer = Completer<Z21Command>();
    _responseCompleter = completer;
    state = {...state, (cvAddress, _cv31, _cv32): null};
    _z21(cmd);

    // POM write
    if (cmd is LanXCvPomWriteByte || cmd is LanXCvPomAccessoryWriteByte) {
      final result =
          LanXCvResult(cvAddress: cvAddress, value: (cmd as dynamic).value);
      state = {...state, (cvAddress, _cv31, _cv32): result};
      final progCount = ref.read(
        settingsProvider.select(
          (config) =>
              config.value?.dccProgramPacketCount ??
              Config().dccProgramPacketCount,
        ),
      );
      await Future.delayed(Duration(milliseconds: 20 * progCount));
      return result;
    }
    // ... everything else
    else {
      final timeout = ref.read(
        settingsProvider.select(
          (config) =>
              config.value?.httpReceiveTimeout ?? Config().httpReceiveTimeout,
        ),
      );
      final response = await completer.future
          .timeout(Duration(seconds: timeout), onTimeout: () => LanXCvNack());
      _responseCompleter = null;
      state = {...state, (cvAddress, _cv31, _cv32): response};
      return response;
    }
  }

  /// \todo document
  void _onResponse(Z21Command command) {
    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.complete(command);
    }
  }
}
