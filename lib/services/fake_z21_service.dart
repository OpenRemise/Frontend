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

import 'package:Frontend/constants/fake_initial_cvs.dart';
import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/services/fake_sys_service.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeZ21Service implements Z21Service {
  final _controller = StreamController<Command>();
  late final Stream<Command> _stream;
  int _centralState = 0x02;
  List<int> _cvs = fakeInitialLocoCvs;
  final ProviderContainer ref;

  FakeZ21Service(this.ref) {
    _stream = _controller.stream.asBroadcastStream();
  }

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
    state = State.Suspend;
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
        _cvs = [
          for (var i = 0; i < _cvs.length; ++i)
            if (i == cvAddress) byte else _cvs[i],
        ];
        _controller.sink
            .add(LanXCvResult(cvAddress: cvAddress, value: _cvs[cvAddress]));
      },
    );
  }

  @override
  void lanXGetLocoInfo(int locoAddress) {
    Future.delayed(const Duration(milliseconds: 200), () {
      final locos = ref.read(locosProvider);
      final loco = locos.firstWhere(
        (loco) => loco.address == locoAddress,
        orElse: () => Loco(address: locoAddress, name: locoAddress.toString()),
      );
      if (_controller.isClosed) return;
      _controller.sink.add(
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
    });
  }

  @override
  void lanXSetLocoDrive(int locoAddress, int speedSteps, int rvvvvvvv) {
    final locos = ref.read(locosProvider);
    final loco = locos.firstWhere(
      (loco) => loco.address == locoAddress,
      orElse: () => Loco(address: locoAddress, name: locoAddress.toString()),
    );
    ref.read(locosProvider.notifier).updateLoco(
          locoAddress,
          loco.copyWith(speedSteps: speedSteps, rvvvvvvv: rvvvvvvv),
        );
  }

  @override
  void lanXSetLocoFunction(int locoAddress, int state, int index) {
    final locos = ref.read(locosProvider);
    final loco = locos.firstWhere(
      (loco) => loco.address == locoAddress,
      orElse: () => Loco(address: locoAddress, name: locoAddress.toString()),
    );
    ref.read(locosProvider.notifier).updateLoco(
          locoAddress,
          loco.copyWith(
            f31_0: state == 1
                ? loco.f31_0 | (1 << index)
                : loco.f31_0 & ~(1 << index),
          ),
        );
  }

  @override
  void lanXCvPomWriteByte(int locoAddress, int cvAddress, int byte) {
    final locos = ref.read(locosProvider);
    final loco = locos.firstWhere(
      (loco) => loco.address == locoAddress,
      orElse: () => Loco(address: 0),
    );
    if (loco.address != 0) _cvs[cvAddress] = byte;
  }

  @override
  void lanXCvPomReadByte(int locoAddress, int cvAddress) async {
    final locos = ref.read(locosProvider);
    final loco = locos.firstWhere(
      (loco) => loco.address == locoAddress,
      orElse: () => Loco(address: 0),
    );
    await Future.delayed(
      Duration(milliseconds: loco.address != 0 ? 250 : 500),
      () => _controller.sink.add(
        loco.address != 0
            ? LanXCvResult(cvAddress: cvAddress, value: _cvs[cvAddress])
            : LanXCvNack(),
      ),
    );
  }

  @override
  void lanSetBroadcastFlags(BroadcastFlags broadcastFlags) {
    // TODO: implement lanSetBroadcastFlags
  }

  @override
  void lanSystemStateGetData() {
    // TODO: implement lanSystemStateGetData
  }

  @override
  void lanRailComGetData(int locoAddress) {
    // TODO: implement lanRailComGetData
  }
}
