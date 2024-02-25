import 'package:freezed_annotation/freezed_annotation.dart';

part 'loco.freezed.dart';
part 'loco.g.dart';

@freezed
class Loco with _$Loco {
  factory Loco({
    required int address,
    @Default('') String name,
    @Default(0) int functions, // TODO 53bit width my become an issue?
    @Default(0) int speed,
    @Default(1) int dir,
  }) = _Loco;

  factory Loco.fromJson(Map<String, Object?> json) => _$LocoFromJson(json);
}
