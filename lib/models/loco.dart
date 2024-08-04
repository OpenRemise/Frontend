import 'package:freezed_annotation/freezed_annotation.dart';

part 'loco.freezed.dart';
part 'loco.g.dart';

@freezed
class Loco with _$Loco {
  factory Loco({
    required int address,
    @Default('') String name,
    @Default(0) int f31_0, // TODO 53bit width my become an issue?
    @Default(0x80) int rvvvvvvv,
    @JsonKey(name: 'speed_steps', defaultValue: 2) @Default(2) int speedSteps,
  }) = _Loco;

  factory Loco.fromJson(Map<String, Object?> json) => _$LocoFromJson(json);
}
