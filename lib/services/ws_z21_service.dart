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

import 'package:Frontend/services/z21_service.dart';
import 'package:Frontend/utilities/exor.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsZ21Service implements Z21Service {
  late final WebSocketChannel _channel;
  late final Stream<Command> _stream;

  WsZ21Service(String domain) {
    debugPrint('WsZ21Service ctor');
    _channel = WebSocketChannel.connect(Uri.parse('ws://$domain/z21/'));
    _stream = _channel.stream
        .asBroadcastStream()
        .cast<Uint8List>()
        .map(Z21Service.convert);
  }

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Command> get stream => _stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  @override
  void lanXGetStatus() {
    _channel.sink.add(
      Uint8List.fromList([
        0x07,
        0x00,
        Header.LAN_X_GET_STATUS.value,
        0x00,
        XHeader.LAN_X_GET_STATUS.value,
        DB0.LAN_X_GET_STATUS.value,
        0x05,
      ]),
    );
  }

  @override
  void lanXSetTrackPowerOff() {
    _channel.sink.add(
      Uint8List.fromList([
        0x07,
        0x00,
        Header.LAN_X_SET_TRACK_POWER_OFF.value,
        0x00,
        XHeader.LAN_X_SET_TRACK_POWER_OFF.value,
        DB0.LAN_X_SET_TRACK_POWER_OFF.value,
        0xA1,
      ]),
    );
  }

  @override
  void lanXSetTrackPowerOn() {
    _channel.sink.add(
      Uint8List.fromList([
        0x07,
        0x00,
        Header.LAN_X_SET_TRACK_POWER_ON.value,
        0x00,
        XHeader.LAN_X_SET_TRACK_POWER_ON.value,
        DB0.LAN_X_SET_TRACK_POWER_ON.value,
        0xA0,
      ]),
    );
  }

  @override
  void lanXCvRead(int cvAddress) {
    assert(cvAddress <= 1024);
    List<int> data = [
      0x09,
      0x00,
      Header.LAN_X_CV_READ.value,
      0x00,
      XHeader.LAN_X_CV_READ.value,
      DB0.LAN_X_CV_READ.value,
      (cvAddress >> 8) & 0xFF, // CV address
      (cvAddress >> 0) & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void lanXCvWrite(int cvAddress, int byte) {
    assert(cvAddress <= 1024 && byte <= 255);
    List<int> data = [
      0x0A,
      0x00,
      Header.LAN_X_CV_WRITE.value,
      0x00,
      XHeader.LAN_X_CV_WRITE.value,
      DB0.LAN_X_CV_WRITE.value,
      (cvAddress >> 8) & 0xFF, // CV address
      (cvAddress >> 0) & 0xFF,
      byte & 0xFF, // CV value
    ];
    data.add(exor(data.sublist(4)));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void lanXGetLocoInfo(int locoAddress) {
    assert(locoAddress <= 9999);
    List<int> data = [
      0x09,
      0x00,
      Header.LAN_X_GET_LOCO_INFO.value,
      0x00,
      XHeader.LAN_X_GET_LOCO_INFO.value,
      DB0.LAN_X_GET_LOCO_INFO.value,
      (locoAddress >> 8) & 0xFF, // Loco address
      (locoAddress >> 0) & 0xFF,
    ];
    data.add(exor(data.sublist(4)));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void lanXSetLocoDrive(int locoAddress, int speedSteps, int rvvvvvvv) {
    assert(
      locoAddress <= 9999 && [0, 2, 3].contains(speedSteps) && rvvvvvvv <= 0xFF,
    );
    List<int> data = [
      0x0A,
      0x00,
      Header.LAN_X_SET_LOCO_DRIVE.value,
      0x00,
      XHeader.LAN_X_SET_LOCO_DRIVE.value,
      speedSteps == 0
          ? DB0.LAN_X_SET_LOCO_DRIVE_14.value
          : speedSteps == 2
              ? DB0.LAN_X_SET_LOCO_DRIVE_28.value
              : DB0.LAN_X_SET_LOCO_DRIVE_128.value,
      (locoAddress >> 8) & 0xFF, // Loco address
      (locoAddress >> 0) & 0xFF,
      rvvvvvvv,
    ];
    data.add(exor(data.sublist(4)));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void lanXSetLocoFunction(int locoAddress, int state, int index) {
    assert(locoAddress <= 9999 && state <= 3 && index <= 0x3F);
    List<int> data = [
      0x0A,
      0x00,
      Header.LAN_X_SET_LOCO_FUNCTION.value,
      0x00,
      XHeader.LAN_X_SET_LOCO_FUNCTION.value,
      DB0.LAN_X_SET_LOCO_FUNCTION.value,
      (locoAddress >> 8) & 0xFF, // Loco address
      (locoAddress >> 0) & 0xFF,
      state << 6 | index,
    ];
    data.add(exor(data.sublist(4)));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void lanXCvPomWriteByte(int locoAddress, int cvAddress, int byte) {
    assert(locoAddress <= 9999 && cvAddress <= 1024 && byte <= 255);
    List<int> data = [
      0x0C,
      0x00,
      Header.LAN_X_CV_POM_WRITE_BYTE.value,
      0x00,
      XHeader.LAN_X_CV_POM_WRITE_BYTE.value,
      DB0.LAN_X_CV_POM_WRITE_BYTE.value,
      (locoAddress >> 8) & 0xFF, // Loco address
      (locoAddress >> 0) & 0xFF,
      0xEC | (cvAddress >> 8) & 0xFF, // CV address
      (cvAddress >> 0) & 0xFF, //
      byte & 0xFF, // CV value
    ];
    data.add(exor(data.sublist(4)));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void lanXCvPomReadByte(int locoAddress, int cvAddress) {
    assert(locoAddress <= 9999 && cvAddress <= 1024);
    List<int> data = [
      0x0C,
      0x00,
      Header.LAN_X_CV_POM_READ_BYTE.value,
      0x00,
      XHeader.LAN_X_CV_POM_READ_BYTE.value,
      DB0.LAN_X_CV_POM_READ_BYTE.value,
      (locoAddress >> 8) & 0xFF, // Loco address
      (locoAddress >> 0) & 0xFF,
      0xE4 | (cvAddress >> 8) & 0xFF, // CV address
      (cvAddress >> 0) & 0xFF, //
      0 & 0xFF, // CV value
    ];
    data.add(exor(data.sublist(4)));
    _channel.sink.add(Uint8List.fromList(data));
  }

  @override
  void lanSystemStateGetData() {
    _channel.sink.add(
      Uint8List.fromList(
        [0x04, 0x00, Header.LAN_SYSTEMSTATE_GETDATA.value, 0x00],
      ),
    );
  }
}
