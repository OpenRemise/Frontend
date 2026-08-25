// Copyright (C) 2026 Vincent Hamp
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

part 'condition.freezed.dart';
part 'condition.g.dart';

/// Rule that applies [value] to a target once all [conditions] match
///
/// Mirrors TriggerType of commonTypes.xsd. All conditions of a trigger are
/// combined with a logical and.
@freezed
abstract class Trigger with _$Trigger {
  const factory Trigger({
    @JsonKey(name: 'value') required String value,
    @JsonKey(name: 'target') String? target,
    @Default([]) @JsonKey(name: 'conditions') List<Condition> conditions,
  }) = _Trigger;

  factory Trigger.fromJson(Map<String, Object?> json) =>
      _$TriggerFromJson(json);
}

/// Single check against a CV value, a decoder name or a nested condition tree
///
/// Mirrors ConditionType of commonTypes.xsd. [cv], [value] and [selection] are
/// transported as strings even where they denote numbers. A [ConditionType.logical]
/// condition carries no operands of its own and instead combines [conditions].
@freezed
abstract class Condition with _$Condition {
  const factory Condition({
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'operation') required String operation,
    @JsonKey(name: 'cv') String? cv,
    @JsonKey(name: 'value') String? value,
    @JsonKey(name: 'selection') String? selection,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
    @Default([]) @JsonKey(name: 'conditions') List<Condition> conditions,
  }) = _Condition;

  factory Condition.fromJson(Map<String, Object?> json) =>
      _$ConditionFromJson(json);
}
