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
/// \file   ui/update/decup_view_model.dart
/// \author Vincent Hamp
/// \date   17/06/2026

import 'dart:math';
import 'dart:typed_data';

import 'package:Frontend/config/ws_batch_size.dart';
import 'package:Frontend/data/models/zimo/zpp.dart';
import 'package:Frontend/data/models/zimo/zsu.dart';
import 'package:Frontend/data/services/zimo/decup/decup.dart';
import 'package:Frontend/ui/update/view_models/exception.dart';
import 'package:Frontend/ui/update/view_models/state.dart';
import 'package:Frontend/ui/update/view_models/zimo/decup_service.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
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
        final firmware = await _zsuSearch(zsu);
        await _zsuBlockCount(firmware);
        await _zsuSecurityBytes();
        await _zsuUpdate(firmware);
      } else {
        final zpp = file as Zpp;
        await _zppPreamble();
        await _zppErase();
        await _zppUpdate(zpp);
        await _zppCvs(zpp);
      }
      await _disconnect();
    } on UpdateException catch (e) {
      state = state.copyWith(
        status: UpdateStatus.Failed,
        message: e.message,
        progress: 0,
        devices: [
          ...state.devices.map((d) => d.copyWith(status: UpdateStatus.Failed)),
        ],
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
  Future<ZsuFirmware> _zsuSearch(Zsu zsu) async {
    state = state.copyWith(status: UpdateStatus.Updating, message: 'Searching');

    for (final firmware in zsu.firmwares) {
      _decup(ZsuDecoderId(byte: firmware.id));
      final msg = await _events.next;
      if (msg.contains(DecupService.ack)) {
        state = state.copyWith(
          devices: [
            UpdateDeviceState(
              status: UpdateStatus.Connecting,
              name: firmware.name,
              id: firmware.id,
            ),
          ],
        );
        return firmware;
      }
    }

    throw UpdateException('No decoder found');
  }

  /// \todo document
  Future<void> _zsuBlockCount(ZsuFirmware firmware) async {
    final blockCount = (firmware.bin.length ~/ 256 + 8 - 1);
    _decup(ZsuBlockCount(count: blockCount));
    final msg = await _events.next;
    if (_decup.closeReason != null || !msg.contains(DecupService.nak)) {
      throw UpdateException(
        _decup.closeReason ?? 'Block count not acknowledged',
      );
    }
  }

  /// \todo document
  Future<void> _zsuSecurityBytes() async {
    _decup(ZsuSecurityByte1());
    final msg1 = await _events.next;
    _decup(ZsuSecurityByte2());
    final msg2 = await _events.next;
    if (_decup.closeReason != null ||
        !msg1.contains(DecupService.nak) ||
        !msg2.contains(DecupService.nak)) {
      throw UpdateException(
        _decup.closeReason ?? 'Security byte not acknowledged',
      );
    }
  }

  /// \todo document
  Future<void> _zsuUpdate(ZsuFirmware firmware) async {
    state = state.copyWith(
      message: 'Writing',
      devices: [state.devices.first.copyWith(status: UpdateStatus.Updating)],
    );

    final blockSize =
        firmware.id == 200 || (firmware.id >= 202 && firmware.id <= 205)
            ? 32
            : 64;
    final blocks = firmware.bin.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(wsBatchSize, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _decup(
          ZsuBlocks(count: i + j, chunk: Uint8List.fromList(blocks[i + j])),
        );
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (msg.contains(DecupService.ack)) {
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
      if (_decup.closeReason != null) {
        throw UpdateException(_decup.closeReason!);
      }

      // Update progress
      state = state.copyWith(
        message:
            'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        progress: i / blocks.length,
      );
    }
  }

  /// \todo document
  Future<void> _zppPreamble() async {
    for (int i = 0; i < _preambleCount; ++i) {
      _decup(ZppPreamble());
      await _events.next;
    }
  }

  /// \todo document
  Future<void> _zppErase() async {
    state = state.copyWith(status: UpdateStatus.Updating, message: 'Erasing');
    _decup(ZppErase());
    final msg = await _events.next;
    if (_decup.closeReason != null || !msg.contains(DecupService.nak)) {
      throw UpdateException(_decup.closeReason ?? 'Erasing failed');
    }
  }

  /// \todo document
  Future<void> _zppUpdate(Zpp zpp) async {
    state = state.copyWith(message: 'Writing');

    const int blockSize = 256;
    final blocks = zpp.flash.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(wsBatchSize, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _decup(
          ZppBlocks(count: i + j, chunk: Uint8List.fromList(blocks[i + j])),
        );
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (msg.contains(DecupService.ack)) {
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
      if (_decup.closeReason != null) {
        throw UpdateException(_decup.closeReason!);
      }

      // Update progress
      state = state.copyWith(
        message:
            'Writing ${i * blockSize ~/ 1024} / ${blocks.length * blockSize ~/ 1024} kB',
        progress: i / blocks.length,
      );
    }
  }

  /// \todo document
  Future<void> _zppCvs(Zpp zpp) async {
    state = state.copyWith(message: 'Writing');

    int i = 0;
    for (final entry in zpp.cvs.entries) {
      final msg = await _retryOnFailure(
        () => _decup(ZppWriteCv(cvAddress: entry.key, value: entry.value)),
      );
      if (_decup.closeReason != null || !msg.contains(DecupService.ack)) {
        throw UpdateException(_decup.closeReason ?? 'Writing CVs failed');
      }

      // Update progress
      state = state.copyWith(
        message: 'Writing ${++i} / ${zpp.cvs.length} CVs',
        progress: i / zpp.cvs.length,
      );
    }
  }

  /// \todo document
  Future<void> _disconnect() async {
    state = state.copyWith(
      status: UpdateStatus.Completed,
      message: 'Done',
      devices: [
        ...state.devices.map((d) => d.copyWith(status: UpdateStatus.Completed)),
      ],
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
