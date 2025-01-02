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

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

/// \todo document
@freezed
class Config with _$Config {
  factory Config({
    @JsonKey(name: 'sta_mdns') String? mdns,
    @JsonKey(name: 'sta_ssid') String? ssid,
    @JsonKey(name: 'sta_pass') String? password,
    @JsonKey(name: 'http_rx_timeout') int? httpReceiveTimeout,
    @JsonKey(name: 'http_tx_timeout') int? httpTransmitTimeout,
    @JsonKey(name: 'cur_lim') int? currentLimit,
    @JsonKey(name: 'cur_lim_serv') int? currentLimitService,
    @JsonKey(name: 'cur_sc_time') int? currentShortCircuitTime,
    @JsonKey(name: 'dcc_preamble') int? dccPreamble,
    @JsonKey(name: 'dcc_bit1_dur') int? dccBit1Duration,
    @JsonKey(name: 'dcc_bit0_dur') int? dccBit0Duration,
    @JsonKey(name: 'dcc_bidibit_dur') int? dccBiDiBitDuration,
    @JsonKey(name: 'dcc_prog_type') int? dccProgrammingType,
    @JsonKey(name: 'dcc_strtp_rs_pc') int? dccStartupResetPacketCount,
    @JsonKey(name: 'dcc_cntn_rs_pc') int? dccContinueResetPacketCount,
    @JsonKey(name: 'dcc_prog_pc') int? dccProgramPacketCount,
    @JsonKey(name: 'dcc_verify_bit1') bool? dccBitVerifyTo1,
    @JsonKey(name: 'dcc_ack_cur') int? dccProgrammingAckCurrent,
    @JsonKey(name: 'dcc_flags') int? dccFlags,
    @JsonKey(name: 'mdu_preamble') int? mduPreamble,
    @JsonKey(name: 'mdu_ackreq') int? mduAckreq,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);
}
