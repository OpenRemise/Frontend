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

/// DECUP view model
///
/// \file   ui/update/zusi_view_model.dart
/// \author Vincent Hamp
/// \date   17/06/2026

import 'dart:typed_data';

import 'package:Frontend/data/services/zimo/decup/decup.dart';
import 'package:Frontend/domain/models/zimo/zpp.dart';
import 'package:Frontend/domain/models/zimo/zsu.dart';
import 'package:Frontend/ui/update/view_models/exception.dart';
import 'package:Frontend/ui/update/view_models/state.dart';
import 'package:Frontend/ui/update/view_models/zimo/decup_service.dart';
import 'package:async/async.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'decup_view_model.g.dart';

/// \todo document
@Riverpod()
class DecupViewModel extends _$DecupViewModel {
  static const int _preambleCount = 300;
  static const int _retries = 10;
  late final String _endpoint;
  late final DecupService _decup;
  late final StreamQueue<Uint8List> _events;

  /// \todo document
  @override
  UpdateState build(String endpoint) {
    _endpoint = endpoint;
    _decup = ref.read(decupServiceProvider(endpoint));
    _events = StreamQueue(_decup.stream);
    ref.onDispose(
      () {
        _events.cancel();
        _decup.close();
      },
    );
    return UpdateState();
  }

  /// \todo document
  Future<void> update(dynamic file) async {
    try {
      await _connect();
      if (_endpoint.contains('zsu')) {
        final zsu = file as Zsu;
        await _zsuPreamble();
      } else {
        final zpp = file as Zpp;
        await _zppPreamble();
      }
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
    await _decup.ready;
  }

  /// \todo document
  Future<void> _zsuPreamble() async {
    for (int i = 0; i < _preambleCount; ++i) {
      _decup(ZsuPreamble());
      await _events.next;
    }
  }

  /// \todo document
  Future<void> _zsuSearch() async {}

  /// \todo document
  Future<void> _zsuBlockCount() async {}

  /// \todo document
  Future<void> _zsuSecurityBytes() async {}

  /// \todo document
  Future<void> _zsuUpdate() async {}

  /// \todo document
  Future<void> _zppPreamble() async {
    for (int i = 0; i < _preambleCount; ++i) {
      _decup(ZppPreamble());
      await _events.next;
    }
  }

  /// \todo document
  Future<void> _zppErase() async {}

  /// \todo document
  Future<void> _zppUpdate() async {}

  /// \todo document
  Future<void> _zppCvs() async {}

  /// \todo document
  Future<void> _disconnect() async {
    state = state.copyWith(
      status: UpdateStatus.Completed,
      message: 'Done (\u{26A0} page will reload)',
    );
    await _decup.close();
  }

  /// \todo document
  Future<Uint8List> _retryOnFailure(
    Function() f, {
    int retries = _retries,
  }) async {
    var msg = Uint8List.fromList([]);
    for (int i = 0; i < retries; i++) {
      f();
      msg = await _events.next;
      if (msg.contains(DecupService.ack)) return msg;
    }
    return msg;
  }
}
