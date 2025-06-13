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

import 'package:Frontend/model/bidi.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'loco.freezed.dart';
part 'loco.g.dart';

/// \todo document
@freezed
abstract class Loco with _$Loco implements Comparable<Loco> {
  const Loco._();

  const factory Loco({
    @JsonKey(name: 'address') required int address,
    @Default('') @JsonKey(name: 'name', defaultValue: '') String name,
    @Default(0) @JsonKey(name: 'mode', defaultValue: 0) int mode,
    @Default(false) @JsonKey(name: 'busy', defaultValue: false) bool busy,
    @Default(4) @JsonKey(name: 'speed_steps', defaultValue: 4) int speedSteps,
    @JsonKey(name: 'rvvvvvvv') int? rvvvvvvv,
    @JsonKey(name: 'f31_0') int? f31_0,
    @JsonKey(name: 'bidi') BiDi? bidi,
  }) = _Loco;

  factory Loco.fromJson(Map<String, Object?> json) => _$LocoFromJson(json);

  @override
  int compareTo(Loco other) {
    return address.compareTo(other.address);
  }
}
