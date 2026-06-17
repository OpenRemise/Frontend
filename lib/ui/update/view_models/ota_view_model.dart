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

/// OTA view model
///
/// \file   ui/update/ota_view_model.dart
/// \author Vincent Hamp
/// \date   16/06/2026

import 'dart:math';
import 'dart:typed_data';

import 'package:Frontend/data/services/ota/ota.dart';
import 'package:Frontend/ui/update/view_models/exception.dart';
import 'package:Frontend/ui/update/view_models/state.dart';
import 'package:Frontend/ui/update/view_models/ota_service.dart';
import 'package:async/async.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ota_view_model.g.dart';

/// \todo document
@Riverpod()
class OtaViewModel extends _$OtaViewModel {
  static const int _chunkSize = 1024;
  late final OtaService _ota;
  late final StreamQueue<Uint8List> _events;

  /// \todo document
  @override
  UpdateState build() {
    _ota = ref.read(otaServiceProvider);
    _events = StreamQueue(_ota.stream);
    ref.onDispose(
      () {
        _events.cancel();
        _ota.close();
      },
    );
    return UpdateState();
  }

  /// \todo document
  Future<void> update(Uint8List bin) async {
    try {
      await _connect();
      await _write(bin);
      await _disconnect();
    } on UpdateException catch (e) {
      state = state.copyWith(
        status: UpdateStatus.Failed,
        message: e.message,
        progress: 0,
      );
    }
  }

  /// \todo document
  Future<void> _connect() async {
    state =
        state.copyWith(status: UpdateStatus.Connecting, message: 'Connecting');
    await _ota.ready;
  }

  /// \todo document
  Future<void> _write(Uint8List bin) async {
    state = state.copyWith(status: UpdateStatus.Updating, message: 'Writing');

    int i = 0;
    while (i < bin.length) {
      final start = i;
      final end = start + _chunkSize;
      final chunk = bin.sublist(start, min(end, bin.length));
      _ota(Write(chunk: chunk));

      final msg = await _events.next;
      if (_ota.closeReason != null || !msg.contains(OtaService.ack)) {
        throw UpdateException(_ota.closeReason ?? 'Writing failed');
      }

      i += chunk.length;
      state = state.copyWith(
        message: 'Writing ${i ~/ 1024} / ${bin.length ~/ 1024} kB',
        progress: i / bin.length,
      );
    }
  }

  /// \todo document
  Future<void> _disconnect() async {
    state = state.copyWith(
      status: UpdateStatus.Completed,
      message: 'Done (\u{26A0} page will reload)',
    );
    await _ota.close();
  }
}
