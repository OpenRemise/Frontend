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

import 'package:Frontend/data/models/decoderdb/definition_version.dart';
import 'package:Frontend/data/models/decoderdb/detection_item.dart';
import 'package:Frontend/data/models/decoderdb/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'decoder_detection.freezed.dart';
part 'decoder_detection.g.dart';

/// Rules for identifying an unknown decoder by reading CVs
///
/// Downloaded from the link in `Repository.decoderDetections`. This is the
/// first file to fetch, because it tells which CVs to read in order to resolve
/// manufacturer, decoder and firmware version of a decoder on the track.
@freezed
abstract class DecoderDetectionFile with _$DecoderDetectionFile {
  const factory DecoderDetectionFile({
    @JsonKey(name: 'version') DefinitionVersion? version,
    @Default([]) @JsonKey(name: 'protocols') List<DetectionProtocol> protocols,
  }) = _DecoderDetectionFile;

  factory DecoderDetectionFile.fromJson(Map<String, Object?> json) =>
      _$DecoderDetectionFileFromJson(json);
}

/// Detection rules for one command protocol
///
/// [defaults] holds the protocol wide rules that are evaluated first, typically
/// reading the manufacturer id. Once the manufacturer is known, the matching
/// entry of [manufacturers] refines the result with vendor specific rules.
@freezed
abstract class DetectionProtocol with _$DetectionProtocol {
  const factory DetectionProtocol({
    @JsonKey(name: 'type') required String type,
    @Default([]) @JsonKey(name: 'default') List<Detection> defaults,
    @Default([])
    @JsonKey(name: 'manufacturer')
    List<DetectionManufacturer> manufacturers,
  }) = _DetectionProtocol;

  factory DetectionProtocol.fromJson(Map<String, Object?> json) =>
      _$DetectionProtocolFromJson(json);
}

/// Vendor specific detection rules
///
/// Selected by matching [id] and [extendedId] against the manufacturer id read
/// by the protocol defaults.
@freezed
abstract class DetectionManufacturer with _$DetectionManufacturer {
  const factory DetectionManufacturer({
    @JsonKey(name: 'id') required int id,
    @Default(0) @JsonKey(name: 'extendedId') int extendedId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'shortName') String? shortName,
    @Default([]) @JsonKey(name: 'detection') List<Detection> detections,
  }) = _DetectionManufacturer;

  factory DetectionManufacturer.fromJson(Map<String, Object?> json) =>
      _$DetectionManufacturerFromJson(json);
}

/// How to determine one decoder property
///
/// [items] is the heterogeneous choice described by [DetectionItem]: any
/// [ConditionsItem] gates the rule, while [Cv] and [CvGroup] entries supply the
/// values. [displayFormat] is a .NET style format string that renders those
/// values, e.g. `{0}.{1}` for a two part firmware version. A fixed [value] is
/// used instead when the rule identifies a decoder without reading anything.
@freezed
abstract class Detection with _$Detection {
  const factory Detection({
    @JsonKey(name: 'type') required String type,
    @DetectionItemConverter()
    @Default([])
    @JsonKey(name: 'items')
    List<DetectionItem> items,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
    @JsonKey(name: 'displayFormat') String? displayFormat,
    @JsonKey(name: 'value') String? value,
    @JsonKey(name: 'valueName') String? valueName,
  }) = _Detection;

  factory Detection.fromJson(Map<String, Object?> json) =>
      _$DetectionFromJson(json);
}
