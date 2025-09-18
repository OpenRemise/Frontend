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

import 'package:Frontend/model/config.dart';
import 'package:Frontend/service/settings_service.dart';

class FakeSettingsService implements SettingsService {
  Config _config = Config(
    stationMdns: 'remise',
    stationSsid: 'FakeSSID',
    stationPassword: '************',
    stationAlternativeSsid: '',
    stationAlternativePassword: '',
    stationIp: '',
    stationNetmask: '',
    stationGateway: '',
    httpReceiveTimeout: 5,
    httpTransmitTimeout: 5,
    httpExitMessage: true,
    currentLimit: 3,
    currentLimitService: 1,
    currentShortCircuitTime: 100,
    ledDutyCycleBug: 5,
    ledDutyCycleWiFi: 50,
    dccPreamble: 17,
    dccBit1Duration: 58,
    dccBit0Duration: 100,
    dccBiDiBitDuration: 60,
    dccProgrammingType: 3,
    dccStartupResetPacketCount: 25,
    dccContinueResetPacketCount: 6,
    dccProgramPacketCount: 7,
    dccBitVerifyTo1: true,
    dccProgrammingAckCurrent: 50,
    dccLocoFlags: 0x80 | 0x40 | 0x20 | 0x02,
    dccAccyFlags: 0x04,
    dccAccySwitchTime: 5,
  );

  @override
  Future<Config> fetch() {
    return Future.delayed(const Duration(milliseconds: 500), () => _config);
  }

  @override
  Future<void> update(Config config) {
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => _config = Config(
        stationMdns: config.stationMdns ?? _config.stationMdns,
        stationSsid: config.stationSsid ?? _config.stationSsid,
        stationPassword: List.filled(
          (config.stationPassword ?? _config.stationPassword)!.length,
          '*',
        ).join(),
        stationAlternativeSsid:
            config.stationAlternativeSsid ?? _config.stationAlternativeSsid,
        stationAlternativePassword: List.filled(
          (config.stationAlternativePassword ??
                  _config.stationAlternativePassword)!
              .length,
          '*',
        ).join(),
        stationIp: config.stationIp ?? _config.stationIp,
        stationNetmask: config.stationNetmask ?? _config.stationNetmask,
        stationGateway: config.stationGateway ?? _config.stationGateway,
        httpReceiveTimeout: config.httpReceiveTimeout,
        httpTransmitTimeout: config.httpTransmitTimeout,
        httpExitMessage: config.httpExitMessage,
        currentLimit: config.currentLimit,
        currentLimitService: config.currentLimitService,
        currentShortCircuitTime: config.currentShortCircuitTime,
        ledDutyCycleBug: config.ledDutyCycleBug,
        ledDutyCycleWiFi: config.ledDutyCycleWiFi,
        dccPreamble: config.dccPreamble,
        dccBit1Duration: config.dccBit1Duration,
        dccBit0Duration: config.dccBit0Duration,
        dccBiDiBitDuration: config.dccBiDiBitDuration,
        dccProgrammingType: config.dccProgrammingType,
        dccStartupResetPacketCount: config.dccStartupResetPacketCount,
        dccContinueResetPacketCount: config.dccContinueResetPacketCount,
        dccProgramPacketCount: config.dccProgramPacketCount,
        dccBitVerifyTo1: config.dccBitVerifyTo1,
        dccProgrammingAckCurrent: config.dccProgrammingAckCurrent,
        dccLocoFlags: config.dccLocoFlags,
        dccAccyFlags: config.dccAccyFlags,
        dccAccySwitchTime: config.dccAccySwitchTime,
      ),
    );
  }
}
