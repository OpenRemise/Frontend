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

import 'package:Frontend/data/models/decoderdb/common_types.dart';
import 'package:Frontend/data/models/decoderdb/json_helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'decoder_detection.freezed.dart';
part 'decoder_detection.g.dart';

/// Top-level wrapper for DecoderDetection.json
@freezed
abstract class DecoderDetectionFile with _$DecoderDetectionFile {
  const factory DecoderDetectionFile({
    @JsonKey(name: 'decoderDetection')
    required DecoderDetection decoderDetection,
  }) = _DecoderDetectionFile;

  factory DecoderDetectionFile.fromJson(Map<String, Object?> json) =>
      _$DecoderDetectionFileFromJson(json);
}

/// Decoder detection data containing version and protocols
@freezed
abstract class DecoderDetection with _$DecoderDetection {
  const factory DecoderDetection({
    @JsonKey(name: 'version') required Version version,
    @Default([])
    @JsonKey(name: 'protocols', readValue: readNestedAsList)
    List<DetectionProtocol> protocols,
  }) = _DecoderDetection;

  factory DecoderDetection.fromJson(Map<String, Object?> json) =>
      _$DecoderDetectionFromJson(json);
}

/// Protocol-specific detection configuration
@freezed
abstract class DetectionProtocol with _$DetectionProtocol {
  const factory DetectionProtocol({
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'default') required DetectionDefault defaults,
    @Default([])
    @JsonKey(name: 'manufacturer')
    List<DetectionManufacturer> manufacturers,
  }) = _DetectionProtocol;

  factory DetectionProtocol.fromJson(Map<String, Object?> json) =>
      _$DetectionProtocolFromJson(json);
}

/// Default detection entries for a protocol
@freezed
abstract class DetectionDefault with _$DetectionDefault {
  const factory DetectionDefault({
    @Default([]) @JsonKey(name: 'detection') List<Detection> detections,
  }) = _DetectionDefault;

  factory DetectionDefault.fromJson(Map<String, Object?> json) =>
      _$DetectionDefaultFromJson(json);
}

/// Manufacturer-specific detection configuration
@freezed
abstract class DetectionManufacturer with _$DetectionManufacturer {
  const factory DetectionManufacturer({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'extendedId') String? extendedId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'shortName') required String shortName,
    @Default([])
    @JsonKey(name: 'detection', readValue: readAsList)
    List<Detection> detections,
  }) = _DetectionManufacturer;

  factory DetectionManufacturer.fromJson(Map<String, Object?> json) =>
      _$DetectionManufacturerFromJson(json);
}
