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
import 'package:freezed_annotation/freezed_annotation.dart';

part 'decoder_definition.freezed.dart';
part 'decoder_definition.g.dart';

/// Definition of a single decoder
///
/// Downloaded from the link of the matching `DecoderFile` entry of
/// `Repository.decoders`. Describes what a decoder is and how it is built, but
/// not its CVs, which are part of the firmware definition instead.
@freezed
abstract class DecoderDefinitionFile with _$DecoderDefinitionFile {
  const factory DecoderDefinitionFile({
    @JsonKey(name: 'decoder') required DecoderDefinition decoder,
    @JsonKey(name: 'version') DefinitionVersion? version,
    @JsonKey(name: 'sourceFile') String? sourceFile,
  }) = _DecoderDefinitionFile;

  factory DecoderDefinitionFile.fromJson(Map<String, Object?> json) =>
      _$DecoderDefinitionFileFromJson(json);
}

/// Product data of a decoder
///
/// [type] is one of loco, loco-sound, function, car, car-sound, susi,
/// susi-sound, standardAccessory or extendedAccessory. [typeIds] and
/// [articleNumbers] are semicolon separated lists, [producedFrom] and
/// [producedTill] are four digit years.
@freezed
abstract class DecoderDefinition with _$DecoderDefinition {
  const factory DecoderDefinition({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @Default(0)
    @JsonKey(name: 'manufacturerExtendedId')
    int manufacturerExtendedId,
    @JsonKey(name: 'specifications')
    required DecoderSpecifications specifications,
    @JsonKey(name: 'decoderDBLink') String? decoderDBLink,
    @JsonKey(name: 'typeIds') String? typeIds,
    @JsonKey(name: 'articleNumbers') String? articleNumbers,
    @JsonKey(name: 'producedFrom') String? producedFrom,
    @JsonKey(name: 'producedTill') String? producedTill,
    @JsonKey(name: 'options') String? options,
    @JsonKey(name: 'manufacturerUrl') String? manufacturerUrl,
    @JsonKey(name: 'manufacturerName') String? manufacturerName,
    @JsonKey(name: 'manufacturerShortName') String? manufacturerShortName,
    @Default([])
    @JsonKey(name: 'description')
    List<DecoderDescription> description,
    @Default([]) @JsonKey(name: 'images') List<DecoderImage> images,
  }) = _DecoderDefinition;

  factory DecoderDefinition.fromJson(Map<String, Object?> json) =>
      _$DecoderDefinitionFromJson(json);
}

/// Physical and electrical properties of a decoder
@freezed
abstract class DecoderSpecifications with _$DecoderSpecifications {
  const factory DecoderSpecifications({
    @JsonKey(name: 'electrical') required DecoderElectrical electrical,
    @JsonKey(name: 'connectors') required DecoderConnectors connectors,
    @JsonKey(name: 'dimensions') DecoderDimensions? dimensions,
    @JsonKey(name: 'functionConnectors') DecoderConnectors? functionConnectors,
  }) = _DecoderSpecifications;

  factory DecoderSpecifications.fromJson(Map<String, Object?> json) =>
      _$DecoderSpecificationsFromJson(json);
}

/// Size of a decoder in mm
@freezed
abstract class DecoderDimensions with _$DecoderDimensions {
  const factory DecoderDimensions({
    @JsonKey(name: 'length') required double length,
    @JsonKey(name: 'width') required double width,
    @JsonKey(name: 'height') required double height,
  }) = _DecoderDimensions;

  factory DecoderDimensions.fromJson(Map<String, Object?> json) =>
      _$DecoderDimensionsFromJson(json);
}

/// Ratings of a decoder in A, V and number of outputs
///
/// A rating of 0 means the value is unknown rather than actually zero.
@freezed
abstract class DecoderElectrical with _$DecoderElectrical {
  const factory DecoderElectrical({
    @JsonKey(name: 'maxTotalCurrent') required double maxTotalCurrent,
    @JsonKey(name: 'maxMotorCurrent') required double maxMotorCurrent,
    @JsonKey(name: 'maxVoltage') required double maxVoltage,
    @JsonKey(name: 'peakCurrent') double? peakCurrent,
    @JsonKey(name: 'functionOutputs') double? functionOutputs,
  }) = _DecoderElectrical;

  factory DecoderElectrical.fromJson(Map<String, Object?> json) =>
      _$DecoderElectricalFromJson(json);
}

/// Semicolon separated list of connectors, e.g. `NEM651+Cable;Plux22`
@freezed
abstract class DecoderConnectors with _$DecoderConnectors {
  const factory DecoderConnectors({
    @JsonKey(name: 'list') required String list,
  }) = _DecoderConnectors;

  factory DecoderConnectors.fromJson(Map<String, Object?> json) =>
      _$DecoderConnectorsFromJson(json);
}

/// Localized description of a decoder
///
/// [innerText] contains HTML markup. [language] is a two letter code or `all`.
@freezed
abstract class DecoderDescription with _$DecoderDescription {
  const factory DecoderDescription({
    @JsonKey(name: 'language') required String language,
    @JsonKey(name: 'innerText') required String innerText,
  }) = _DecoderDescription;

  factory DecoderDescription.fromJson(Map<String, Object?> json) =>
      _$DecoderDescriptionFromJson(json);
}

/// Photo of a decoder
///
/// [name] is the file name below the `images` folder of the manufacturer,
/// [source] the original location the image was taken from.
@freezed
abstract class DecoderImage with _$DecoderImage {
  const factory DecoderImage({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'source') String? source,
    @JsonKey(name: 'lastModified') DateTime? lastModified,
    @JsonKey(name: 'copyright') String? copyright,
  }) = _DecoderImage;

  factory DecoderImage.fromJson(Map<String, Object?> json) =>
      _$DecoderImageFromJson(json);
}
