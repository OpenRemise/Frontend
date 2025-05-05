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
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'version') String? version,
    @JsonKey(name: 'project_name') String? projectName,
    @JsonKey(name: 'compile_time') String? compileTime,
    @JsonKey(name: 'compile_date') String? compileDate,
    @JsonKey(name: 'idf_version') String? idfVersion,
    @JsonKey(name: 'mdns') String? mdns,
    @JsonKey(name: 'ip') String? ip,
    @JsonKey(name: 'mac') String? mac,
    @JsonKey(name: 'rssi') int? rssi,
    @JsonKey(name: 'voltage') int? voltage,
    @JsonKey(name: 'current') int? current,
    @JsonKey(name: 'temperature') double? temperature,
    @JsonKey(name: 'heap') int? heap,
    @JsonKey(name: 'internalHeap') int? internalHeap,
  }) = _Info;

  factory Info.fromJson(Map<String, Object?> json) => _$InfoFromJson(json);
}
