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

part 'common_types.freezed.dart';
part 'common_types.g.dart';

/// Version metadata common to all DecoderDB files
@freezed
abstract class Version with _$Version {
  const factory Version({
    @JsonKey(name: 'createdBy') String? createdBy,
    @JsonKey(name: 'creatorLink') String? creatorLink,
    @JsonKey(name: 'author') String? author,
    @JsonKey(name: 'lastUpdate') required String lastUpdate,
    @JsonKey(name: 'created') String? created,
  }) = _Version;

  factory Version.fromJson(Map<String, Object?> json) =>
      _$VersionFromJson(json);
}

/// Localized description with optional help text
@freezed
abstract class Description with _$Description {
  const factory Description({
    @JsonKey(name: 'language') required String language,
    @JsonKey(name: 'text') required String text,
    @JsonKey(name: 'help') String? help,
  }) = _Description;

  factory Description.fromJson(Map<String, Object?> json) =>
      _$DescriptionFromJson(json);
}

/// Simple CV reference used in detection entries
@freezed
abstract class DetectionCv with _$DetectionCv {
  const factory DetectionCv({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'mode') String? mode,
  }) = _DetectionCv;

  factory DetectionCv.fromJson(Map<String, Object?> json) =>
      _$DetectionCvFromJson(json);
}

/// Simple CV group reference used in detection entries
@freezed
abstract class DetectionCvGroup with _$DetectionCvGroup {
  const factory DetectionCvGroup({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'mode') String? mode,
    @Default([]) @JsonKey(name: 'cv') List<DetectionCv> cvs,
  }) = _DetectionCvGroup;

  factory DetectionCvGroup.fromJson(Map<String, Object?> json) =>
      _$DetectionCvGroupFromJson(json);
}

/// Condition group containing a list of triggers
@freezed
abstract class Condition with _$Condition {
  const factory Condition({
    @Default([]) @JsonKey(name: 'trigger') List<ConditionTrigger> triggers,
  }) = _Condition;

  factory Condition.fromJson(Map<String, Object?> json) =>
      _$ConditionFromJson(json);
}

/// Trigger within a condition, specifying when the condition applies
@freezed
abstract class ConditionTrigger with _$ConditionTrigger {
  const factory ConditionTrigger({
    @JsonKey(name: 'value') required String value,
    @JsonKey(name: 'target') String? target,
    @Default([]) @JsonKey(name: 'condition') List<TriggerCondition> conditions,
  }) = _ConditionTrigger;

  factory ConditionTrigger.fromJson(Map<String, Object?> json) =>
      _$ConditionTriggerFromJson(json);
}

/// Individual condition expression. Can be recursive for logical operations.
@freezed
abstract class TriggerCondition with _$TriggerCondition {
  const factory TriggerCondition({
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'operation') String? operation,
    @JsonKey(name: 'cv') int? cv,
    @JsonKey(name: 'value') String? value,
    @JsonKey(name: 'selection') String? selection,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
    @Default([]) @JsonKey(name: 'condition') List<TriggerCondition> conditions,
  }) = _TriggerCondition;

  factory TriggerCondition.fromJson(Map<String, Object?> json) =>
      _$TriggerConditionFromJson(json);
}

/// Detection entry describing how to identify a decoder property
@freezed
abstract class Detection with _$Detection {
  const factory Detection({
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'displayFormat') String? displayFormat,
    @Default([]) @JsonKey(name: 'cv') List<DetectionCv> cvs,
    @Default([]) @JsonKey(name: 'cvGroup') List<DetectionCvGroup> cvGroups,
    @Default([]) @JsonKey(name: 'conditions') List<Condition> conditions,
  }) = _Detection;

  factory Detection.fromJson(Map<String, Object?> json) =>
      _$DetectionFromJson(json);
}
