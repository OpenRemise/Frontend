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

import 'package:Frontend/model/loco.dart';
import 'package:Frontend/utility/exor.dart';

/// \todo document
int _bigEndianData2uint16(Uint8List data) {
  return data[0] << 8 | data[1] << 0;
}

/// \todo document
int _bigEndianData2int16(data) {
  return data[0] << 8 | data[1] << 0;
}

/// \todo document
int _littleEndianData2uint16(Uint8List data) {
  return data[1] << 8 | data[0] << 0;
}

/// \todo document
int _littleEndianData2uint32(Uint8List data) {
  return data[3] << 24 | data[2] << 16 | data[1] << 8 | data[0] << 0;
}

/// \todo document
int _bigEndianData2LocoAddress(Uint8List data) {
  return _bigEndianData2uint16(data) & 0x3FFF;
}

/// \todo document
int _bigEndianData2CvAddress(Uint8List data) {
  return _bigEndianData2uint16(data) & 0x03FF;
}

/// \todo document
int _bigEndianData2AccessoryAddress(Uint8List data) {
  return _bigEndianData2uint16(data) & 0x07FF;
}

/// \todo document
int _bigEndianLocoAddressMsb(int locoAddress) {
  return (locoAddress >= 128 ? 0xC0 : 0x00) | ((locoAddress >> 8) & 0xFF);
}

/// \todo document
int _bigEndianLocoAddressLsb(int locoAddress) {
  return (locoAddress >> 0) & 0xFF;
}

/// \todo document
int _bigEndianAccessoryAddressMsb(int accyAddress) {
  return (accyAddress >> 8) & 0xFF;
}

/// \todo document
int _bigEndianAccessoryAddressLsb(int accyAddress) {
  return (accyAddress >> 0) & 0xFF;
}

/// \todo document
int _littleEndianLocoAddressMsb(int locoAddress) {
  return _bigEndianLocoAddressLsb(locoAddress);
}

/// \todo document
int _littleEndianLocoAddressLsb(int locoAddress) {
  return (locoAddress >> 8) & 0xFF;
}

/// \todo document
int _stupidAccessoryAddressMsb(int accyAddress) {
  return (accyAddress >> 6) & 0xFF;
}

/// \todo document
int _stupidAccessoryAddressLsb(int accyAddress) {
  return ((accyAddress & 0x3C) << 2) | (accyAddress & 0x03);
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
class _Header {
  // Client to Z21
  static const int LAN_GET_SERIAL_NUMBER = 0x10;
  static const int LAN_GET_COMMON_SETTINGS = 0x12;
  static const int LAN_SET_COMMON_SETTINGS = 0x13;
  static const int LAN_GET_MMDCC_SETTINGS = 0x16;
  static const int LAN_SET_MMDCC_SETTINGS = 0x17;
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
  static const int Reply_to_LAN_GET_COMMON_SETTINGS = 0x12;
  static const int Reply_to_LAN_GET_MMDCC_SETTINGS = 0x16;
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
  static const int Reply_to_LAN_LOCONET_FROM_LAN = 0xA2;
  static const int Reply_to_LAN_LOCONET_DISPATCH_ADDR = 0xA3;
  static const int Reply_to_LAN_LOCONET_DETECTOR = 0xA4;
  static const int Reply_to_LAN_CAN_DETECTOR = 0xC4;
  static const int Reply_to_LAN_CAN_DEVICE_GET_DESCRIPTION = 0xC8;
  static const int LAN_CAN_BOOSTER_SYSTEMSTATE_CHANGED = 0xCA;
  static const int LAN_FAST_CLOCK_DATA = 0xCD;
  static const int Reply_to_LAN_FAST_CLOCK_SETTINGS_GET = 0xCE;
  static const int Reply_to_LAN_BOOSTER_GET_DESCRIPTION = 0xB8;
  static const int LAN_BOOSTER_SYSTEMSTATE_DATACHANGED = 0xBA;
  static const int Reply_to_LAN_DECODER_GET_DESCRIPTION = 0xD8;
  static const int LAN_DECODER_SYSTEMSTATE_DATACHANGED = 0xDA;
  static const int Reply_to_LAN_ZLINK_GET_HWINFO = 0xE8;

  const _Header._();
}

/// \todo document
class _XHeader {
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

  const _XHeader._();
}

/// \todo document
class _DB0 {
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

  const _DB0._();
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
sealed class Z21Command {
  Uint8List toUint8List() {
    return Uint8List(0);
  }
}

// Client to Z21

/// \todo document
class LanGetSerialNumber extends Z21Command {}

/// \todo document
class LanGetCommonSettings extends Z21Command {}

/// \todo document
class LanSetCommonSettings extends Z21Command {}

/// \todo document
class LanGetMmDccSettings extends Z21Command {}

/// \todo document
class LanSetMmDccSettings extends Z21Command {}

/// \todo document
class LanGetCode extends Z21Command {}

/// \todo document
class LanGetHwInfo extends Z21Command {}

/// \todo document
class LanLogoff extends Z21Command {}

/// \todo document
class LanXGetVersion extends Z21Command {}

/// \todo document
class LanXGetStatus implements Z21Command {
  @override
  Uint8List toUint8List() {
    return Uint8List.fromList([
      0x07,
      0x00,
      _Header.LAN_X_GET_STATUS,
      0x00,
      _XHeader.LAN_X_GET_STATUS,
      _DB0.LAN_X_GET_STATUS,
      0x05,
    ]);
  }

  @override
  String toString() {
    return 'LanXGetStatus()';
  }
}

/// \todo document
class LanXSetTrackPowerOff implements Z21Command {
  @override
  Uint8List toUint8List() {
    return Uint8List.fromList([
      0x07,
      0x00,
      _Header.LAN_X_SET_TRACK_POWER_OFF,
      0x00,
      _XHeader.LAN_X_SET_TRACK_POWER_OFF,
      _DB0.LAN_X_SET_TRACK_POWER_OFF,
      0xA1,
    ]);
  }

  @override
  String toString() {
    return 'LanXSetTrackPowerOff()';
  }
}

/// \todo document
class LanXSetTrackPowerOn implements Z21Command {
  @override
  Uint8List toUint8List() {
    return Uint8List.fromList([
      0x07,
      0x00,
      _Header.LAN_X_SET_TRACK_POWER_ON,
      0x00,
      _XHeader.LAN_X_SET_TRACK_POWER_ON,
      _DB0.LAN_X_SET_TRACK_POWER_ON,
      0xA0,
    ]);
  }

  @override
  String toString() {
    return 'LanXSetTrackPowerOn()';
  }
}

/// \todo document
class LanXDccReadRegister extends Z21Command {}

/// \todo document
class LanXCvRead implements Z21Command {
  final int cvAddress;

  LanXCvRead({required this.cvAddress}) {
    assert(cvAddress <= 1023);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x09,
      0x00,
      _Header.LAN_X_CV_READ,
      0x00,
      _XHeader.LAN_X_CV_READ,
      _DB0.LAN_X_CV_READ,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXCvRead(cvAddress: $cvAddress)';
  }
}

/// \todo document
class LanXDccWriteRegister extends Z21Command {}

/// \todo document
class LanXCvWrite implements Z21Command {
  final int cvAddress;
  final int value;

  LanXCvWrite({required this.cvAddress, required this.value}) {
    assert(cvAddress <= 1023 && value <= 255);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x0A,
      0x00,
      _Header.LAN_X_CV_WRITE,
      0x00,
      _XHeader.LAN_X_CV_WRITE,
      _DB0.LAN_X_CV_WRITE,
      (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      value & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXCvWrite(cvAddress: $cvAddress, value: $value)';
  }
}

/// \todo document
class LanXMmWriteByte extends Z21Command {}

/// \todo document
class LanXGetTurnoutInfo implements Z21Command {
  final int accyAddress;

  LanXGetTurnoutInfo({required this.accyAddress}) {
    assert(accyAddress < 2048);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x08,
      0x00,
      _Header.LAN_X_GET_TURNOUT_INFO,
      0x00,
      _XHeader.LAN_X_GET_TURNOUT_INFO,
      _bigEndianAccessoryAddressMsb(accyAddress),
      _bigEndianAccessoryAddressLsb(accyAddress),
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXGetTurnoutInfo(accyAddress: $accyAddress)';
  }
}

/// \todo document
class LanXGetExtAccessoryInfo extends Z21Command {}

/// \todo document
class LanXSetTurnout implements Z21Command {
  final int accyAddress;
  final bool p;
  final bool a;
  final bool q;

  LanXSetTurnout({
    required this.accyAddress,
    required this.p,
    required this.a,
    this.q = false,
  }) {
    assert(accyAddress < 2048);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x09,
      0x00,
      _Header.LAN_X_SET_TURNOUT,
      0x00,
      _XHeader.LAN_X_SET_TURNOUT,
      _bigEndianAccessoryAddressMsb(accyAddress),
      _bigEndianAccessoryAddressLsb(accyAddress),
      0x80 | (q ? 0x20 : 0x00) | (a ? 0x08 : 0x00) | (p ? 0x01 : 0x00),
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXSetTurnout(accyAddress: $accyAddress, p: $p, a: $a, q: $q)';
  }
}

/// \todo document
class LanXSetExtAccessory extends Z21Command {}

/// \todo document
class LanXSetStop extends Z21Command {}

/// \todo document
class LanXSetLocoEStop implements Z21Command {
  final int locoAddress;

  LanXSetLocoEStop({required this.locoAddress}) {
    assert(locoAddress <= 9999);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x08,
      0x00,
      _Header.LAN_X_SET_LOCO_E_STOP,
      0x00,
      _XHeader.LAN_X_SET_LOCO_E_STOP,
      _bigEndianLocoAddressMsb(locoAddress),
      _bigEndianLocoAddressLsb(locoAddress),
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXSetLocoEStop(locoAddress: $locoAddress)';
  }
}

/// \todo document
class LanXPurgeLoco extends Z21Command {}

/// \todo document
class LanXGetLocoInfo implements Z21Command {
  final int locoAddress;

  LanXGetLocoInfo({required this.locoAddress}) {
    assert(locoAddress <= 9999);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x09,
      0x00,
      _Header.LAN_X_GET_LOCO_INFO,
      0x00,
      _XHeader.LAN_X_GET_LOCO_INFO,
      _DB0.LAN_X_GET_LOCO_INFO,
      _bigEndianLocoAddressMsb(locoAddress),
      _bigEndianLocoAddressLsb(locoAddress),
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXGetLocoInfo(locoAddress: $locoAddress)';
  }
}

/// \todo document
class LanXSetLocoDrive extends Z21Command {
  final int locoAddress;
  final int speedSteps;
  final int rvvvvvvv;

  LanXSetLocoDrive({
    required this.locoAddress,
    required this.speedSteps,
    required this.rvvvvvvv,
  }) {
    assert(
      locoAddress <= 9999 &&
          [0, 2, 3, 4].contains(speedSteps) &&
          rvvvvvvv <= 0xFF,
    );
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x0A,
      0x00,
      _Header.LAN_X_SET_LOCO_DRIVE,
      0x00,
      _XHeader.LAN_X_SET_LOCO_DRIVE,
      speedSteps == 0
          ? _DB0.LAN_X_SET_LOCO_DRIVE_14
          : speedSteps == 2
              ? _DB0.LAN_X_SET_LOCO_DRIVE_28
              : _DB0.LAN_X_SET_LOCO_DRIVE_128,
      _bigEndianLocoAddressMsb(locoAddress),
      _bigEndianLocoAddressLsb(locoAddress),
      rvvvvvvv,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXSetLocoDrive(locoAddress: $locoAddress, speedSteps: $speedSteps, rvvvvvvv: $rvvvvvvv)';
  }
}

/// \todo document
class LanXSetLocoFunction extends Z21Command {
  final int locoAddress;
  final int state;
  final int index;

  LanXSetLocoFunction({
    required this.locoAddress,
    required this.state,
    required this.index,
  }) {
    assert(locoAddress <= 9999 && state <= 3 && index <= 0x3F);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x0A,
      0x00,
      _Header.LAN_X_SET_LOCO_FUNCTION,
      0x00,
      _XHeader.LAN_X_SET_LOCO_FUNCTION,
      _DB0.LAN_X_SET_LOCO_FUNCTION,
      _bigEndianLocoAddressMsb(locoAddress),
      _bigEndianLocoAddressLsb(locoAddress),
      state << 6 | index,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXSetLocoFunction(locoAddress: $locoAddress, state: $state, index: $index)';
  }
}

/// \todo document
class LanXSetLocoFunctionGroup extends Z21Command {}

/// \todo document
class LanXSetLocoBinaryState extends Z21Command {}

/// \todo document
class LanXCvPomWriteByte implements Z21Command {
  final int locoAddress;
  final int cvAddress;
  final int value;

  LanXCvPomWriteByte({
    required this.locoAddress,
    required this.cvAddress,
    required this.value,
  }) {
    assert(locoAddress <= 9999 && cvAddress <= 1023 && value <= 255);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x0C,
      0x00,
      _Header.LAN_X_CV_POM_WRITE_BYTE,
      0x00,
      _XHeader.LAN_X_CV_POM_WRITE_BYTE,
      _DB0.LAN_X_CV_POM_WRITE_BYTE,
      _bigEndianLocoAddressMsb(locoAddress),
      _bigEndianLocoAddressLsb(locoAddress),
      0xEC | (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      value & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXCvPomWriteByte(locoAddress: $locoAddress, cvAddress: $cvAddress, value: $value)';
  }
}

/// \todo document
class LanXCvPomWriteBit extends Z21Command {}

/// \todo document
class LanXCvPomReadByte implements Z21Command {
  final int locoAddress;
  final int cvAddress;

  LanXCvPomReadByte({required this.locoAddress, required this.cvAddress}) {
    assert(locoAddress <= 9999 && cvAddress <= 1023);
  }

  @override
  Uint8List toUint8List() {
    List<int> data = [
      0x0C,
      0x00,
      _Header.LAN_X_CV_POM_READ_BYTE,
      0x00,
      _XHeader.LAN_X_CV_POM_READ_BYTE,
      _DB0.LAN_X_CV_POM_READ_BYTE,
      _bigEndianLocoAddressMsb(locoAddress),
      _bigEndianLocoAddressLsb(locoAddress),
      0xE4 | (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      0 & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXCvPomReadByte(locoAddress: $locoAddress, cvAddress: $cvAddress)';
  }
}

/// \todo document
class LanXCvPomAccessoryWriteByte implements Z21Command {
  final int accyAddress;
  final int cvAddress;
  final int value;

  LanXCvPomAccessoryWriteByte({
    required this.accyAddress,
    required this.cvAddress,
    required this.value,
  }) {
    assert(accyAddress < 2048 && cvAddress <= 1023 && value <= 255);
  }

  @override
  Uint8List toUint8List() {
    const int c = 0x08;
    List<int> data = [
      0x0C,
      0x00,
      _Header.LAN_X_CV_POM_ACCESSORY_WRITE_BYTE,
      0x00,
      _XHeader.LAN_X_CV_POM_ACCESSORY_WRITE_BYTE,
      _DB0.LAN_X_CV_POM_ACCESSORY_WRITE_BYTE,
      _stupidAccessoryAddressMsb(accyAddress),
      _stupidAccessoryAddressLsb(accyAddress) | c,
      0xEC | (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      0 & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXCvPomAccessoryWriteByte(accyAddress: $accyAddress, cvAddress: $cvAddress, value: $value)';
  }
}

/// \todo document
class LanXCvPomAccessoryWriteBit extends Z21Command {}

/// \todo document
class LanXCvPomAccessoryReadByte implements Z21Command {
  final int accyAddress;
  final int cvAddress;

  LanXCvPomAccessoryReadByte({
    required this.accyAddress,
    required this.cvAddress,
  }) {
    assert(accyAddress < 2048 && cvAddress <= 1023);
  }

  @override
  Uint8List toUint8List() {
    const int c = 0x08;
    List<int> data = [
      0x0C,
      0x00,
      _Header.LAN_X_CV_POM_ACCESSORY_READ_BYTE,
      0x00,
      _XHeader.LAN_X_CV_POM_ACCESSORY_READ_BYTE,
      _DB0.LAN_X_CV_POM_ACCESSORY_READ_BYTE,
      _stupidAccessoryAddressMsb(accyAddress),
      _stupidAccessoryAddressLsb(accyAddress) | c,
      0xE4 | (cvAddress >> 8) & 0xFF,
      (cvAddress >> 0) & 0xFF,
      0 & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    return Uint8List.fromList(data);
  }

  @override
  String toString() {
    return 'LanXCvPomAccessoryReadByte(accyAddress: $accyAddress, cvAddress: $cvAddress)';
  }
}

/// \todo document
class LanXGetFirmwareVersion extends Z21Command {}

/// \todo document
class LanSetBroadcastFlags implements Z21Command {
  final BroadcastFlags broadcastFlags;

  LanSetBroadcastFlags({required this.broadcastFlags});

  @override
  Uint8List toUint8List() {
    return Uint8List.fromList(
      [
        0x08,
        0x00,
        _Header.LAN_SET_BROADCASTFLAGS,
        0x00,
        (broadcastFlags.value >> 0) & 0xFF,
        (broadcastFlags.value >> 8) & 0xFF,
        (broadcastFlags.value >> 16) & 0xFF,
        (broadcastFlags.value >> 24) & 0xFF,
      ],
    );
  }

  @override
  String toString() {
    return 'LanSetBroadcastFlags(broadcastFlags: $broadcastFlags)';
  }
}

/// \todo document
class LanGetBroadcastFlags extends Z21Command {}

/// \todo document
class LanGetLocoMode extends Z21Command {}

/// \todo document
class LanSetLocoMode extends Z21Command {}

/// \todo document
class LanGetTurnoutMode extends Z21Command {}

/// \todo document
class LanSetTurnoutMode extends Z21Command {}

/// \todo document
class LanRmBusGetData extends Z21Command {}

/// \todo document
class LanRmBusProgramModule extends Z21Command {}

/// \todo document
class LanSystemStateGetData implements Z21Command {
  @override
  Uint8List toUint8List() {
    return Uint8List.fromList(
      [0x04, 0x00, _Header.LAN_SYSTEMSTATE_GETDATA, 0x00],
    );
  }

  @override
  String toString() {
    return 'LanSystemStateGetData()';
  }
}

/// \todo document
class LanRailComGetData implements Z21Command {
  final int locoAddress;

  LanRailComGetData({required this.locoAddress}) {
    assert(locoAddress <= 9999);
  }

  @override
  Uint8List toUint8List() {
    return Uint8List.fromList(
      [
        0x07,
        0x00,
        _Header.LAN_RAILCOM_GETDATA,
        0x00,
        0x01,
        _littleEndianLocoAddressMsb(locoAddress), // Loco address
        _littleEndianLocoAddressLsb(locoAddress),
      ],
    );
  }

  @override
  String toString() {
    return 'LanRailComGetData(locoAddress: $locoAddress)';
  }
}

/// \todo document
class LanLocoNetFromLan extends Z21Command {}

/// \todo document
class LanLocoNetDispatchAddr extends Z21Command {}

/// \todo document
class LanLocoNetDetector extends Z21Command {}

/// \todo document
class LanCanDetector extends Z21Command {}

/// \todo document
class LanCanDeviceGetDescription extends Z21Command {}

/// \todo document
class LanCanDeviceSetDescription extends Z21Command {}

/// \todo document
class LanCanBoosterSetTrackPower extends Z21Command {}

/// \todo document
class LanFastClockControl extends Z21Command {}

/// \todo document
class LanFastClockSettingsGet extends Z21Command {}

/// \todo document
class LanFastClockSettingsSet extends Z21Command {}

/// \todo document
class LanBoosterSetPower extends Z21Command {}

/// \todo document
class LanBoosterGetDescription extends Z21Command {}

/// \todo document
class LanBoosterSetDescription extends Z21Command {}

/// \todo document
class LanBoosterSystemStateGetData extends Z21Command {}

/// \todo document
class LanDecoderGetDescription extends Z21Command {}

/// \todo document
class LanDecoderSetDescription extends Z21Command {}

/// \todo document
class LanDecoderSystemStateGetData extends Z21Command {}

/// \todo document
class LanZLinkGetHwInfo extends Z21Command {}

// Z21 to client

/// \todo document
class ReplyToLanGetSerialNumber extends Z21Command {}

/// \todo document
class ReplyToLanGetCommonSettings extends Z21Command {}

/// \todo document
class ReplyToLanGetMmDccSettings extends Z21Command {}

/// \todo document
class ReplyToLanGetCode extends Z21Command {}

/// \todo document
class ReplyToLanGetHwInfo extends Z21Command {}

/// \todo document
class LanXTurnoutInfo extends Z21Command {
  final int accyAddress;
  final int zz;

  LanXTurnoutInfo({
    required this.accyAddress,
    required this.zz,
  });

  LanXTurnoutInfo.fromUint8List(Uint8List dataset)
      : accyAddress = _bigEndianData2AccessoryAddress(dataset.sublist(5)),
        zz = dataset[7] {
    assert(dataset.length == 0x09);
  }

  @override
  String toString() {
    return 'LanXTurnoutInfo(accyAddress: $accyAddress, zz: $zz)';
  }
}

/// \todo document
class LanXExtAccessoryInfo extends Z21Command {}

/// \todo document
class LanXBcTrackPowerOff extends Z21Command {}

/// \todo document
class LanXBcTrackPowerOn extends Z21Command {}

/// \todo document
class LanXBcProgrammingMode extends Z21Command {}

/// \todo document
class LanXBcTrackShortCircuit extends Z21Command {}

/// \todo document
class LanXCvNackSc extends Z21Command {}

/// \todo document
class LanXCvNack extends Z21Command {}

/// \todo document
class LanXUnknownCommand extends Z21Command {}

/// \todo document
class LanXStatusChanged extends Z21Command {
  final int centralState;

  LanXStatusChanged({required this.centralState});

  LanXStatusChanged.fromUint8List(Uint8List dataset)
      : centralState = dataset[6] {
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
    return centralState & 0x20 != 0;
  }

  @override
  String toString() {
    return 'LanXStatusChanged(centralState: $centralState)';
  }
}

/// \todo document
class ReplyToLanXGetVersion extends Z21Command {}

/// \todo document
class LanXCvResult extends Z21Command {
  final int cvAddress;
  final int value;

  LanXCvResult({required this.cvAddress, required this.value});

  LanXCvResult.fromUint8List(Uint8List dataset)
      : cvAddress = _bigEndianData2CvAddress(dataset.sublist(6)),
        value = dataset[8] {
    assert(dataset.length == 0x0A);
  }

  @override
  String toString() {
    return 'LanXCvResult(cvAddress: $cvAddress, value: $value)';
  }
}

/// \todo document
class LanXBcStopped extends Z21Command {}

/// \todo document
class LanXLocoInfo extends Z21Command {
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

  LanXLocoInfo.fromUint8List(Uint8List dataset)
      : locoAddress = _bigEndianData2LocoAddress(dataset.sublist(5)),
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

  int speed() {
    return decodeRvvvvvvv(speedSteps, rvvvvvvv);
  }

  @override
  String toString() {
    return 'LanXLocoInfo(locoAddress: $locoAddress, mode: $mode, busy: $busy, speedSteps: $speedSteps, rvvvvvvv: $rvvvvvvv, doubleTraction: $doubleTraction, smartSearch: $smartSearch, f31_0: 0x${f31_0.toRadixString(16)})';
  }
}

/// \todo document
class ReplyToLanXGetFirmwareVersion extends Z21Command {}

/// \todo document
class ReplyToLanGetBroadcastFlags extends Z21Command {}

/// \todo document
class ReplyToLanGetLocoMode extends Z21Command {}

/// \todo document
class ReplyToLanGetTurnoutMode extends Z21Command {}

/// \todo document
class LanRmBusDataChanged extends Z21Command {}

/// \todo document
class LanSystemStateDataChanged extends LanXStatusChanged
    implements Z21Command {
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

  LanSystemStateDataChanged.fromUint8List(Uint8List dataset)
      : mainCurrent = _bigEndianData2int16(dataset.sublist(4)),
        progCurrent = _bigEndianData2int16(dataset.sublist(6)),
        filteredMainCurrent = _bigEndianData2int16(dataset.sublist(8)),
        temperature = _bigEndianData2int16(dataset.sublist(10)),
        supplyVoltage = _bigEndianData2uint16(dataset.sublist(12)),
        vccVoltage = _bigEndianData2uint16(dataset.sublist(14)),
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
class LanRailComDataChanged extends Z21Command {
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

  LanRailComDataChanged.fromUint8List(Uint8List dataset)
      : locoAddress = _littleEndianData2uint16(dataset.sublist(4)),
        receiveCounter = _littleEndianData2uint32(dataset.sublist(6)),
        errorCounter = _littleEndianData2uint16(dataset.sublist(10)),
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

  BiDi bidi() {
    return BiDi(options: options, speed: speed, qos: qos);
  }

  @override
  String toString() {
    return 'LanRailComDataChanged(locoAddress: $locoAddress, receiveCounter: $receiveCounter, errorCounter: $errorCounter, options: $options, speed: $speed, qos: $qos)';
  }
}

/// \todo document
class LanLocoNetZ21Rx extends Z21Command {}

/// \todo document
class LanLocoNetZ21Tx extends Z21Command {}

/// \todo document
class ReplyToLanLocoNetFromLan extends Z21Command {}

/// \todo document
class ReplyToLanLocoNetDispatchAddr extends Z21Command {}

/// \todo document
class ReplyToLanLocoNetDetector extends Z21Command {}

/// \todo document
class ReplyToLanCanDetector extends Z21Command {}

/// \todo document
class ReplyToLanCanDeviceGetDescription extends Z21Command {}

/// \todo document
class LanCanBoosterSystemStateChanged extends Z21Command {}

/// \todo document
class LanFastClockData extends Z21Command {}

/// \todo document
class ReplyToLanFastClockSettingsGet extends Z21Command {}

/// \todo document
class ReplyToLanBoosterGetDescription extends Z21Command {}

/// \todo document
class LanBoosterSystemStateDataChanged extends Z21Command {}

/// \todo document
class ReplyToLanDecoderGetDescription extends Z21Command {}

/// \todo document
class LanDecoderSystemStateDataChanged extends Z21Command {}

/// \todo document
class ReplyToLanZLinkGetHwInfo extends Z21Command {}

/// \todo document
abstract interface class Z21Service {
  int? get closeCode;
  String? get closeReason;
  Future<void> get ready;
  Stream<Z21Command> get stream;
  Future close([int? closeCode, String? closeReason]);

  void call(Z21Command command);

  /// \todo document
  static Z21Command convert(Uint8List dataset) {
    if (dataset.length <= 4) return LanXUnknownCommand();

    switch (dataset[2]) {
      case _Header.Reply_to_LAN_GET_SERIAL_NUMBER:
        return ReplyToLanGetSerialNumber();

      case _Header.Reply_to_LAN_GET_CODE:
        return ReplyToLanGetCode();

      case _Header.Reply_to_LAN_GET_HWINFO:
        return ReplyToLanGetHwInfo();

      case _Header.LAN_X:
        if (exor(dataset.sublist(4)) != 0) break;
        switch (dataset[4]) {
          case _XHeader.LAN_X_TURNOUT_INFO:
            return LanXTurnoutInfo.fromUint8List(dataset);

          case _XHeader.LAN_X_EXT_ACCESSORY_INFO:
            return LanXExtAccessoryInfo();

          case _XHeader.LAN_X_61:
            if (dataset.length < 6) break;
            switch (dataset[5]) {
              case _DB0.LAN_X_BC_TRACK_POWER_OFF:
                return LanXBcTrackPowerOff();

              case _DB0.LAN_X_BC_TRACK_POWER_ON:
                return LanXBcTrackPowerOn();

              case _DB0.LAN_X_BC_PROGRAMMING_MODE:
                return LanXBcProgrammingMode();

              case _DB0.LAN_X_BC_TRACK_SHORT_CIRCUIT:
                return LanXBcTrackShortCircuit();

              case _DB0.LAN_X_CV_NACK_SC:
                return LanXCvNackSc();

              case _DB0.LAN_X_CV_NACK:
                return LanXCvNack();

              case _DB0.LAN_X_UNKNOWN_COMMAND:
                break;

              default:
                break;
            }
            break;

          case _XHeader.LAN_X_STATUS_CHANGED:
            return LanXStatusChanged.fromUint8List(dataset);

          case _XHeader.Reply_to_LAN_X_GET_VERSION:
            return ReplyToLanXGetVersion();

          case _XHeader.LAN_X_CV_RESULT:
            return LanXCvResult.fromUint8List(dataset);

          case _XHeader.LAN_X_BC_STOPPED:
            return LanXBcStopped();

          case _XHeader.LAN_X_LOCO_INFO:
            return LanXLocoInfo.fromUint8List(dataset);

          case _XHeader.Reply_to_LAN_X_GET_FIRMWARE_VERSION:
            return ReplyToLanXGetFirmwareVersion();

          default:
            break;
        }
        break;

      case _Header.Reply_to_LAN_GET_BROADCASTFLAGS:
        return ReplyToLanGetBroadcastFlags();

      case _Header.Reply_to_LAN_GET_LOCOMODE:
        return ReplyToLanGetLocoMode();

      case _Header.Reply_to_LAN_GET_TURNOUTMODE:
        return ReplyToLanGetTurnoutMode();

      case _Header.LAN_RMBUS_DATACHANGED:
        return LanRmBusDataChanged();

      case _Header.LAN_SYSTEMSTATE_DATACHANGED:
        return LanSystemStateDataChanged.fromUint8List(dataset);

      case _Header.LAN_RAILCOM_DATACHANGED:
        return LanRailComDataChanged.fromUint8List(dataset);

      case _Header.LAN_LOCONET_Z21_RX:
        return LanLocoNetZ21Rx();

      case _Header.LAN_LOCONET_Z21_TX:
        return LanLocoNetZ21Tx();

      case _Header.Reply_to_LAN_LOCONET_FROM_LAN:
        return ReplyToLanLocoNetFromLan();

      case _Header.Reply_to_LAN_LOCONET_DISPATCH_ADDR:
        return ReplyToLanLocoNetDispatchAddr();

      case _Header.Reply_to_LAN_LOCONET_DETECTOR:
        return ReplyToLanLocoNetDetector();

      case _Header.Reply_to_LAN_CAN_DETECTOR:
        return ReplyToLanCanDetector();

      case _Header.Reply_to_LAN_CAN_DEVICE_GET_DESCRIPTION:
        return ReplyToLanCanDeviceGetDescription();

      case _Header.LAN_CAN_BOOSTER_SYSTEMSTATE_CHANGED:
        return LanCanBoosterSystemStateChanged();

      case _Header.LAN_FAST_CLOCK_DATA:
        return LanFastClockData();

      case _Header.Reply_to_LAN_FAST_CLOCK_SETTINGS_GET:
        return ReplyToLanFastClockSettingsGet();

      case _Header.Reply_to_LAN_BOOSTER_GET_DESCRIPTION:
        return ReplyToLanBoosterGetDescription();

      case _Header.LAN_BOOSTER_SYSTEMSTATE_DATACHANGED:
        return LanBoosterSystemStateDataChanged();

      case _Header.Reply_to_LAN_DECODER_GET_DESCRIPTION:
        return ReplyToLanDecoderGetDescription();

      case _Header.LAN_DECODER_SYSTEMSTATE_DATACHANGED:
        return LanDecoderSystemStateDataChanged();

      case _Header.Reply_to_LAN_ZLINK_GET_HWINFO:
        return ReplyToLanZLinkGetHwInfo();

      default:
        break;
    }

    return LanXUnknownCommand();
  }
}
