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

/// MDU view model
///
/// \file   ui/update/mdu_view_model.dart
/// \author Vincent Hamp
/// \date   19/06/2026

import 'dart:math';
import 'dart:typed_data';

import 'package:Frontend/config/ws_batch_size.dart';
import 'package:Frontend/data/services/zimo/mdu/mdu.dart';
import 'package:Frontend/domain/models/zimo/zpp.dart';
import 'package:Frontend/domain/models/zimo/zsu.dart';
import 'package:Frontend/ui/update/view_models/exception.dart';
import 'package:Frontend/ui/update/view_models/state.dart';
import 'package:Frontend/ui/update/view_models/zimo/mdu_service.dart';
import 'package:Frontend/utils/crc32.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mdu_view_model.g.dart';

/// \todo document
@Riverpod()
class MduViewModel extends _$MduViewModel {
  static const int _retries = 10;
  late final String _endpoint;
  late final MduService _mdu;
  late final StreamQueue<Uint8List> _events;

  /// \todo document
  @override
  UpdateState build(String endpoint) {
    _endpoint = endpoint;
    _mdu = ref.read(mduServiceProvider(endpoint));
    _events = StreamQueue(_mdu.stream);
    ref.onDispose(
      () {
        _events.cancel();
        _mdu.close();
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
        await _configTransferRate(zsu);
        await _zsuSearch(zsu);
        for (final device in state.devices) {
          final firmware = zsu.firmwares.firstWhere((fw) => fw.id == device.id);
          await _zsuPing(firmware);
          await _zsuSalsa20Iv(firmware);
          await _zsuErase(firmware);
          await _zsuUpdate(firmware);
          await _zsuCrc32Start(firmware);
          await _zsuCrc32Result(firmware);
        }
        await _zsuExit();
      } else {
        final zpp = file as Zpp;
        await _configTransferRate();
        await _zppValid(zpp);
        await _zppLcDcQuery(zpp);
        await _zppErase(zpp);
        await _zppUpdate(zpp);
        await _zppUpdateEnd(zpp);
        await _zppExit(zpp);
      }
      await _disconnect();
    } on UpdateException catch (e) {
      state = state.copyWith(
        status: UpdateStatus.Failed,
        message: e.message,
        progress: 0,
        devices: [
          ...state.devices.map(
            (d) => d.status == UpdateStatus.Completed
                ? d
                : d.copyWith(status: UpdateStatus.Failed),
          ),
        ],
      );
    }
  }

  /// \todo document
  Future<void> _connect() async {
    state =
        state.copyWith(status: UpdateStatus.Connecting, message: 'Connecting');
    await _mdu.ready;
  }

  /// \todo document
  Future<void> _configTransferRate([Zsu? zsu]) async {
    state = state.copyWith(
      status: UpdateStatus.Updating,
      message: 'Configuring transfer rate',
    );

    // Workaround for special bootloader update software
    if ((zsu?.firmwares.length ?? 0) == 1) return;

    // zsu -> TF starts at 3
    // zpp -> TF starts at 1
    final tfStart = zsu == null ? 1 : 3;
    for (int tf = tfStart; tf <= 4; ++tf) {
      final msg = await _retryOnFailure(
        () => _mdu(ConfigTransferRate(transferRate: tf)),
      );
      if (!msg.contains(MduService.ack)) return;
    }

    // Fallback
    final msg =
        await _retryOnFailure(() => _mdu(ConfigTransferRate(transferRate: 0)));
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(
        _mdu.closeReason ?? 'No common transfer rate found',
      );
    }
  }

  /// \todo document
  Future<void> _zsuSearch(Zsu zsu) async {
    state = state.copyWith(message: 'Searching');

    for (final firmware in zsu.firmwares) {
      // Already found
      if (state.devices.firstWhereOrNull((d) => d.id == firmware.id) != null) {
        continue;
      }

      // Ping all
      await _retryOnFailure(() => _mdu(Ping(serialNumber: 0, decoderId: 0)));

      // Ping ID
      final msg = await _retryOnFailure(
        () => _mdu(Ping(serialNumber: 0, decoderId: firmware.id)),
        retries: 1,
      );
      if (msg[0] == MduService.nak && msg[1] == MduService.ack) {
        final exp = RegExp(r'\w{5,}-[0-9]');
        final match = exp.firstMatch(firmware.name);
        if (match != null && match[0] != null) {
          final String name = match[0]!;
          state = state.copyWith(
            devices: [
              ...state.devices,
              UpdateDeviceState(
                status: UpdateStatus.Idle,
                name: name,
                id: firmware.id,
              ),
            ],
          );
        }
      }
    }

    if (state.devices.isEmpty) {
      throw UpdateException('No decoders found');
    }
  }

  /// \todo document
  Future<void> _zsuPing(ZsuFirmware firmware) async {
    state = state.copyWith(
      message: 'Pinging',
      devices: [
        ...state.devices.map(
          (d) => d.id == firmware.id
              ? d.copyWith(status: UpdateStatus.Connecting)
              : d,
        ),
      ],
    );
    await _retryOnFailure(() => _mdu(Ping(serialNumber: 0, decoderId: 0)));
    final msg = await _retryOnFailure(
      () => _mdu(Ping(serialNumber: 0, decoderId: firmware.id)),
    );
    if (_mdu.closeReason != null ||
        msg[0] == MduService.ack ||
        msg[1] == MduService.nak) {
      throw UpdateException(_mdu.closeReason ?? 'Decoder does not respond');
    }
  }

  /// \todo document
  Future<void> _zsuSalsa20Iv(ZsuFirmware firmware) async {
    state = state.copyWith(
      devices: [
        ...state.devices.map(
          (d) => d.id == firmware.id
              ? d.copyWith(status: UpdateStatus.Updating)
              : d,
        ),
      ],
    );
    final msg =
        await _retryOnFailure(() => _mdu(ZsuSalsa20IV(iv: firmware.iv!)));
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'Salsa20IV not valid');
    }
  }

  /// \todo document
  Future<void> _zsuErase(ZsuFirmware firmware) async {
    state = state.copyWith(message: 'Erasing');
    final msg = await _retryOnFailure(
      () =>
          _mdu(ZsuErase(beginAddress: 0, endAddress: firmware.bin.length - 1)),
    );
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'Erasing failed');
    }

    // Busy doesn't work for internal memory so don't check the response
    for (int i = 0; i < 5; ++i) {
      await Future.delayed(const Duration(seconds: 1));
      await _retryOnFailure(() => _mdu(Busy()));
    }
  }

  /// \todo document
  Future<void> _zsuUpdate(ZsuFirmware firmware) async {
    state = state.copyWith(message: 'Writing');

    const int blockSize = 64;
    final blocks = firmware.bin.slices(blockSize).toList();

    int i = 0;
    int failCount = 0;
    while (i < blocks.length) {
      // Number of blocks transmit at once
      final n = min(wsBatchSize, blocks.length - i);
      for (var j = 0; j < n; ++j) {
        _mdu(
          ZsuUpdate(
            address: (i + j) * blockSize,
            chunk: Uint8List.fromList(blocks[i + j]),
          ),
        );
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (!msg.contains(MduService.ack)) {
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
      if (_mdu.closeReason != null) {
        throw UpdateException(_mdu.closeReason!);
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
  Future<void> _zsuCrc32Start(ZsuFirmware firmware) async {
    final msg = await _retryOnFailure(
      () => _mdu(
        ZsuCrc32Start(
          beginAddress: 0,
          endAddress: firmware.bin.length - 1,
          crc32: crc32(firmware.bin),
        ),
      ),
    );
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'CRC32 check failed');
    }
  }

  /// \todo document
  Future<void> _zsuCrc32Result(ZsuFirmware firmware) async {
    final msg = await _retryOnFailure(() => _mdu(ZsuCrc32Result()));
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'CRC32 check failed');
    }
    state = state.copyWith(
      devices: [
        ...state.devices.map(
          (d) => d.id == firmware.id
              ? d.copyWith(status: UpdateStatus.Completed)
              : d,
        ),
      ],
    );
  }

  /// \todo document
  Future<void> _zsuExit() async {
    // Don't leave any decoder in MDU
    await _retryOnFailure(() => _mdu(Ping(serialNumber: 0, decoderId: 0)));
    await _retryOnFailure(() => _mdu(ZsuCrc32ResultExit()));
  }

  /// \todo document
  Future<void> _zppValid(Zpp zpp) async {
    state = state.copyWith(message: 'Validating ZPP');
    final msg = await _retryOnFailure(
      () => _mdu(
        ZppValidQuery(id: zpp.id, flashSize: zpp.flash.length),
      ),
    );
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'ZPP not valid');
    }
  }

  /// \todo document
  Future<void> _zppLcDcQuery(Zpp zpp) async {
    if (!zpp.coded) return;
    state = state.copyWith(message: 'Validating load code');
    final msg = await _retryOnFailure(
      () => _mdu(ZppLcDcQuery(developerCode: zpp.developerCode)),
    );
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'Load code not valid');
    }
  }

  /// \todo document
  Future<void> _zppErase(Zpp zpp) async {
    state = state.copyWith(message: 'Erasing');
    var msg = await _retryOnFailure(
      () => _mdu(
        ZppErase(beginAddress: 0, endAddress: zpp.flash.length),
      ),
    );
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'Erasing failed');
    }

    /// \warning
    /// During erasing busy must be checked periodically within the HTTP receive timeout.
    for (int i = 0; i < (200 / 3).ceil(); ++i) {
      await Future.delayed(const Duration(seconds: 3));
      msg = await _retryOnFailure(() => _mdu(Busy()));
      if (!msg.contains(MduService.ack)) break;
    }
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'Erasing failed');
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
        _mdu(
          ZppUpdate(
            address: (i + j) * blockSize,
            chunk: Uint8List.fromList(blocks[i + j]),
          ),
        );
      }

      // Wait for all responses
      for (final msg in await _events.take(n)) {
        // Go either forward
        if (!msg.contains(MduService.ack)) {
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
      if (_mdu.closeReason != null) {
        throw UpdateException(_mdu.closeReason!);
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
  Future<void> _zppUpdateEnd(Zpp zpp) async {
    final msg = await _retryOnFailure(
      () => _mdu(ZppUpdateEnd(beginAddress: 0, endAddress: zpp.flash.length)),
    );
    if (_mdu.closeReason != null || msg.contains(MduService.ack)) {
      throw UpdateException(_mdu.closeReason ?? 'ZPP update end check failed');
    }
  }

  /// \todo document
  Future<void> _zppExit(Zpp zpp) async {
    // Don't leave any decoder in MDU
    await _retryOnFailure(() => _mdu(Ping(serialNumber: 0, decoderId: 0)));
    await _retryOnFailure(() => _mdu(ZppExitReset()));
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
    await _mdu.close();
  }

  /// \todo document
  Future<Uint8List> _retryOnFailure(
    Function() f, {
    int retries = _retries,
  }) async {
    var msg = Uint8List.fromList([MduService.ack, MduService.nak]);
    for (int i = 0; i < retries; i++) {
      f();
      msg = await _events.next;
      if (msg[0] == MduService.nak) return msg;
    }
    return msg;
  }
}
