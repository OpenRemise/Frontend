// Copyright (C) 2024 Vincent Hamp
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

// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:Frontend/utilities/exor.dart';

int data2uint16(Uint8List data) {
  return data[0] << 8 | data[1] << 0;
}

int data2int16(data) => data2uint16(data);

int data2uint32(Uint8List data) {
  return data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0;
}

int data2locoAddress(Uint8List data) {
  return data2uint16(data) & 0x3FFF;
}

int data2cvAddress(Uint8List data) {
  return data2uint16(data) & 0x03FF;
}

enum Header {
  // Client to Z21
  LAN_GET_SERIAL_NUMBER(0x10),
  LAN_GET_CODE(0x18),
  LAN_GET_HWINFO(0x1A),
  LAN_LOGOFF(0x30),
  LAN_X(0x40),
  LAN_X_GET_VERSION(0x40),
  LAN_X_GET_STATUS(0x40),
  LAN_X_SET_TRACK_POWER_OFF(0x40),
  LAN_X_SET_TRACK_POWER_ON(0x40),
  LAN_X_DCC_READ_REGISTER(0x40),
  LAN_X_CV_READ(0x40),
  LAN_X_DCC_WRITE_REGISTER(0x40),
  LAN_X_CV_WRITE(0x40),
  LAN_X_MM_WRITE_BYTE(0x40),
  LAN_X_GET_TURNOUT_INFO(0x40),
  LAN_X_GET_EXT_ACCESSORY_INFO(0x40),
  LAN_X_SET_TURNOUT(0x40),
  LAN_X_SET_EXT_ACCESSORY(0x40),
  LAN_X_SET_STOP(0x40),
  LAN_X_SET_LOCO_E_STOP(0x40),
  LAN_X_PURGE_LOCO(0x40),
  LAN_X_GET_LOCO_INFO(0x40),
  LAN_X_SET_LOCO_DRIVE(0x40),
  LAN_X_SET_LOCO_FUNCTION(0x40),
  LAN_X_SET_LOCO_FUNCTION_GROUP(0x40),
  LAN_X_SET_LOCO_BINARY_STATE(0x40),
  LAN_X_CV_POM_WRITE_BYTE(0x40),
  LAN_X_CV_POM_WRITE_BIT(0x40),
  LAN_X_CV_POM_READ_BYTE(0x40),
  LAN_X_CV_POM_ACCESSORY_WRITE_BYTE(0x40),
  LAN_X_CV_POM_ACCESSORY_WRITE_BIT(0x40),
  LAN_X_CV_POM_ACCESSORY_READ_BYTE(0x40),
  LAN_X_GET_FIRMWARE_VERSION(0x40),
  LAN_SET_BROADCASTFLAGS(0x50),
  LAN_GET_BROADCASTFLAGS(0x51),
  LAN_GET_LOCOMODE(0x60),
  LAN_SET_LOCOMODE(0x61),
  LAN_GET_TURNOUTMODE(0x70),
  LAN_SET_TURNOUTMODE(0x71),
  LAN_RMBUS_GETDATA(0x81),
  LAN_RMBUS_PROGRAMMODULE(0x82),
  LAN_SYSTEMSTATE_GETDATA(0x85),
  LAN_RAILCOM_GETDATA(0x89),
  LAN_LOCONET_FROM_LAN(0xA2),
  LAN_LOCONET_DISPATCH_ADDR(0xA3),
  LAN_LOCONET_DETECTOR(0xA4),
  LAN_CAN_DETECTOR(0xC4),
  LAN_CAN_DEVICE_GET_DESCRIPTION(0xC8),
  LAN_CAN_DEVICE_SET_DESCRIPTION(0xC9),
  LAN_CAN_BOOSTER_SET_TRACKPOWER(0xCB),
  LAN_FAST_CLOCK_CONTROL(0xCC),
  LAN_FAST_CLOCK_SETTINGS_GET(0xCE),
  LAN_FAST_CLOCK_SETTINGS_SET(0xCF),
  LAN_BOOSTER_SET_POWER(0xB2),
  LAN_BOOSTER_GET_DESCRIPTION(0xB8),
  LAN_BOOSTER_SET_DESCRIPTION(0xB9),
  LAN_BOOSTER_SYSTEMSTATE_GETDATA(0xBB),
  LAN_DECODER_GET_DESCRIPTION(0xD8),
  LAN_DECODER_SET_DESCRIPTION(0xD9),
  LAN_DECODER_SYSTEMSTATE_GETDATA(0xDB),
  LAN_ZLINK_GET_HWINFO(0xE8),

  // Z21 to Client
  Reply_to_LAN_GET_SERIAL_NUMBER(0x10),
  Reply_to_LAN_GET_CODE(0x18),
  Reply_to_LAN_GET_HWINFO(0x1A),
  LAN_X_TURNOUT_INFO(0x40),
  LAN_X_EXT_ACCESSORY_INFO(0x40),
  LAN_X_BC_TRACK_POWER_OFF(0x40),
  LAN_X_BC_TRACK_POWER_ON(0x40),
  LAN_X_BC_PROGRAMMING_MODE(0x40),
  LAN_X_BC_TRACK_SHORT_CIRCUIT(0x40),
  LAN_X_CV_NACK_SC(0x40),
  LAN_X_CV_NACK(0x40),
  LAN_X_UNKNOWN_COMMAND(0x40),
  LAN_X_STATUS_CHANGED(0x40),
  Reply_to_LAN_X_GET_VERSION(0x40),
  LAN_X_CV_RESULT(0x40),
  LAN_X_BC_STOPPED(0x40),
  LAN_X_LOCO_INFO(0x40),
  Reply_to_LAN_X_GET_FIRMWARE_VERSION(0x40),
  Reply_to_LAN_GET_BROADCASTFLAGS(0x51),
  Reply_to_LAN_GET_LOCOMODE(0x60),
  Reply_to_LAN_GET_TURNOUTMODE(0x70),
  LAN_RMBUS_DATACHANGED(0x80),
  LAN_SYSTEMSTATE_DATACHANGED(0x84),
  LAN_RAILCOM_DATACHANGED(0x88),
  LAN_LOCONET_Z21_RX(0xA0),
  LAN_LOCONET_Z21_TX(0xA1),
  // LAN_LOCONET_FROM_LAN ( 0xA2),
  // LAN_LOCONET_DISPATCH_ADDR ( 0xA3),
  // LAN_LOCONET_DETECTOR ( 0xA4),
  // LAN_CAN_DETECTOR ( 0xC4),
  Reply_to_LAN_CAN_DEVICE_GET_DESCRIPTION(0xC8),
  LAN_CAN_BOOSTER_SYSTEMSTATE_CHANGED(0xCA),
  LAN_FAST_CLOCK_DATA(0xCD),
  // LAN_FAST_CLOCK_SETTINGS_GET ( 0xCE),
  Reply_to_LAN_BOOSTER_GET_DESCRIPTION(0xB8),
  LAN_BOOSTER_SYSTEMSTATE_DATACHANGED(0xBA),
  Reply_to_LAN_DECODER_GET_DESCRIPTION(0xD8),
  LAN_DECODER_SYSTEMSTATE_DATACHANGED(0xDA),
  Reply_to_LAN_ZLINK_GET_HWINFO(0xE8);

  final int value;

  const Header(this.value);

  factory Header.fromInt(int i) => values.firstWhere(
        (e) => e.value == i,
        orElse: () => Header.LAN_X_UNKNOWN_COMMAND,
      );
}

enum XHeader {
  // Client to Z21
  LAN_X_21(0x21),
  LAN_X_GET_VERSION(0x21),
  LAN_X_GET_STATUS(0x21),
  LAN_X_SET_TRACK_POWER_OFF(0x21),
  LAN_X_SET_TRACK_POWER_ON(0x21),
  LAN_X_DCC_READ_REGISTER(0x22),
  LAN_X_23(0x23),
  LAN_X_CV_READ(0x23),
  LAN_X_DCC_WRITE_REGISTER(0x23),
  LAN_X_24(0x24),
  LAN_X_CV_WRITE(0x24),
  LAN_X_MM_WRITE_BYTE(0x24),
  LAN_X_GET_TURNOUT_INFO(0x43),
  LAN_X_GET_EXT_ACCESSORY_INFO(0x44),
  LAN_X_SET_TURNOUT(0x53),
  LAN_X_SET_EXT_ACCESSORY(0x54),
  LAN_X_SET_STOP(0x80),
  LAN_X_SET_LOCO_E_STOP(0x92),
  LAN_X_E3(0xE3),
  LAN_X_PURGE_LOCO(0xE3),
  LAN_X_GET_LOCO_INFO(0xE3),
  LAN_X_E4(0xE4),
  LAN_X_SET_LOCO_DRIVE(0xE4),
  LAN_X_SET_LOCO_FUNCTION(0xE4),
  LAN_X_SET_LOCO_FUNCTION_GROUP(0xE4),
  LAN_X_SET_LOCO_BINARY_STATE(0xE4),
  LAN_X_E6(0xE6),
  LAN_X_CV_POM_WRITE_BYTE(0xE6),
  LAN_X_CV_POM_WRITE_BIT(0xE6),
  LAN_X_CV_POM_READ_BYTE(0xE6),
  LAN_X_CV_POM_ACCESSORY_WRITE_BYTE(0xE6),
  LAN_X_CV_POM_ACCESSORY_WRITE_BIT(0xE6),
  LAN_X_CV_POM_ACCESSORY_READ_BYTE(0xE6),
  LAN_X_GET_FIRMWARE_VERSION(0xF1),

  // Z21 to Client
  LAN_X_TURNOUT_INFO(0x43),
  LAN_X_EXT_ACCESSORY_INFO(0x44),
  LAN_X_61(0x61),
  LAN_X_BC_TRACK_POWER_OFF(0x61),
  LAN_X_BC_TRACK_POWER_ON(0x61),
  LAN_X_BC_PROGRAMMING_MODE(0x61),
  LAN_X_BC_TRACK_SHORT_CIRCUIT(0x61),
  LAN_X_CV_NACK_SC(0x61),
  LAN_X_CV_NACK(0x61),
  LAN_X_UNKNOWN_COMMAND(0x61),
  LAN_X_STATUS_CHANGED(0x62),
  Reply_to_LAN_X_GET_VERSION(0x63),
  LAN_X_CV_RESULT(0x64),
  LAN_X_BC_STOPPED(0x81),
  LAN_X_LOCO_INFO(0xEF),
  Reply_to_LAN_X_GET_FIRMWARE_VERSION(0xF3);

  final int value;

  const XHeader(this.value);

  factory XHeader.fromInt(int i) => values.firstWhere(
        (e) => e.value == i,
        orElse: () => XHeader.LAN_X_UNKNOWN_COMMAND,
      );
}

enum DB0 {
  // Client to Z21
  LAN_X_GET_VERSION(0x21),
  LAN_X_GET_STATUS(0x24),
  LAN_X_SET_TRACK_POWER_OFF(0x80),
  LAN_X_SET_TRACK_POWER_ON(0x81),
  LAN_X_DCC_READ_REGISTER(0x11),
  LAN_X_CV_READ(0x11),
  LAN_X_DCC_WRITE_REGISTER(0x12),
  LAN_X_CV_WRITE(0x12),
  LAN_X_MM_WRITE_BYTE(0xFF),
  LAN_X_PURGE_LOCO(0x44),
  LAN_X_GET_LOCO_INFO(0xF0),
  LAN_X_SET_LOCO_DRIVE_14(0x10),
  LAN_X_SET_LOCO_DRIVE_28(0x12),
  LAN_X_SET_LOCO_DRIVE_128(0x13),
  LAN_X_SET_LOCO_FUNCTION(0xF8),
  LAN_X_SET_LOCO_FUNCTION_GROUP_1(0x20),
  LAN_X_SET_LOCO_FUNCTION_GROUP_2(0x21),
  LAN_X_SET_LOCO_FUNCTION_GROUP_3(0x22),
  LAN_X_SET_LOCO_FUNCTION_GROUP_4(0x23),
  LAN_X_SET_LOCO_FUNCTION_GROUP_5(0x28),
  LAN_X_SET_LOCO_FUNCTION_GROUP_6(0x29),
  LAN_X_SET_LOCO_FUNCTION_GROUP_7(0x2A),
  LAN_X_SET_LOCO_FUNCTION_GROUP_8(0x2B),
  LAN_X_SET_LOCO_FUNCTION_GROUP_9(0x50),
  LAN_X_SET_LOCO_FUNCTION_GROUP_10(0x51),
  LAN_X_SET_LOCO_BINARY_STATE(0x5F),
  LAN_X_CV_POM(0x30),
  LAN_X_CV_POM_WRITE_BYTE(0x30),
  LAN_X_CV_POM_WRITE_BIT(0x30),
  LAN_X_CV_POM_READ_BYTE(0x30),
  LAN_X_CV_POM_ACCESSORY(0x31),
  LAN_X_CV_POM_ACCESSORY_WRITE_BYTE(0x31),
  LAN_X_CV_POM_ACCESSORY_WRITE_BIT(0x31),
  LAN_X_CV_POM_ACCESSORY_READ_BYTE(0x31),
  LAN_X_GET_FIRMWARE_VERSION(0x0A),

  // Z21 to Client
  LAN_X_BC_TRACK_POWER_OFF(0x00),
  LAN_X_BC_TRACK_POWER_ON(0x01),
  LAN_X_BC_PROGRAMMING_MODE(0x02),
  LAN_X_BC_TRACK_SHORT_CIRCUIT(0x08),
  LAN_X_CV_NACK_SC(0x12),
  LAN_X_CV_NACK(0x13),
  LAN_X_UNKNOWN_COMMAND(0x82),
  LAN_X_STATUS_CHANGED(0x22),
  Reply_to_LAN_X_GET_VERSION(0x21),
  LAN_X_CV_RESULT(0x14),
  Reply_to_LAN_X_GET_FIRMWARE_VERSION(0x0A);

  final int value;

  const DB0(this.value);

  factory DB0.fromInt(int i) => values.firstWhere(
        (e) => e.value == i,
        orElse: () => DB0.LAN_X_UNKNOWN_COMMAND,
      );
}

sealed class Command {}

class ReplyToLanGetSerialNumber implements Command {}

class ReplyToLanGetCode implements Command {}

class ReplyToLanGetHwInfo implements Command {}

class LanXTurnoutInfo implements Command {}

class LanXExtAccessoryInfo implements Command {}

class LanXBcTrackPowerOff implements Command {}

class LanXBcTrackPowerOn implements Command {}

class LanXBcProgrammingMode implements Command {}

class LanXBcTrackShortCircuit implements Command {}

class LanXCvNackSc implements Command {}

class LanXCvNack implements Command {}

class LanXUnknownCommand implements Command {}

class LanXStatusChanged implements Command {
  final int centralState;

  LanXStatusChanged({required this.centralState});

  LanXStatusChanged.fromDataset(Uint8List dataset) : centralState = dataset[6] {
    assert(dataset.length == 0x08);
  }

  bool emergencyStop() {
    return centralState & 0x01 == 0x01;
  }

  bool trackVoltageOff() {
    return centralState & 0x02 == 0x02;
  }

  bool shortCircuit() {
    return centralState & 0x04 == 0x04;
  }

  bool programmingMode() {
    return centralState & 0x01 == 0x01;
  }

  @override
  String toString() {
    return 'LanXStatusChanged(centralState: $centralState)';
  }
}

class ReplyToLanXGetVersion implements Command {}

class LanXCvResult implements Command {
  final int cvAddress;
  final int value;

  LanXCvResult({required this.cvAddress, required this.value});

  LanXCvResult.fromDataset(Uint8List dataset)
      : cvAddress = data2cvAddress(dataset.sublist(6)),
        value = dataset[8] {
    assert(dataset.length == 0x0A);
  }

  @override
  String toString() {
    return 'LanXCvResult(cvAddress: $cvAddress, value: $value)';
  }
}

class LanXBcStopped implements Command {}

class LanXLocoInfo implements Command {
  final int address;
  final int mode;
  final bool busy;
  final int speedSteps;
  final int rvvvvvvv;
  final bool doubleTraction;
  final bool smartSearch;
  final int f31_0;

  LanXLocoInfo({
    required this.address,
    required this.mode,
    required this.busy,
    required this.speedSteps,
    required this.rvvvvvvv,
    required this.doubleTraction,
    required this.smartSearch,
    required this.f31_0,
  });

  LanXLocoInfo.fromDataset(Uint8List dataset)
      : address = data2locoAddress(dataset.sublist(5)),
        mode = dataset[7] & 0x07,
        busy = dataset[7] & (1 << 3) == (1 << 3),
        speedSteps = dataset[7] & 0x07,
        rvvvvvvv = dataset[8],
        doubleTraction = dataset[9] & (1 << 6) == (1 << 6),
        smartSearch = dataset[9] & (1 << 5) == (1 << 5),
        f31_0 = dataset.sublist(11, dataset.length - 1).fold(
                  dataset[10] << 5,
                  (previousValue, element) => element << 8 | previousValue,
                ) | // F31-F5
            ((dataset[9] & 0x0F) << 1) | // F4-F1
            ((dataset[9] & (1 << 4)) >> 4) // F0
  {
    assert(dataset.length >= 0x0F);
  }

  @override
  String toString() {
    return 'LanXLocoInfo(address: $address, mode: $mode, busy: $busy, speedSteps: $speedSteps, rvvvvvvv: $rvvvvvvv, doubleTraction: $doubleTraction, smartSearch: $smartSearch, f31_0: 0x${f31_0.toRadixString(16)})';
  }
}

class ReplyToLanXGetFirmwareVersion implements Command {}

class ReplyToLanGetBroadcastFlags implements Command {}

class ReplyToLanGetLocoMode implements Command {}

class ReplyToLanGetTurnoutMode implements Command {}

class LanRmBusDataChanged implements Command {}

class LanSystemStateDataChanged extends LanXStatusChanged implements Command {
  final int mainCurrent;
  final int progCurrent;
  final int filteredMainCurrent;
  final int temperature;
  final int supplyVoltage;
  final int vccVoltage;
  final int centralStateEx;
  final int capabilities;

  LanSystemStateDataChanged({
    required this.mainCurrent,
    required this.progCurrent,
    required this.filteredMainCurrent,
    required this.temperature,
    required this.supplyVoltage,
    required this.vccVoltage,
    required super.centralState,
    required this.centralStateEx,
    required this.capabilities,
  });

  LanSystemStateDataChanged.fromDataset(Uint8List dataset)
      : mainCurrent = data2int16(dataset.sublist(4)),
        progCurrent = data2int16(dataset.sublist(6)),
        filteredMainCurrent = data2int16(dataset.sublist(8)),
        temperature = data2int16(dataset.sublist(10)),
        supplyVoltage = data2uint16(dataset.sublist(12)),
        vccVoltage = data2uint16(dataset.sublist(14)),
        centralStateEx = dataset[16],
        capabilities = dataset[17],
        super(centralState: dataset[15]) {
    assert(dataset.length == 0x14);
  }

  @override
  String toString() {
    return 'LanSystemStateDataChanged(mainCurrent: $mainCurrent, progCurrent: $progCurrent, filteredMainCurrent: $filteredMainCurrent, temperature: $temperature, supplyVoltage: $supplyVoltage, vccVoltage: $vccVoltage, centralState: $centralState, centralStateEx: $centralStateEx, capabilities: $capabilities)';
  }
}

class LanRailComDataChanged implements Command {}

class LanLoconetZ21Rx implements Command {}

class LanLoconetZ21Tx implements Command {}

class LanLoconetFromLan implements Command {}

class LanLoconetDispatchAddr implements Command {}

class LanLoconetDetector implements Command {}

class LanCanDetector implements Command {}

class ReplyToLanCanDeviceGetDescription implements Command {}

class LanCanBoosterSystemStateChanged implements Command {}

class LanFastClockData implements Command {}

class LanFastClockSettingsGet implements Command {}

class ReplyToLanBoosterGetDescription implements Command {}

class LanBoosterSystemStateDataChanged implements Command {}

class ReplyToLanDecoderGetDescription implements Command {}

class LanDecoderSystemStateDataChanged implements Command {}

class ReplyToLanZLinkGetHwInfo implements Command {}

abstract interface class Z21Service {
  Future<void> get ready;
  Stream<Command> get stream;
  Future close([int? closeCode, String? closeReason]);

  void lanXGetStatus();
  void lanXSetTrackPowerOff();
  void lanXSetTrackPowerOn();
  void lanXCvRead(int cvAddress);
  void lanXCvWrite(int cvAddress, int value);
  void lanXGetLocoInfo(int address);
  void lanXSetLocoDrive(int address, int speedSteps, int rvvvvvvv);
  void lanXSetLocoFunction(int address, int state, int index);
  void lanXCvPomWriteByte(int address, int cvAddress, int value);
  void lanXCvPomReadByte(int address, int cvAddress);
  void lanSystemStateGetData();

  static Command convert(Uint8List dataset) {
    if (dataset.length <= 4) return LanXUnknownCommand();

    switch (Header.fromInt(dataset[2])) {
      case Header.Reply_to_LAN_GET_SERIAL_NUMBER:
        return ReplyToLanGetSerialNumber();

      case Header.Reply_to_LAN_GET_CODE:
        return ReplyToLanGetCode();

      case Header.Reply_to_LAN_GET_HWINFO:
        return ReplyToLanGetHwInfo();

      case Header.LAN_X:
        if (exor(dataset.sublist(4)) != 0) break;
        switch (XHeader.fromInt(dataset[4])) {
          case XHeader.LAN_X_TURNOUT_INFO:
            return LanXTurnoutInfo();

          case XHeader.LAN_X_EXT_ACCESSORY_INFO:
            return LanXExtAccessoryInfo();

          case XHeader.LAN_X_61:
            if (dataset.length < 6) break;
            switch (DB0.fromInt(dataset[5])) {
              case DB0.LAN_X_BC_TRACK_POWER_OFF:
                return LanXBcTrackPowerOff();

              case DB0.LAN_X_BC_TRACK_POWER_ON:
                return LanXBcTrackPowerOn();

              case DB0.LAN_X_BC_PROGRAMMING_MODE:
                return LanXBcProgrammingMode();

              case DB0.LAN_X_BC_TRACK_SHORT_CIRCUIT:
                return LanXBcTrackShortCircuit();

              case DB0.LAN_X_CV_NACK_SC:
                return LanXCvNackSc();

              case DB0.LAN_X_CV_NACK:
                return LanXCvNack();

              case DB0.LAN_X_UNKNOWN_COMMAND:
                break;

              default:
                break;
            }
            break;

          case XHeader.LAN_X_STATUS_CHANGED:
            return LanXStatusChanged.fromDataset(dataset);

          case XHeader.Reply_to_LAN_X_GET_VERSION:
            return ReplyToLanXGetVersion();

          case XHeader.LAN_X_CV_RESULT:
            return LanXCvResult.fromDataset(dataset);

          case XHeader.LAN_X_BC_STOPPED:
            return LanXBcStopped();

          case XHeader.LAN_X_LOCO_INFO:
            return LanXLocoInfo.fromDataset(dataset);

          case XHeader.Reply_to_LAN_X_GET_FIRMWARE_VERSION:
            return ReplyToLanXGetFirmwareVersion();

          default:
            break;
        }
        break;

      case Header.Reply_to_LAN_GET_BROADCASTFLAGS:
        return ReplyToLanGetBroadcastFlags();

      case Header.Reply_to_LAN_GET_LOCOMODE:
        return ReplyToLanGetLocoMode();

      case Header.Reply_to_LAN_GET_TURNOUTMODE:
        return ReplyToLanGetTurnoutMode();

      case Header.LAN_RMBUS_DATACHANGED:
        return LanRmBusDataChanged();

      case Header.LAN_SYSTEMSTATE_DATACHANGED:
        return LanSystemStateDataChanged.fromDataset(dataset);

      case Header.LAN_RAILCOM_DATACHANGED:
        return LanRailComDataChanged();

      case Header.LAN_LOCONET_Z21_RX:
        return LanLoconetZ21Rx();

      case Header.LAN_LOCONET_Z21_TX:
        return LanLoconetZ21Tx();

      case Header.LAN_LOCONET_FROM_LAN:
        return LanLoconetFromLan();

      case Header.LAN_LOCONET_DISPATCH_ADDR:
        return LanLoconetDispatchAddr();

      case Header.LAN_LOCONET_DETECTOR:
        return LanLoconetDetector();

      case Header.LAN_CAN_DETECTOR:
        return LanCanDetector();

      case Header.Reply_to_LAN_CAN_DEVICE_GET_DESCRIPTION:
        return ReplyToLanCanDeviceGetDescription();

      case Header.LAN_CAN_BOOSTER_SYSTEMSTATE_CHANGED:
        return LanCanBoosterSystemStateChanged();

      case Header.LAN_FAST_CLOCK_DATA:
        return LanFastClockData();

      case Header.LAN_FAST_CLOCK_SETTINGS_GET:
        return LanFastClockSettingsGet();

      case Header.Reply_to_LAN_BOOSTER_GET_DESCRIPTION:
        return ReplyToLanBoosterGetDescription();

      case Header.LAN_BOOSTER_SYSTEMSTATE_DATACHANGED:
        return LanBoosterSystemStateDataChanged();

      case Header.Reply_to_LAN_DECODER_GET_DESCRIPTION:
        return ReplyToLanDecoderGetDescription();

      case Header.LAN_DECODER_SYSTEMSTATE_DATACHANGED:
        return LanDecoderSystemStateDataChanged();

      case Header.Reply_to_LAN_ZLINK_GET_HWINFO:
        return ReplyToLanZLinkGetHwInfo();

      default:
        break;
    }

    return LanXUnknownCommand();
  }
}
