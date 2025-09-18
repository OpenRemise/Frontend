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

part 'info.freezed.dart';
part 'info.g.dart';

/// \todo document
@freezed
abstract class Info with _$Info {
  const factory Info({
    @JsonKey(name: 'state') required String state,
    @JsonKey(name: 'version') required String version,
    @JsonKey(name: 'project_name') required String projectName,
    @JsonKey(name: 'compile_time') required String compileTime,
    @JsonKey(name: 'compile_date') required String compileDate,
    @JsonKey(name: 'idf_version') required String idfVersion,
    @JsonKey(name: 'mdns') required String mdns,
    @JsonKey(name: 'ip') required String ip,
    @JsonKey(name: 'mac') required String mac,
    @Default(0) @JsonKey(name: 'rssi') int rssi,
    @Default(0) @JsonKey(name: 'voltage') int voltage,
    @Default(0) @JsonKey(name: 'current') int current,
    @Default(0.0) @JsonKey(name: 'temperature') double temperature,
    @JsonKey(name: 'heap') required int heap,
    @JsonKey(name: 'internal_heap') required int internalHeap,
  }) = _Info;

  factory Info.fromJson(Map<String, Object?> json) => _$InfoFromJson(json);
}
