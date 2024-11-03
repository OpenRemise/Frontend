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
