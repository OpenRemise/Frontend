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

part 'info.freezed.dart';
part 'info.g.dart';

/// \todo document
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
