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

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

/// \todo document
@freezed
abstract class Config with _$Config {
  const factory Config({
    @JsonKey(name: 'sta_mdns') String? stationMdns,
    @JsonKey(name: 'sta_ssid') String? stationSsid,
    @JsonKey(name: 'sta_pass') String? stationPassword,
    @JsonKey(name: 'sta_alt_ssid') String? stationAlternativeSsid,
    @JsonKey(name: 'sta_alt_pass') String? stationAlternativePassword,
    @JsonKey(name: 'sta_ip') String? stationIp,
    @JsonKey(name: 'sta_netmask') String? stationNetmask,
    @JsonKey(name: 'sta_gateway') String? stationGateway,
    @Default(5) @JsonKey(name: 'http_rx_timeout') int httpReceiveTimeout,
    @Default(5) @JsonKey(name: 'http_tx_timeout') int httpTransmitTimeout,
    @Default(true) @JsonKey(name: 'http_exit_msg') bool httpExitMessage,
    @Default(3) @JsonKey(name: 'cur_lim') int currentLimit,
    @Default(1) @JsonKey(name: 'cur_lim_serv') int currentLimitService,
    @Default(100) @JsonKey(name: 'cur_sc_time') int currentShortCircuitTime,
    @Default(5) @JsonKey(name: 'led_dc_bug') int ledDutyCycleBug,
    @Default(50) @JsonKey(name: 'led_dc_wifi') int ledDutyCycleWiFi,
    @Default(17) @JsonKey(name: 'dcc_preamble') int dccPreamble,
    @Default(58) @JsonKey(name: 'dcc_bit1_dur') int dccBit1Duration,
    @Default(100) @JsonKey(name: 'dcc_bit0_dur') int dccBit0Duration,
    @Default(60) @JsonKey(name: 'dcc_bidibit_dur') int dccBiDiBitDuration,
    @Default(3) @JsonKey(name: 'dcc_prog_type') int dccProgrammingType,
    @Default(25)
    @JsonKey(name: 'dcc_strtp_rs_pc')
    int dccStartupResetPacketCount,
    @Default(6)
    @JsonKey(name: 'dcc_cntn_rs_pc')
    int dccContinueResetPacketCount,
    @Default(7) @JsonKey(name: 'dcc_prog_pc') int dccProgramPacketCount,
    @Default(true) @JsonKey(name: 'dcc_verify_bit1') bool dccBitVerifyTo1,
    @Default(50) @JsonKey(name: 'dcc_ack_cur') int dccProgrammingAckCurrent,
    @Default(0xE2) // 0x80 | 0x40 | 0x20
    @JsonKey(name: 'dcc_loco_flags')
    int dccLocoFlags,
    @Default(0x04) @JsonKey(name: 'dcc_accy_flags') int dccAccessoryFlags,
    @Default(20) @JsonKey(name: 'dcc_accy_swtime') int dccAccessorySwitchTime,
    @Default(2) @JsonKey(name: 'dcc_accy_pc') int dccAccessoryPacketCount,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);
}
