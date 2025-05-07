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

part 'bidi.freezed.dart';
part 'bidi.g.dart';

@freezed
abstract class BiDi with _$BiDi {
  const factory BiDi({
    @Default(0)
    @JsonKey(name: 'receive_counter', defaultValue: 0)
    int receiveCounter,
    @Default(0)
    @JsonKey(name: 'error_counter', defaultValue: 0)
    int errorCounter,
    @Default(0) @JsonKey(name: 'options', defaultValue: 0) int options,
    @Default(0) @JsonKey(name: 'speed', defaultValue: 0) int speed,
    @Default(0) @JsonKey(name: 'qos', defaultValue: 0) int qos,
  }) = _BiDi;

  factory BiDi.fromJson(Map<String, dynamic> json) => _$BiDiFromJson(json);
}
