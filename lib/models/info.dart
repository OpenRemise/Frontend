import 'package:freezed_annotation/freezed_annotation.dart';

part 'info.freezed.dart';
part 'info.g.dart';

@freezed
class Info with _$Info {
  factory Info({
    required String mode,
    String? version,
    @JsonKey(name: 'idf_version') String? idfVersion,
    @JsonKey(name: 'compile_date') String? compileDate,
    String? ip,
    String? mac,
    int? heap,
    @JsonKey(name: 'internal_heap') int? internalHeap,
    int? voltage,
    int? current,
    double? temperature,
  }) = _Info;

  factory Info.fromJson(Map<String, Object?> json) => _$InfoFromJson(json);
}
