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

/// ZUSI view model
///
/// \file   ui/update/zusi_view_model.dart
/// \author Vincent Hamp
/// \date   17/06/2026

import 'dart:math';
import 'dart:typed_data';

import 'package:Frontend/config/ws_batch_size.dart';
import 'package:Frontend/data/services/zimo/zusi/zusi.dart';
import 'package:Frontend/domain/models/zimo/zpp.dart';
import 'package:Frontend/ui/update/view_models/exception.dart';
import 'package:Frontend/ui/update/view_models/state.dart';
import 'package:Frontend/ui/update/view_models/zimo/zusi_service.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'zusi_view_model.g.dart';

/// \todo document
@Riverpod()
class ZusiViewModel extends _$ZusiViewModel {
  static const int _retries = 10;
  static const int _blockSize = 256;
  late final ZusiService _zusi;
  late final StreamQueue<Uint8List> _events;

  /// \todo document
  @override
  UpdateState build() {
    _zusi = ref.read(zusiServiceProvider);
    _events = StreamQueue(_zusi.stream);
    ref.onDispose(
      () {
        _events.cancel();
        _zusi.close();
      },
    );
    return UpdateState();
  }

  /// \todo document
  Future<void> update(Zpp zpp) async {
    try {
      await _connect();
      await _features();
      await _zppLcDcQuery(zpp);
      await _erase();
      await _write(zpp);
      await _cvs(zpp);
      await _exit();
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
    await _zusi.ready;
  }

  /// \todo document
  Future<void> _features() async {
    state = state.copyWith(status: UpdateStatus.Updating);
    final msg = await _retryOnFailure(() => _zusi(Features()));
    if (_zusi.closeReason != null || !msg.contains(ZusiService.ack)) {
      throw UpdateException(_zusi.closeReason ?? 'No decoder found');
    }
  }

  /// \todo document
  Future<void> _zppLcDcQuery(Zpp zpp) async {
    if (!zpp.coded) return;
    state = state.copyWith(message: 'Check if load code is valid');
    final msg = await _retryOnFailure(
      () => _zusi(ZppLcDcQuery(developerCode: zpp.developerCode)),
    );
    if (_zusi.closeReason != null ||
        !msg.contains(ZusiService.ack) ||
        msg[1] == 0x00) {
      throw UpdateException(_zusi.closeReason ?? 'Load code not valid');
    }
  }

  /// \todo document
  Future<void> _erase() async {
    state = state.copyWith(message: 'Erasing');
    final msg = await _retryOnFailure(() => _zusi(ZppErase()));
    if (_zusi.closeReason != null || !msg.contains(ZusiService.ack)) {
      throw UpdateException(_zusi.closeReason ?? 'Erasing failed');
    }
  }

  /// \todo document
  Future<void> _write(Zpp zpp) async {
    state = state.copyWith(message: 'Writing');
    final blocks = zpp.flash.slices(_blockSize).toList();
    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(wsBatchSize, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _zusi(
          ZppWrite(
            address: (i + j) * _blockSize,
            chunk: Uint8List.fromList(blocks[i + j]),
          ),
        );
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (msg.contains(ZusiService.ack)) {
          failCount = 0;
          ++i;
        }
        // Or back (limited number of times)
        else if (failCount < _retries) {
          ++failCount;
          i = max(i - 1, 0);
          break;
        }
        // Or bail
        else {
          throw UpdateException('Writing failed');
        }
      }

      // WebSocket closed on the server side
      if (_zusi.closeReason != null) {
        throw UpdateException(_zusi.closeReason!);
      }

      // Update progress
      state = state.copyWith(
        message:
            'Writing ${i * _blockSize ~/ 1024} / ${blocks.length * _blockSize ~/ 1024} kB',
        progress: i / blocks.length,
      );
    }
  }

  /// \todo document
  Future<void> _cvs(Zpp zpp) async {
    state = state.copyWith(message: 'Writing');
    int i = 0;
    for (final entry in zpp.cvs.entries) {
      final msg = await _retryOnFailure(
        () => _zusi(CvWrite(cvAddress: entry.key, value: entry.value)),
      );
      if (_zusi.closeReason != null || !msg.contains(ZusiService.ack)) {
        throw UpdateException(_zusi.closeReason ?? 'Writing CVs failed');
      }

      // Update progress
      state = state.copyWith(
        message: 'Writing ${++i} / ${zpp.cvs.length} CVs',
        progress: i / zpp.cvs.length,
      );
    }
  }

  /// \todo document
  Future<void> _exit() async {
    await _retryOnFailure(() => _zusi(Exit(cv8Reset: true, restart: true)));
  }

  /// \todo document
  Future<void> _disconnect() async {
    state = state.copyWith(status: UpdateStatus.Completed, message: 'Done');
    await _zusi.close();
  }

  /// \todo document
  Future<Uint8List> _retryOnFailure(
    Function() f, {
    int retries = _retries,
  }) async {
    var msg = Uint8List.fromList([ZusiService.nak]);
    for (int i = 0; i < retries; i++) {
      f();
      msg = await _events.next;
      if (msg.contains(ZusiService.ack)) return msg;
    }
    return msg;
  }
}
