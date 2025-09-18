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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'loco.freezed.dart';
part 'loco.g.dart';

/// \todo document
@freezed
abstract class Loco with _$Loco implements Comparable<Loco> {
  const Loco._();

  const factory Loco({
    @JsonKey(name: 'address') required int address,
    @Default('') @JsonKey(name: 'name') String name,
    @Default(0) @JsonKey(name: 'mode') int mode,
    @Default(false) @JsonKey(name: 'busy') bool busy,
    @Default(4) @JsonKey(name: 'speed_steps') int speedSteps,
    @Default(0x80) @JsonKey(name: 'rvvvvvvv') int rvvvvvvv,
    @Default(0) @JsonKey(name: 'f31_0') int f31_0,
    @JsonKey(name: 'bidi') BiDi? bidi,
  }) = _Loco;

  factory Loco.fromJson(Map<String, Object?> json) => _$LocoFromJson(json);

  @override
  int compareTo(Loco other) {
    return address.compareTo(other.address);
  }
}

@freezed
abstract class BiDi with _$BiDi {
  const factory BiDi({
    @Default(0) @JsonKey(name: 'receive_counter') int receiveCounter,
    @Default(0) @JsonKey(name: 'error_counter') int errorCounter,
    @Default(0) @JsonKey(name: 'options') int options,
    @Default(0) @JsonKey(name: 'speed') int speed,
    @Default(0) @JsonKey(name: 'qos') int qos,
  }) = _BiDi;

  factory BiDi.fromJson(Map<String, dynamic> json) => _$BiDiFromJson(json);
}
