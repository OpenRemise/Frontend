// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

@freezed
class Config with _$Config {
  factory Config({
    @JsonKey(name: 'sta_mdns') String? mdns,
    @JsonKey(name: 'sta_ssid') String? ssid,
    @JsonKey(name: 'sta_pass') String? password,
    @JsonKey(name: 'http_rx_timeout') int? httpReceiveTimeout,
    @JsonKey(name: 'http_tx_timeout') int? httpTransmitTimeout,
    @JsonKey(name: 'usb_rx_timeout') int? usbReceiveTimeout,
    @JsonKey(name: 'current_limit') int? currentLimit,
    @JsonKey(name: 'dcc_preamble') int? dccPreamble,
    @JsonKey(name: 'dcc_bit1_dur') int? dccBit1Duration,
    @JsonKey(name: 'dcc_bit0_dur') int? dccBit0Duration,
    @JsonKey(name: 'dcc_bidibit_dur') int? dccBiDiBitDuration,
    @JsonKey(name: 'mdu_preamble') int? mduPreamble,
    @JsonKey(name: 'mdu_ackreq') int? mduAckreq,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);
}
