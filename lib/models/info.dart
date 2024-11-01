// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'info.freezed.dart';
part 'info.g.dart';

@freezed
class Info with _$Info {
  factory Info({
    required String state,
    required String version,
    @JsonKey(name: 'project_name') required String projectName,
    @JsonKey(name: 'compile_time') required String compileTime,
    @JsonKey(name: 'compile_date') required String compileDate,
    @JsonKey(name: 'idf_version') required String idfVersion,
    required String mdns,
    required String ip,
    required String mac,
    required int heap,
    @JsonKey(name: 'internal_heap') required int internalHeap,
    required int voltage,
    required int current,
    required double temperature,
  }) = _Info;

  factory Info.fromJson(Map<String, Object?> json) => _$InfoFromJson(json);
}
