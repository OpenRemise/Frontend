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

// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:Frontend/utilities/exor.dart';

/// \todo document
int bigEndianData2uint16(Uint8List data) {
  return data[0] << 8 | data[1] << 0;
}

/// \todo document
int bigEndianData2int16(data) {
  return data[0] << 8 | data[1] << 0;
}

/// \todo document
int littleEndianData2uint16(Uint8List data) {
  return data[1] << 8 | data[1] << 0;
}

/// \todo document
int littleEndianData2uint32(Uint8List data) {
  return data[3] << 24 | data[2] << 16 | data[1] << 8 | data[1] << 0;
}

/// \todo document
int data2locoAddress(Uint8List data) {
  return bigEndianData2uint16(data) & 0x3FFF;
}

/// \todo document
int data2cvAddress(Uint8List data) {
  return bigEndianData2uint16(data) & 0x03FF;
}

/// \todo document
int decodeRvvvvvvv(int speedSteps, int rvvvvvvv) {
  // 128 speed steps
  if (speedSteps == 3 || // Used in LAN_X_SET_LOCO_DRIVE
          speedSteps == 4 // Used in LAN_X_LOCO_INFO
      ) {
    // Halt
    if (rvvvvvvv & 0x7F == 0) {
      return 0;
    } else if (rvvvvvvv & 0x7E == 0) {
      return -1;
    } else {
      return (rvvvvvvv & 0x7F) - 1;
    }
  }
  // 14 or 28 speed steps
  else {
    // Halt
    if (rvvvvvvv & 0x0F == 0) {
      return 0;
    }
    // EStop
    else if (rvvvvvvv & 0x0E == 0) {
      return -1;
    }

    int speed = (rvvvvvvv & 0x0F) - 1;

    // 28 speed steps with intermediate
    if (speedSteps == 2) {
      speed <<= 1;
      if (rvvvvvvv & 0x10 == 0) --speed;
    }

    return speed;
  }
}

/// \todo document
int encodeRvvvvvvv(int speedSteps, bool dir, int speed) {
  // Halt
  if (speed == 0) {
    return (dir ? 1 : 0) << 7;
  }
  // EStop
  else if (speed < 0) {
    return ((dir ? 1 : 0) << 7) | 1;
  }

  int vvvvvvv = speed + 1;

  // 28 speed steps with intermediate
  if (speedSteps == 2) {
    vvvvvvv = (vvvvvvv >> 1) + 1;
    if (speed % 2 == 0) vvvvvvv |= 0x10;
  }

  return (dir ? 1 : 0) << 7 | vvvvvvv;
}

/// \todo document
class Header {
  // Client to Z21
  static const int LAN_GET_SERIAL_NUMBER = 0x10;
  static const int LAN_GET_CODE = 0x18;
  static const int LAN_GET_HWINFO = 0x1A;
  static const int LAN_LOGOFF = 0x30;
  static const int LAN_X = 0x40;
  static const int LAN_X_GET_VERSION = 0x40;
  static const int LAN_X_GET_STATUS = 0x40;
  static const int LAN_X_SET_TRACK_POWER_OFF = 0x40;
  static const int LAN_X_SET_TRACK_POWER_ON = 0x40;
  static const int LAN_X_DCC_READ_REGISTER = 0x40;
  static const int LAN_X_CV_READ = 0x40;
  static const int LAN_X_DCC_WRITE_REGISTER = 0x40;
  static const int LAN_X_CV_WRITE = 0x40;
  static const int LAN_X_MM_WRITE_BYTE = 0x40;
  static const int LAN_X_GET_TURNOUT_INFO = 0x40;
  static const int LAN_X_GET_EXT_ACCESSORY_INFO = 0x40;
  static const int LAN_X_SET_TURNOUT = 0x40;
  static const int LAN_X_SET_EXT_ACCESSORY = 0x40;
  static const int LAN_X_SET_STOP = 0x40;
  static const int LAN_X_SET_LOCO_E_STOP = 0x40;
  static const int LAN_X_PURGE_LOCO = 0x40;
  static const int LAN_X_GET_LOCO_INFO = 0x40;
  static const int LAN_X_SET_LOCO_DRIVE = 0x40;
  static const int LAN_X_SET_LOCO_FUNCTION = 0x40;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP = 0x40;
  static const int LAN_X_SET_LOCO_BINARY_STATE = 0x40;
  static const int LAN_X_CV_POM_WRITE_BYTE = 0x40;
  static const int LAN_X_CV_POM_WRITE_BIT = 0x40;
  static const int LAN_X_CV_POM_READ_BYTE = 0x40;
  static const int LAN_X_CV_POM_ACCESSORY_WRITE_BYTE = 0x40;
  static const int LAN_X_CV_POM_ACCESSORY_WRITE_BIT = 0x40;
  static const int LAN_X_CV_POM_ACCESSORY_READ_BYTE = 0x40;
  static const int LAN_X_GET_FIRMWARE_VERSION = 0x40;
  static const int LAN_SET_BROADCASTFLAGS = 0x50;
  static const int LAN_GET_BROADCASTFLAGS = 0x51;
  static const int LAN_GET_LOCOMODE = 0x60;
  static const int LAN_SET_LOCOMODE = 0x61;
  static const int LAN_GET_TURNOUTMODE = 0x70;
  static const int LAN_SET_TURNOUTMODE = 0x71;
  static const int LAN_RMBUS_GETDATA = 0x81;
  static const int LAN_RMBUS_PROGRAMMODULE = 0x82;
  static const int LAN_SYSTEMSTATE_GETDATA = 0x85;
  static const int LAN_RAILCOM_GETDATA = 0x89;
  static const int LAN_LOCONET_FROM_LAN = 0xA2;
  static const int LAN_LOCONET_DISPATCH_ADDR = 0xA3;
  static const int LAN_LOCONET_DETECTOR = 0xA4;
  static const int LAN_CAN_DETECTOR = 0xC4;
  static const int LAN_CAN_DEVICE_GET_DESCRIPTION = 0xC8;
  static const int LAN_CAN_DEVICE_SET_DESCRIPTION = 0xC9;
  static const int LAN_CAN_BOOSTER_SET_TRACKPOWER = 0xCB;
  static const int LAN_FAST_CLOCK_CONTROL = 0xCC;
  static const int LAN_FAST_CLOCK_SETTINGS_GET = 0xCE;
  static const int LAN_FAST_CLOCK_SETTINGS_SET = 0xCF;
  static const int LAN_BOOSTER_SET_POWER = 0xB2;
  static const int LAN_BOOSTER_GET_DESCRIPTION = 0xB8;
  static const int LAN_BOOSTER_SET_DESCRIPTION = 0xB9;
  static const int LAN_BOOSTER_SYSTEMSTATE_GETDATA = 0xBB;
  static const int LAN_DECODER_GET_DESCRIPTION = 0xD8;
  static const int LAN_DECODER_SET_DESCRIPTION = 0xD9;
  static const int LAN_DECODER_SYSTEMSTATE_GETDATA = 0xDB;
  static const int LAN_ZLINK_GET_HWINFO = 0xE8;

  // Z21 to Client
  static const int Reply_to_LAN_GET_SERIAL_NUMBER = 0x10;
  static const int Reply_to_LAN_GET_CODE = 0x18;
  static const int Reply_to_LAN_GET_HWINFO = 0x1A;
  static const int LAN_X_TURNOUT_INFO = 0x40;
  static const int LAN_X_EXT_ACCESSORY_INFO = 0x40;
  static const int LAN_X_BC_TRACK_POWER_OFF = 0x40;
  static const int LAN_X_BC_TRACK_POWER_ON = 0x40;
  static const int LAN_X_BC_PROGRAMMING_MODE = 0x40;
  static const int LAN_X_BC_TRACK_SHORT_CIRCUIT = 0x40;
  static const int LAN_X_CV_NACK_SC = 0x40;
  static const int LAN_X_CV_NACK = 0x40;
  static const int LAN_X_UNKNOWN_COMMAND = 0x40;
  static const int LAN_X_STATUS_CHANGED = 0x40;
  static const int Reply_to_LAN_X_GET_VERSION = 0x40;
  static const int LAN_X_CV_RESULT = 0x40;
  static const int LAN_X_BC_STOPPED = 0x40;
  static const int LAN_X_LOCO_INFO = 0x40;
  static const int Reply_to_LAN_X_GET_FIRMWARE_VERSION = 0x40;
  static const int Reply_to_LAN_GET_BROADCASTFLAGS = 0x51;
  static const int Reply_to_LAN_GET_LOCOMODE = 0x60;
  static const int Reply_to_LAN_GET_TURNOUTMODE = 0x70;
  static const int LAN_RMBUS_DATACHANGED = 0x80;
  static const int LAN_SYSTEMSTATE_DATACHANGED = 0x84;
  static const int LAN_RAILCOM_DATACHANGED = 0x88;
  static const int LAN_LOCONET_Z21_RX = 0xA0;
  static const int LAN_LOCONET_Z21_TX = 0xA1;
  // LAN_LOCONET_FROM_LAN = 0xA2u,
  // LAN_LOCONET_DISPATCH_ADDR = 0xA3u,
  // LAN_LOCONET_DETECTOR = 0xA4u,
  // LAN_CAN_DETECTOR = 0xC4u,
  static const int Reply_to_LAN_CAN_DEVICE_GET_DESCRIPTION = 0xC8;
  static const int LAN_CAN_BOOSTER_SYSTEMSTATE_CHANGED = 0xCA;
  static const int LAN_FAST_CLOCK_DATA = 0xCD;
  // LAN_FAST_CLOCK_SETTINGS_GET = 0xCEu,
  static const int Reply_to_LAN_BOOSTER_GET_DESCRIPTION = 0xB8;
  static const int LAN_BOOSTER_SYSTEMSTATE_DATACHANGED = 0xBA;
  static const int Reply_to_LAN_DECODER_GET_DESCRIPTION = 0xD8;
  static const int LAN_DECODER_SYSTEMSTATE_DATACHANGED = 0xDA;
  static const int Reply_to_LAN_ZLINK_GET_HWINFO = 0xE8;

  const Header._();
}

/// \todo document
class XHeader {
  // Client to Z21
  static const int LAN_X_21 = 0x21;
  static const int LAN_X_GET_VERSION = 0x21;
  static const int LAN_X_GET_STATUS = 0x21;
  static const int LAN_X_SET_TRACK_POWER_OFF = 0x21;
  static const int LAN_X_SET_TRACK_POWER_ON = 0x21;
  static const int LAN_X_DCC_READ_REGISTER = 0x22;
  static const int LAN_X_23 = 0x23;
  static const int LAN_X_CV_READ = 0x23;
  static const int LAN_X_DCC_WRITE_REGISTER = 0x23;
  static const int LAN_X_24 = 0x24;
  static const int LAN_X_CV_WRITE = 0x24;
  static const int LAN_X_MM_WRITE_BYTE = 0x24;
  static const int LAN_X_GET_TURNOUT_INFO = 0x43;
  static const int LAN_X_GET_EXT_ACCESSORY_INFO = 0x44;
  static const int LAN_X_SET_TURNOUT = 0x53;
  static const int LAN_X_SET_EXT_ACCESSORY = 0x54;
  static const int LAN_X_SET_STOP = 0x80;
  static const int LAN_X_SET_LOCO_E_STOP = 0x92;
  static const int LAN_X_E3 = 0xE3;
  static const int LAN_X_PURGE_LOCO = 0xE3;
  static const int LAN_X_GET_LOCO_INFO = 0xE3;
  static const int LAN_X_E4 = 0xE4;
  static const int LAN_X_SET_LOCO_DRIVE = 0xE4;
  static const int LAN_X_SET_LOCO_FUNCTION = 0xE4;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP = 0xE4;
  static const int LAN_X_SET_LOCO_BINARY_STATE = 0xE4;
  static const int LAN_X_E6 = 0xE6;
  static const int LAN_X_CV_POM_WRITE_BYTE = 0xE6;
  static const int LAN_X_CV_POM_WRITE_BIT = 0xE6;
  static const int LAN_X_CV_POM_READ_BYTE = 0xE6;
  static const int LAN_X_CV_POM_ACCESSORY_WRITE_BYTE = 0xE6;
  static const int LAN_X_CV_POM_ACCESSORY_WRITE_BIT = 0xE6;
  static const int LAN_X_CV_POM_ACCESSORY_READ_BYTE = 0xE6;
  static const int LAN_X_GET_FIRMWARE_VERSION = 0xF1;

  // Z21 to Client
  static const int LAN_X_TURNOUT_INFO = 0x43;
  static const int LAN_X_EXT_ACCESSORY_INFO = 0x44;
  static const int LAN_X_61 = 0x61;
  static const int LAN_X_BC_TRACK_POWER_OFF = 0x61;
  static const int LAN_X_BC_TRACK_POWER_ON = 0x61;
  static const int LAN_X_BC_PROGRAMMING_MODE = 0x61;
  static const int LAN_X_BC_TRACK_SHORT_CIRCUIT = 0x61;
  static const int LAN_X_CV_NACK_SC = 0x61;
  static const int LAN_X_CV_NACK = 0x61;
  static const int LAN_X_UNKNOWN_COMMAND = 0x61;
  static const int LAN_X_STATUS_CHANGED = 0x62;
  static const int Reply_to_LAN_X_GET_VERSION = 0x63;
  static const int LAN_X_CV_RESULT = 0x64;
  static const int LAN_X_BC_STOPPED = 0x81;
  static const int LAN_X_LOCO_INFO = 0xEF;
  static const int Reply_to_LAN_X_GET_FIRMWARE_VERSION = 0xF3;

  const XHeader._();
}

/// \todo document
class DB0 {
  // Client to Z21
  static const int LAN_X_GET_VERSION = 0x21;
  static const int LAN_X_GET_STATUS = 0x24;
  static const int LAN_X_SET_TRACK_POWER_OFF = 0x80;
  static const int LAN_X_SET_TRACK_POWER_ON = 0x81;
  static const int LAN_X_DCC_READ_REGISTER = 0x11;
  static const int LAN_X_CV_READ = 0x11;
  static const int LAN_X_DCC_WRITE_REGISTER = 0x12;
  static const int LAN_X_CV_WRITE = 0x12;
  static const int LAN_X_MM_WRITE_BYTE = 0xFF;
  static const int LAN_X_PURGE_LOCO = 0x44;
  static const int LAN_X_GET_LOCO_INFO = 0xF0;
  static const int LAN_X_SET_LOCO_DRIVE_14 = 0x10;
  static const int LAN_X_SET_LOCO_DRIVE_28 = 0x12;
  static const int LAN_X_SET_LOCO_DRIVE_128 = 0x13;
  static const int LAN_X_SET_LOCO_FUNCTION = 0xF8;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_1 = 0x20;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_2 = 0x21;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_3 = 0x22;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_4 = 0x23;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_5 = 0x28;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_6 = 0x29;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_7 = 0x2A;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_8 = 0x2B;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_9 = 0x50;
  static const int LAN_X_SET_LOCO_FUNCTION_GROUP_10 = 0x51;
  static const int LAN_X_SET_LOCO_BINARY_STATE = 0x5F;
  static const int LAN_X_CV_POM = 0x30;
  static const int LAN_X_CV_POM_WRITE_BYTE = 0x30;
  static const int LAN_X_CV_POM_WRITE_BIT = 0x30;
  static const int LAN_X_CV_POM_READ_BYTE = 0x30;
  static const int LAN_X_CV_POM_ACCESSORY = 0x31;
  static const int LAN_X_CV_POM_ACCESSORY_WRITE_BYTE = 0x31;
  static const int LAN_X_CV_POM_ACCESSORY_WRITE_BIT = 0x31;
  static const int LAN_X_CV_POM_ACCESSORY_READ_BYTE = 0x31;
  static const int LAN_X_GET_FIRMWARE_VERSION = 0x0A;

  // Z21 to Client
  static const int LAN_X_BC_TRACK_POWER_OFF = 0x00;
  static const int LAN_X_BC_TRACK_POWER_ON = 0x01;
  static const int LAN_X_BC_PROGRAMMING_MODE = 0x02;
  static const int LAN_X_BC_TRACK_SHORT_CIRCUIT = 0x08;
  static const int LAN_X_CV_NACK_SC = 0x12;
  static const int LAN_X_CV_NACK = 0x13;
  static const int LAN_X_UNKNOWN_COMMAND = 0x82;
  static const int LAN_X_STATUS_CHANGED = 0x22;
  static const int Reply_to_LAN_X_GET_VERSION = 0x21;
  static const int LAN_X_CV_RESULT = 0x14;
  static const int Reply_to_LAN_X_GET_FIRMWARE_VERSION = 0x0A;

  const DB0._();
}

enum BroadcastFlag {
  DrivingSwitching(0x00000001),
  RBus(0x00000002),
  RailComSubscribed(0x00000004),
  SystemStatus(0x00000100),
  DrivingSwitchingEx(0x00010000),
  LocoNet(0x01000000),
  LocoNetDriving(0x02000000),
  LocoNetSwitching(0x04000000),
  LocoNetDetector(0x08000000),
  RailCom(0x00040000),
  CANDetector(0x00080000),
  CANBooster(0x00020000),
  FastClock(0x00000010);

  final int value;

  const BroadcastFlag(this.value);

  factory BroadcastFlag.fromInt(int i) => values.firstWhere(
        (f) => f.value == i,
        orElse: () => BroadcastFlag.DrivingSwitching,
      );
}

/// \todo document
class BroadcastFlags {
  final int value;

  const BroadcastFlags(this.value);

  factory BroadcastFlags.fromList(List<BroadcastFlag> flags) {
    return BroadcastFlags(flags.fold(0, (a, b) => a | b.value));
  }

  bool has(BroadcastFlag flag) => (value & flag.value) != 0;

  BroadcastFlags add(BroadcastFlag flag) => BroadcastFlags(value | flag.value);

  BroadcastFlags remove(BroadcastFlag flag) =>
      BroadcastFlags(value & ~flag.value);
}

/// \todo document
sealed class Command {}

/// \todo document
class ReplyToLanGetSerialNumber implements Command {}

/// \todo document
class ReplyToLanGetCode implements Command {}

/// \todo document
class ReplyToLanGetHwInfo implements Command {}

/// \todo document
class LanXTurnoutInfo implements Command {}

/// \todo document
class LanXExtAccessoryInfo implements Command {}

/// \todo document
class LanXBcTrackPowerOff implements Command {}

/// \todo document
class LanXBcTrackPowerOn implements Command {}

/// \todo document
class LanXBcProgrammingMode implements Command {}

/// \todo document
class LanXBcTrackShortCircuit implements Command {}

/// \todo document
class LanXCvNackSc implements Command {}

/// \todo document
class LanXCvNack implements Command {}

/// \todo document
class LanXUnknownCommand implements Command {}

/// \todo document
class LanXStatusChanged implements Command {
  final int centralState;

  LanXStatusChanged({required this.centralState});

  LanXStatusChanged.fromDataset(Uint8List dataset) : centralState = dataset[6] {
    assert(dataset.length == 0x08);
  }

  bool emergencyStop() {
    return centralState & 0x01 != 0;
  }

  bool trackVoltageOff() {
    return centralState & 0x02 != 0;
  }

  bool shortCircuit() {
    return centralState & 0x04 != 0;
  }

  bool programmingMode() {
    return centralState & 0x01 != 0;
  }

  @override
  String toString() {
    return 'LanXStatusChanged(centralState: $centralState)';
  }
}

/// \todo document
class ReplyToLanXGetVersion implements Command {}

/// \todo document
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

/// \todo document
class LanXBcStopped implements Command {}

/// \todo document
class LanXLocoInfo implements Command {
  final int locoAddress;
  final int mode;
  final bool busy;
  final int speedSteps;
  final int rvvvvvvv;
  final bool doubleTraction;
  final bool smartSearch;
  final int f31_0;

  LanXLocoInfo({
    required this.locoAddress,
    required this.mode,
    required this.busy,
    required this.speedSteps,
    required this.rvvvvvvv,
    required this.doubleTraction,
    required this.smartSearch,
    required this.f31_0,
  });

  LanXLocoInfo.fromDataset(Uint8List dataset)
      : locoAddress = data2locoAddress(dataset.sublist(5)),
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
    return 'LanXLocoInfo(locoAddress: $locoAddress, mode: $mode, busy: $busy, speedSteps: $speedSteps, rvvvvvvv: $rvvvvvvv, doubleTraction: $doubleTraction, smartSearch: $smartSearch, f31_0: 0x${f31_0.toRadixString(16)})';
  }
}

/// \todo document
class ReplyToLanXGetFirmwareVersion implements Command {}

/// \todo document
class ReplyToLanGetBroadcastFlags implements Command {}

/// \todo document
class ReplyToLanGetLocoMode implements Command {}

/// \todo document
class ReplyToLanGetTurnoutMode implements Command {}

/// \todo document
class LanRmBusDataChanged implements Command {}

/// \todo document
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
      : mainCurrent = bigEndianData2int16(dataset.sublist(4)),
        progCurrent = bigEndianData2int16(dataset.sublist(6)),
        filteredMainCurrent = bigEndianData2int16(dataset.sublist(8)),
        temperature = bigEndianData2int16(dataset.sublist(10)),
        supplyVoltage = bigEndianData2uint16(dataset.sublist(12)),
        vccVoltage = bigEndianData2uint16(dataset.sublist(14)),
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

/// \todo document
class LanRailComDataChanged implements Command {
  final int locoAddress;
  final int receiveCounter;
  final int errorCounter;
  final int options;
  final int speed;
  final int qos;

  LanRailComDataChanged({
    required this.locoAddress,
    required this.receiveCounter,
    required this.errorCounter,
    required this.options,
    required this.speed,
    required this.qos,
  });

  LanRailComDataChanged.fromDataset(Uint8List dataset)
      : locoAddress = littleEndianData2uint16(dataset.sublist(4)),
        receiveCounter = littleEndianData2uint32(dataset.sublist(6)),
        errorCounter = littleEndianData2uint16(dataset.sublist(10)),
        options = dataset[13],
        speed = dataset[14],
        qos = dataset[15] {
    assert(dataset.length >= 0x11);
  }

  int? kmh() {
    //
    if (options & 0x01 != 0) {
      return speed;
    }
    //
    else if (options & 0x02 != 0) {
      return 256 + speed;
    }
    //
    else {
      return null;
    }
  }

  int? qoS() {
    return options & 0x04 != 0 ? 100 - qos.clamp(0, 100) : null;
  }

  @override
  String toString() {
    return 'LanRailComDataChanged(locoAddress: $locoAddress, receiveCounter: $receiveCounter, errorCounter: $errorCounter, options: $options, speed: $speed, qos: $qos)';
  }
}

/// \todo document
class LanLoconetZ21Rx implements Command {}

/// \todo document
class LanLoconetZ21Tx implements Command {}

/// \todo document
class LanLoconetFromLan implements Command {}

/// \todo document
class LanLoconetDispatchAddr implements Command {}

/// \todo document
class LanLoconetDetector implements Command {}

/// \todo document
class LanCanDetector implements Command {}

/// \todo document
class ReplyToLanCanDeviceGetDescription implements Command {}

/// \todo document
class LanCanBoosterSystemStateChanged implements Command {}

/// \todo document
class LanFastClockData implements Command {}

/// \todo document
class LanFastClockSettingsGet implements Command {}

/// \todo document
class ReplyToLanBoosterGetDescription implements Command {}

/// \todo document
class LanBoosterSystemStateDataChanged implements Command {}

/// \todo document
class ReplyToLanDecoderGetDescription implements Command {}

/// \todo document
class LanDecoderSystemStateDataChanged implements Command {}

/// \todo document
class ReplyToLanZLinkGetHwInfo implements Command {}

/// \todo document
abstract interface class Z21Service {
  int? get closeCode;
  String? get closeReason;
  Future<void> get ready;
  Stream<Command> get stream;
  Future close([int? closeCode, String? closeReason]);

  void lanXGetStatus();
  void lanXSetTrackPowerOff();
  void lanXSetTrackPowerOn();
  void lanXCvRead(int cvAddress);
  void lanXCvWrite(int cvAddress, int byte);
  void lanXGetLocoInfo(int locoAddress);
  void lanXSetLocoDrive(int locoAddress, int speedSteps, int rvvvvvvv);
  void lanXSetLocoFunction(int locoAddress, int state, int index);
  void lanXCvPomWriteByte(int locoAddress, int cvAddress, int byte);
  void lanXCvPomReadByte(int locoAddress, int cvAddress);
  void lanSetBroadcastFlags(BroadcastFlags broadcastFlags);
  void lanSystemStateGetData();
  void lanRailComGetData(int locoAddress);

  /// \todo document
  static Command convert(Uint8List dataset) {
    if (dataset.length <= 4) return LanXUnknownCommand();

    switch (dataset[2]) {
      case Header.Reply_to_LAN_GET_SERIAL_NUMBER:
        return ReplyToLanGetSerialNumber();

      case Header.Reply_to_LAN_GET_CODE:
        return ReplyToLanGetCode();

      case Header.Reply_to_LAN_GET_HWINFO:
        return ReplyToLanGetHwInfo();

      case Header.LAN_X:
        if (exor(dataset.sublist(4)) != 0) break;
        switch (dataset[4]) {
          case XHeader.LAN_X_TURNOUT_INFO:
            return LanXTurnoutInfo();

          case XHeader.LAN_X_EXT_ACCESSORY_INFO:
            return LanXExtAccessoryInfo();

          case XHeader.LAN_X_61:
            if (dataset.length < 6) break;
            switch (dataset[5]) {
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
        return LanRailComDataChanged.fromDataset(dataset);

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
