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

import 'package:Frontend/models/config.dart';
import 'package:Frontend/services/settings_service.dart';

class FakeSettingsService implements SettingsService {
  Config _config = Config(
    mdns: 'remise',
    ssid: 'FakeSSID',
    password: '************',
    alternativeSsid: '',
    alternativePassword: '',
    httpReceiveTimeout: 5,
    httpTransmitTimeout: 5,
    currentLimit: 3,
    currentLimitService: 1,
    currentLimitUpdate: 0,
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
        mdns: config.mdns ?? _config.mdns,
        ssid: config.ssid ?? _config.ssid,
        password:
            List.filled((config.password ?? _config.password)!.length, '*')
                .join(),
        alternativeSsid: config.alternativeSsid ?? _config.alternativeSsid,
        alternativePassword: List.filled(
          (config.alternativePassword ?? _config.alternativePassword)!.length,
          '*',
        ).join(),
        httpReceiveTimeout:
            config.httpReceiveTimeout ?? _config.httpReceiveTimeout,
        httpTransmitTimeout:
            config.httpTransmitTimeout ?? _config.httpTransmitTimeout,
        currentLimit: config.currentLimit ?? _config.currentLimit,
        currentLimitService:
            config.currentLimitService ?? _config.currentLimitService,
        currentLimitUpdate:
            config.currentLimitUpdate ?? _config.currentLimitUpdate,
        currentShortCircuitTime:
            config.currentShortCircuitTime ?? _config.currentShortCircuitTime,
        ledDutyCycleBug: config.ledDutyCycleBug ?? _config.ledDutyCycleBug,
        ledDutyCycleWiFi: config.ledDutyCycleWiFi ?? _config.ledDutyCycleWiFi,
        dccPreamble: config.dccPreamble ?? _config.dccPreamble,
        dccBit1Duration: config.dccBit1Duration ?? _config.dccBit1Duration,
        dccBit0Duration: config.dccBit0Duration ?? _config.dccBit0Duration,
        dccBiDiBitDuration:
            config.dccBiDiBitDuration ?? _config.dccBiDiBitDuration,
        dccProgrammingType:
            config.dccProgrammingType ?? _config.dccProgrammingType,
        dccStartupResetPacketCount: config.dccStartupResetPacketCount ??
            _config.dccStartupResetPacketCount,
        dccContinueResetPacketCount: config.dccContinueResetPacketCount ??
            _config.dccContinueResetPacketCount,
        dccProgramPacketCount:
            config.dccProgramPacketCount ?? _config.dccProgramPacketCount,
        dccBitVerifyTo1: config.dccBitVerifyTo1 ?? _config.dccBitVerifyTo1,
        dccProgrammingAckCurrent:
            config.dccProgrammingAckCurrent ?? _config.dccProgrammingAckCurrent,
        dccLocoFlags: config.dccLocoFlags ?? _config.dccLocoFlags,
        dccAccyFlags: config.dccAccyFlags ?? _config.dccAccyFlags,
      ),
    );
  }
}
