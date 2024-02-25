import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting.freezed.dart';
part 'setting.g.dart';

@freezed
class Setting with _$Setting {
  factory Setting({
    @JsonKey(name: 'sta_mdns') String? mdns,
    @JsonKey(name: 'sta_ssid') String? ssid,
    @JsonKey(name: 'sta_pass') String? password,
    @JsonKey(name: 'http_rx_timeout') int? httpReceiveTimeout,
    @JsonKey(name: 'http_tx_timeout') int? httpTransmitTimeout,
    @JsonKey(name: 'dcc_preamble') int? dccPreambleCount,
    @JsonKey(name: 'dcc_bit1_dur') int? dccBit1Duration,
    @JsonKey(name: 'dcc_bit0_dur') int? dccBit0Duration,
    @JsonKey(name: 'dcc_bidibit_dur') int? dccBiDiBitDuration,
  }) = _Setting;

  factory Setting.fromJson(Map<String, Object?> json) =>
      _$SettingFromJson(json);
}
