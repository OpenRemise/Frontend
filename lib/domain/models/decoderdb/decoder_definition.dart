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

import 'package:Frontend/domain/models/decoderdb/common_types.dart';
import 'package:Frontend/domain/models/decoderdb/json_helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'decoder_definition.freezed.dart';
part 'decoder_definition.g.dart';

/// Top-level wrapper for individual decoder JSON files
@freezed
abstract class DecoderDefinitionFile with _$DecoderDefinitionFile {
  const factory DecoderDefinitionFile({
    @JsonKey(name: 'decoderDefinition')
    required DecoderDefinition decoderDefinition,
  }) = _DecoderDefinitionFile;

  factory DecoderDefinitionFile.fromJson(Map<String, Object?> json) =>
      _$DecoderDefinitionFileFromJson(json);
}

/// Decoder definition containing version and decoder info
@freezed
abstract class DecoderDefinition with _$DecoderDefinition {
  const factory DecoderDefinition({
    @JsonKey(name: 'version') required Version version,
    @JsonKey(name: 'decoder') required DecoderInfo decoder,
  }) = _DecoderDefinition;

  factory DecoderDefinition.fromJson(Map<String, Object?> json) =>
      _$DecoderDefinitionFromJson(json);
}

/// Detailed decoder information
@freezed
abstract class DecoderInfo with _$DecoderInfo {
  const factory DecoderInfo({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'manufacturerName') String? manufacturerName,
    @JsonKey(name: 'manufacturerShortName') String? manufacturerShortName,
    @JsonKey(name: 'manufacturerUrl') String? manufacturerUrl,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'typeIds') String? typeIds,
    @JsonKey(name: 'articleNumbers') String? articleNumbers,
    @JsonKey(name: 'producedFrom') int? producedFrom,
    @JsonKey(name: 'producedTill') int? producedTill,
    @JsonKey(name: 'decoderDBLink') String? decoderDBLink,
    @Default([])
    @JsonKey(name: 'description', readValue: readAsList)
    List<Description> description,
    @JsonKey(name: 'specifications') DecoderSpecifications? specifications,
    @Default([]) @JsonKey(name: 'images') List<DecoderImageGroup> images,
  }) = _DecoderInfo;

  factory DecoderInfo.fromJson(Map<String, Object?> json) =>
      _$DecoderInfoFromJson(json);
}

/// Decoder hardware specifications
@freezed
abstract class DecoderSpecifications with _$DecoderSpecifications {
  const factory DecoderSpecifications({
    @JsonKey(name: 'dimensions') DecoderDimensions? dimensions,
    @JsonKey(name: 'electrical', readValue: readAsSingle)
    DecoderElectrical? electrical,
    @JsonKey(name: 'connectors') DecoderConnectors? connectors,
  }) = _DecoderSpecifications;

  factory DecoderSpecifications.fromJson(Map<String, Object?> json) =>
      _$DecoderSpecificationsFromJson(json);
}

/// Physical dimensions of the decoder
@freezed
abstract class DecoderDimensions with _$DecoderDimensions {
  const factory DecoderDimensions({
    @JsonKey(name: 'length') String? length,
    @JsonKey(name: 'width') String? width,
    @JsonKey(name: 'height') String? height,
  }) = _DecoderDimensions;

  factory DecoderDimensions.fromJson(Map<String, Object?> json) =>
      _$DecoderDimensionsFromJson(json);
}

/// Electrical specifications of the decoder
@freezed
abstract class DecoderElectrical with _$DecoderElectrical {
  const factory DecoderElectrical({
    @JsonKey(name: 'maxTotalCurrent') String? maxTotalCurrent,
    @JsonKey(name: 'maxMotorCurrent') String? maxMotorCurrent,
    @JsonKey(name: 'maxVoltage') String? maxVoltage,
  }) = _DecoderElectrical;

  factory DecoderElectrical.fromJson(Map<String, Object?> json) =>
      _$DecoderElectricalFromJson(json);
}

/// Connector information for the decoder
@freezed
abstract class DecoderConnectors with _$DecoderConnectors {
  const factory DecoderConnectors({
    @JsonKey(name: 'list') String? connectorList,
  }) = _DecoderConnectors;

  factory DecoderConnectors.fromJson(Map<String, Object?> json) =>
      _$DecoderConnectorsFromJson(json);
}

/// Group of decoder images
@freezed
abstract class DecoderImageGroup with _$DecoderImageGroup {
  const factory DecoderImageGroup({
    @Default([]) @JsonKey(name: 'image') List<DecoderImage> image,
  }) = _DecoderImageGroup;

  factory DecoderImageGroup.fromJson(Map<String, Object?> json) =>
      _$DecoderImageGroupFromJson(json);
}

/// Individual decoder image metadata
@freezed
abstract class DecoderImage with _$DecoderImage {
  const factory DecoderImage({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'src') required String src,
    @JsonKey(name: 'lastModified') String? lastModified,
    @JsonKey(name: 'fileSize') int? fileSize,
    @JsonKey(name: 'sha1') String? sha1,
    @JsonKey(name: 'copyright') String? copyright,
  }) = _DecoderImage;

  factory DecoderImage.fromJson(Map<String, Object?> json) =>
      _$DecoderImageFromJson(json);
}
