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
import 'dart:math';

import 'package:Frontend/constant/fake_initial_cvs.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/provider/turnouts.dart';
import 'package:Frontend/service/fake_sys_service.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeZ21Service implements Z21Service {
  final _controller = StreamController<Command>();
  late final Stream<Command> _stream;
  int _centralState = 0x02;
  final List<int> _cvs = List.from(fakeInitialLocoCvs);
  final ProviderContainer ref;

  FakeZ21Service(this.ref) {
    _stream = _controller.stream.asBroadcastStream();
  }

  @override
  int? get closeCode => _controller.isClosed ? 1005 : null;

  @override
  String? get closeReason => closeCode != null ? 'Timeout' : null;

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Command> get stream => _stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _controller.sink.close();

  @override
  void lanXGetStatus() {
    if (_controller.isClosed) return;
    _controller.sink.add(LanXStatusChanged(centralState: _centralState));
  }

  @override
  void lanXSetTrackPowerOff() {
    _centralState = _centralState | 0x02;
    state = State.Suspending;
    Future.delayed(const Duration(seconds: 1), () => state = State.Suspended);
  }

  @override
  void lanXSetTrackPowerOn() {
    _centralState = _centralState & ~0x02;
    state = State.DCCOperations;
  }

  @override
  void lanXCvRead(int cvAddress) {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (_controller.isClosed) return;
        _controller.sink
            .add(LanXCvResult(cvAddress: cvAddress, value: _cvs[cvAddress]));
      },
    );
  }

  @override
  void lanXCvWrite(int cvAddress, int byte) {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (_controller.isClosed) return;
        _cvs[cvAddress] = byte;
        _controller.sink
            .add(LanXCvResult(cvAddress: cvAddress, value: _cvs[cvAddress]));
      },
    );
  }

  @override
  void lanXGetTurnoutInfo(int accyAddress) {
    final turnout = ref.read(turnoutsProvider).firstWhere(
          (t) => t.address == accyAddress,
          orElse: () => _defaultTurnout(accyAddress),
        );
    _lanXTurnoutInfo(
      LanXTurnoutInfo(accyAddress: accyAddress, zz: turnout.position),
    );
  }

  @override
  void lanXSetTurnout(int accyAddress, bool p, bool a, [bool q = false]) {
    if (!a) return;
    Turnout? turnout = ref
        .read(turnoutsProvider)
        .firstWhereOrNull((t) => t.address == accyAddress);

    // Create turnout if it does not exist yet, otherwise we can't store position
    if (turnout == null) {
      turnout = _defaultTurnout(accyAddress);
      ref.read(turnoutsProvider.notifier).updateTurnout(accyAddress, turnout);
    }

    final position = 1 << (p ? 1 : 0);
    if (turnout.position != position) {
      _lanXTurnoutInfo(LanXTurnoutInfo(accyAddress: accyAddress, zz: position));
    }
  }

  @override
  void lanXSetLocoEStop(int locoAddress) {
    final loco =
        ref.read(locosProvider).firstWhere((l) => l.address == locoAddress);
    final rvvvvvvv = encodeRvvvvvvv(loco.speedSteps, loco.rvvvvvvv >= 0x80, -1);
    if (loco.rvvvvvvv != rvvvvvvv) {
      _lanXGetLocoInfo(
        LanXLocoInfo(
          locoAddress: loco.address,
          mode: 2,
          busy: false,
          speedSteps: loco.speedSteps,
          rvvvvvvv: rvvvvvvv,
          doubleTraction: false,
          smartSearch: false,
          f31_0: loco.f31_0,
        ),
      );
    }
  }

  @override
  void lanXGetLocoInfo(int locoAddress) {
    final loco =
        ref.read(locosProvider).firstWhere((l) => l.address == locoAddress);
    _lanXGetLocoInfo(
      LanXLocoInfo(
        locoAddress: loco.address,
        mode: 2,
        busy: false,
        speedSteps: loco.speedSteps,
        rvvvvvvv: loco.rvvvvvvv,
        doubleTraction: false,
        smartSearch: false,
        f31_0: loco.f31_0,
      ),
    );
  }

  @override
  void lanXSetLocoDrive(int locoAddress, int speedSteps, int rvvvvvvv) {
    final loco =
        ref.read(locosProvider).firstWhere((l) => l.address == locoAddress);
    if (loco.speedSteps != speedSteps || loco.rvvvvvvv != rvvvvvvv) {
      _lanXGetLocoInfo(
        LanXLocoInfo(
          locoAddress: loco.address,
          mode: 2,
          busy: false,
          speedSteps: speedSteps,
          rvvvvvvv: rvvvvvvv,
          doubleTraction: false,
          smartSearch: false,
          f31_0: loco.f31_0,
        ),
      );
    }
  }

  @override
  void lanXSetLocoFunction(int locoAddress, int state, int index) {
    final loco =
        ref.read(locosProvider).firstWhere((l) => l.address == locoAddress);
    final f31_0 =
        state == 1 ? loco.f31_0 | (1 << index) : loco.f31_0 & ~(1 << index);
    if (loco.f31_0 != f31_0) {
      _lanXGetLocoInfo(
        LanXLocoInfo(
          locoAddress: loco.address,
          mode: 2,
          busy: false,
          speedSteps: loco.speedSteps,
          rvvvvvvv: loco.rvvvvvvv,
          doubleTraction: false,
          smartSearch: false,
          f31_0: f31_0,
        ),
      );
    }
  }

  @override
  void lanXCvPomWriteByte(int locoAddress, int cvAddress, int byte) {
    final loco = ref
        .read(locosProvider)
        .firstWhereOrNull((l) => l.address == locoAddress);
    if (loco != null && loco.address != 0) _cvs[cvAddress] = byte;
  }

  @override
  void lanXCvPomReadByte(int locoAddress, int cvAddress) {
    final loco = ref
        .read(locosProvider)
        .firstWhereOrNull((l) => l.address == locoAddress);
    Future.delayed(Duration(milliseconds: loco != null ? 250 : 500), () {
      if (_controller.isClosed) return;
      _controller.sink.add(
        loco != null
            ? LanXCvResult(cvAddress: cvAddress, value: _cvs[cvAddress])
            : LanXCvNack(),
      );
    });
  }

  @override
  void lanXCvPomAccessoryWriteByte(int accyAddress, int cvAddress, int byte) {
    final turnout = ref
        .read(turnoutsProvider)
        .firstWhereOrNull((t) => t.address == accyAddress);
    if (turnout != null && turnout.address != 0) _cvs[cvAddress] = byte;
  }

  @override
  void lanXCvPomAccessoryReadByte(int accyAddress, int cvAddress) {
    final turnout = ref
        .read(turnoutsProvider)
        .firstWhereOrNull((t) => t.address == accyAddress);
    Future.delayed(Duration(milliseconds: turnout != null ? 250 : 500), () {
      _controller.sink.add(
        turnout != null
            ? LanXCvResult(cvAddress: cvAddress, value: _cvs[cvAddress])
            : LanXCvNack(),
      );
    });
  }

  @override
  void lanSetBroadcastFlags(BroadcastFlags broadcastFlags) {
    throw UnimplementedError();
  }

  @override
  void lanSystemStateGetData() {
    throw UnimplementedError();
  }

  @override
  void lanRailComGetData(int locoAddress) {
    final loco =
        ref.read(locosProvider).firstWhere((l) => l.address == locoAddress);
    final speed = decodeRvvvvvvv(loco.speedSteps, loco.rvvvvvvv);
    final kmh = speed.isNegative ? 0 : speed * 2;
    Future.delayed(Duration(milliseconds: loco.address != 0 ? 250 : 500), () {
      if (_controller.isClosed) return;
      _controller.sink.add(
        LanRailComDataChanged(
          locoAddress: locoAddress,
          receiveCounter: 0,
          errorCounter: 0,
          options: 0x04 | (kmh >= 256 ? 0x02 : 0x01),
          speed: kmh >= 256 ? kmh - 256 : kmh,
          qos: 0 + Random().nextInt(5),
        ),
      );
    });
  }

  void _lanXGetLocoInfo(LanXLocoInfo locoInfo) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_controller.isClosed) return;
      _controller.sink.add(locoInfo);
    });
  }

  void _lanXTurnoutInfo(LanXTurnoutInfo turnoutInfo) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_controller.isClosed) return;
      _controller.sink.add(turnoutInfo);
    });
  }

  Turnout _defaultTurnout(int accyAddress) {
    return Turnout(
      address: accyAddress,
      name: accyAddress.toString(),
      type: 0,
      group: Group(
        addresses: [accyAddress],
        positions: [
          [1],
          [2],
        ],
      ),
    );
  }
}
