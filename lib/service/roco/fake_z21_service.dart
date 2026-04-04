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
  final _controller = StreamController<Z21Command>();
  late final Stream<Z21Command> _stream;
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
  Stream<Z21Command> get stream => _stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _controller.sink.close();

  @override
  void call(Z21Command cmd) {
    if (_controller.isClosed) return;

    switch (cmd) {
      // Handle this prior to everything else we need to match most specific first
      case LanSystemStateDataChanged():
        throw UnimplementedError();

      case LanGetSerialNumber():
        throw UnimplementedError();

      case LanGetCommonSettings():
        throw UnimplementedError();

      case LanSetCommonSettings():
        throw UnimplementedError();

      case LanGetMmDccSettings():
        throw UnimplementedError();

      case LanSetMmDccSettings():
        throw UnimplementedError();

      case LanGetCode():
        throw UnimplementedError();

      case LanGetHwInfo():
        throw UnimplementedError();

      case LanLogoff():
        throw UnimplementedError();

      case LanXGetVersion():
        throw UnimplementedError();

      case LanXGetStatus():
        _controller.sink.add(LanXStatusChanged(centralState: _centralState));
        break;

      case LanXSetTrackPowerOff():
        _centralState = _centralState | 0x02;
        state = State.Suspending;
        Future.delayed(
          const Duration(seconds: 1),
          () => state = State.Suspended,
        );
        break;

      case LanXSetTrackPowerOn():
        _centralState = _centralState & ~0x02;
        state = State.DCCOperations;
        break;

      case LanXDccReadRegister():
        throw UnimplementedError();

      case LanXCvRead():
        Future.delayed(
          const Duration(seconds: 1),
          () {
            if (_controller.isClosed) return;
            _controller.sink.add(
              LanXCvResult(
                cvAddress: cmd.cvAddress,
                value: _cvs[cmd.cvAddress],
              ),
            );
          },
        );
        break;

      case LanXDccWriteRegister():
        throw UnimplementedError();

      case LanXCvWrite():
        Future.delayed(
          const Duration(seconds: 1),
          () {
            if (_controller.isClosed) return;
            _cvs[cmd.cvAddress] = cmd.value;
            _controller.sink.add(
              LanXCvResult(
                cvAddress: cmd.cvAddress,
                value: _cvs[cmd.cvAddress],
              ),
            );
          },
        );
        break;

      case LanXMmWriteByte():
        throw UnimplementedError();

      case LanXGetTurnoutInfo():
        final turnout = ref.read(turnoutsProvider).firstWhere(
              (t) => t.address == cmd.accyAddress,
              orElse: () => _defaultTurnout(cmd.accyAddress),
            );
        _lanXTurnoutInfo(
          LanXTurnoutInfo(accyAddress: cmd.accyAddress, zz: turnout.position),
        );
        break;

      case LanXGetExtAccessoryInfo():
        throw UnimplementedError();

      case LanXSetTurnout():
        if (!cmd.a) return;
        Turnout? turnout = ref
            .read(turnoutsProvider)
            .firstWhereOrNull((t) => t.address == cmd.accyAddress);

        // Create turnout if it does not exist yet, otherwise we can't store position
        if (turnout == null) {
          turnout = _defaultTurnout(cmd.accyAddress);
          ref
              .read(turnoutsProvider.notifier)
              .updateTurnout(cmd.accyAddress, turnout);
        }

        final position = 1 << (cmd.p ? 1 : 0);
        if (turnout.position != position) {
          _lanXTurnoutInfo(
            LanXTurnoutInfo(accyAddress: cmd.accyAddress, zz: position),
          );
        }
        break;

      case LanXSetExtAccessory():
        throw UnimplementedError();

      case LanXSetStop():
        throw UnimplementedError();

      case LanXSetLocoEStop():
        final loco = ref
            .read(locosProvider)
            .firstWhere((l) => l.address == cmd.locoAddress);
        final rvvvvvvv =
            encodeRvvvvvvv(loco.speedSteps, loco.rvvvvvvv >= 0x80, -1);
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
        break;

      case LanXPurgeLoco():
        throw UnimplementedError();

      case LanXGetLocoInfo():
        final loco = ref
            .read(locosProvider)
            .firstWhere((l) => l.address == cmd.locoAddress);
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
        break;

      case LanXSetLocoDrive():
        final loco = ref
            .read(locosProvider)
            .firstWhere((l) => l.address == cmd.locoAddress);
        if (loco.speedSteps != cmd.speedSteps ||
            loco.rvvvvvvv != cmd.rvvvvvvv) {
          _lanXGetLocoInfo(
            LanXLocoInfo(
              locoAddress: loco.address,
              mode: 2,
              busy: false,
              speedSteps: cmd.speedSteps,
              rvvvvvvv: cmd.rvvvvvvv,
              doubleTraction: false,
              smartSearch: false,
              f31_0: loco.f31_0,
            ),
          );
        }
        break;

      case LanXSetLocoFunction():
        final loco = ref
            .read(locosProvider)
            .firstWhere((l) => l.address == cmd.locoAddress);
        final f31_0 = cmd.state == 1
            ? loco.f31_0 | (1 << cmd.index)
            : loco.f31_0 & ~(1 << cmd.index);
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
        break;

      case LanXSetLocoFunctionGroup():
        throw UnimplementedError();

      case LanXSetLocoBinaryState():
        throw UnimplementedError();

      case LanXCvPomWriteByte():
        final loco = ref
            .read(locosProvider)
            .firstWhereOrNull((l) => l.address == cmd.locoAddress);
        if (loco != null && loco.address != 0) _cvs[cmd.cvAddress] = cmd.value;
        break;

      case LanXCvPomWriteBit():
        throw UnimplementedError();

      case LanXCvPomReadByte():
        final loco = ref
            .read(locosProvider)
            .firstWhereOrNull((l) => l.address == cmd.locoAddress);
        Future.delayed(Duration(milliseconds: loco != null ? 250 : 500), () {
          if (_controller.isClosed) return;
          _controller.sink.add(
            loco != null
                ? LanXCvResult(
                    cvAddress: cmd.cvAddress,
                    value: _cvs[cmd.cvAddress],
                  )
                : LanXCvNack(),
          );
        });
        break;

      case LanXCvPomAccessoryWriteByte():
        final turnout = ref
            .read(turnoutsProvider)
            .firstWhereOrNull((t) => t.address == cmd.accyAddress);
        if (turnout != null && turnout.address != 0) {
          _cvs[cmd.cvAddress] = cmd.value;
        }
        break;

      case LanXCvPomAccessoryWriteBit():
        throw UnimplementedError();

      case LanXCvPomAccessoryReadByte():
        final turnout = ref
            .read(turnoutsProvider)
            .firstWhereOrNull((t) => t.address == cmd.accyAddress);
        Future.delayed(Duration(milliseconds: turnout != null ? 250 : 500), () {
          _controller.sink.add(
            turnout != null
                ? LanXCvResult(
                    cvAddress: cmd.cvAddress,
                    value: _cvs[cmd.cvAddress],
                  )
                : LanXCvNack(),
          );
        });
        break;

      case LanXGetFirmwareVersion():
        throw UnimplementedError();

      case LanSetBroadcastFlags():
        throw UnimplementedError();

      case LanGetBroadcastFlags():
        throw UnimplementedError();

      case LanGetLocoMode():
        throw UnimplementedError();

      case LanSetLocoMode():
        throw UnimplementedError();

      case LanGetTurnoutMode():
        throw UnimplementedError();

      case LanSetTurnoutMode():
        throw UnimplementedError();

      case LanRmBusGetData():
        throw UnimplementedError();

      case LanRmBusProgramModule():
        throw UnimplementedError();

      case LanSystemStateGetData():
        throw UnimplementedError();

      case LanRailComGetData():
        final loco = ref
            .read(locosProvider)
            .firstWhere((l) => l.address == cmd.locoAddress);
        final speed = decodeRvvvvvvv(loco.speedSteps, loco.rvvvvvvv);
        final kmh = speed.isNegative ? 0 : speed * 2;
        Future.delayed(Duration(milliseconds: loco.address != 0 ? 250 : 500),
            () {
          if (_controller.isClosed) return;
          _controller.sink.add(
            LanRailComDataChanged(
              locoAddress: cmd.locoAddress,
              receiveCounter: 0,
              errorCounter: 0,
              options: 0x04 | (kmh >= 256 ? 0x02 : 0x01),
              speed: kmh >= 256 ? kmh - 256 : kmh,
              qos: 0 + Random().nextInt(5),
            ),
          );
        });
        break;

      case LanLocoNetFromLan():
        throw UnimplementedError();

      case LanLocoNetDispatchAddr():
        throw UnimplementedError();

      case LanLocoNetDetector():
        throw UnimplementedError();

      case LanCanDetector():
        throw UnimplementedError();

      case LanCanDeviceGetDescription():
        throw UnimplementedError();

      case LanCanDeviceSetDescription():
        throw UnimplementedError();

      case LanCanBoosterSetTrackPower():
        throw UnimplementedError();

      case LanFastClockControl():
        throw UnimplementedError();

      case LanFastClockSettingsGet():
        throw UnimplementedError();

      case LanFastClockSettingsSet():
        throw UnimplementedError();

      case LanBoosterSetPower():
        throw UnimplementedError();

      case LanBoosterGetDescription():
        throw UnimplementedError();

      case LanBoosterSetDescription():
        throw UnimplementedError();

      case LanBoosterSystemStateGetData():
        throw UnimplementedError();

      case LanDecoderGetDescription():
        throw UnimplementedError();

      case LanDecoderSetDescription():
        throw UnimplementedError();

      case LanDecoderSystemStateGetData():
        throw UnimplementedError();

      case LanZLinkGetHwInfo():
        throw UnimplementedError();

      case ReplyToLanGetSerialNumber():
        throw UnimplementedError();

      case ReplyToLanGetCommonSettings():
        throw UnimplementedError();

      case ReplyToLanGetMmDccSettings():
        throw UnimplementedError();

      case ReplyToLanGetCode():
        throw UnimplementedError();

      case ReplyToLanGetHwInfo():
        throw UnimplementedError();

      case LanXTurnoutInfo():
        throw UnimplementedError();

      case LanXExtAccessoryInfo():
        throw UnimplementedError();

      case LanXBcTrackPowerOff():
        throw UnimplementedError();

      case LanXBcTrackPowerOn():
        throw UnimplementedError();

      case LanXBcProgrammingMode():
        throw UnimplementedError();

      case LanXBcTrackShortCircuit():
        throw UnimplementedError();

      case LanXCvNackSc():
        throw UnimplementedError();

      case LanXCvNack():
        throw UnimplementedError();

      case LanXUnknownCommand():
        throw UnimplementedError();

      case LanXStatusChanged():
        throw UnimplementedError();

      case ReplyToLanXGetVersion():
        throw UnimplementedError();

      case LanXCvResult():
        throw UnimplementedError();

      case LanXBcStopped():
        throw UnimplementedError();

      case LanXLocoInfo():
        throw UnimplementedError();

      case ReplyToLanXGetFirmwareVersion():
        throw UnimplementedError();

      case ReplyToLanGetBroadcastFlags():
        throw UnimplementedError();

      case ReplyToLanGetLocoMode():
        throw UnimplementedError();

      case ReplyToLanGetTurnoutMode():
        throw UnimplementedError();

      case LanRmBusDataChanged():
        throw UnimplementedError();

      // Handled above
      // case LanSystemStateDataChanged():
      //   throw UnimplementedError();

      case LanRailComDataChanged():
        throw UnimplementedError();

      case LanLocoNetZ21Rx():
        throw UnimplementedError();

      case LanLocoNetZ21Tx():
        throw UnimplementedError();

      case ReplyToLanLocoNetFromLan():
        throw UnimplementedError();

      case ReplyToLanLocoNetDispatchAddr():
        throw UnimplementedError();

      case ReplyToLanLocoNetDetector():
        throw UnimplementedError();

      case ReplyToLanCanDetector():
        throw UnimplementedError();

      case ReplyToLanCanDeviceGetDescription():
        throw UnimplementedError();

      case LanCanBoosterSystemStateChanged():
        throw UnimplementedError();

      case LanFastClockData():
        throw UnimplementedError();

      case ReplyToLanFastClockSettingsGet():
        throw UnimplementedError();

      case ReplyToLanBoosterGetDescription():
        throw UnimplementedError();

      case LanBoosterSystemStateDataChanged():
        throw UnimplementedError();

      case ReplyToLanDecoderGetDescription():
        throw UnimplementedError();

      case LanDecoderSystemStateDataChanged():
        throw UnimplementedError();

      case ReplyToLanZLinkGetHwInfo():
        throw UnimplementedError();
    }
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
