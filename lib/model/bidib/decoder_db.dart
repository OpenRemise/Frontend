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

// ignore_for_file: library_private_types_in_public_api, unused_element

/// DecoderDB
///
/// \file   model/bidib/decoder_db.dart
/// \author Vincent Hamp
/// \date   11/05/2026

import 'package:freezed_annotation/freezed_annotation.dart';

part 'decoder_db.freezed.dart';
part 'decoder_db.g.dart';

@freezed
abstract class DecoderDbVersion with _$DecoderDbVersion {
  const factory DecoderDbVersion({
    @JsonKey(name: 'nmraListDate') String? nmraListDate,
    @JsonKey(name: 'createdBy') String? createdBy,
    @JsonKey(name: 'creatorLink') String? creatorLink,
    @JsonKey(name: 'lastUpdate') String? lastUpdate,
    @JsonKey(name: 'created') String? created,
  }) = _DecoderDbVersion;

  factory DecoderDbVersion.fromJson(Map<String, Object?> json) =>
      _$DecoderDbVersionFromJson(json);
}

//

@freezed
abstract class DecoderDbRepository with _$DecoderDbRepository {
  const factory DecoderDbRepository({
    @JsonKey(name: 'version') int? version,
    @JsonKey(name: 'manufacturers')
    DecoderDbRepositoryManufacturers? manufacturers,
    @JsonKey(name: 'decoderDetections')
    DecoderDbRepositoryDecoderDetections? decoderDetections,
    @JsonKey(name: 'decoder') List<DecoderDbRepositoryDecoder>? decoder,
    @JsonKey(name: 'firmware') List<DecoderDbRepositoryFirmware>? firmware,
    @JsonKey(name: 'image') List<DecoderDbRepositoryImage>? image,
  }) = _DecoderDbRepository;

  factory DecoderDbRepository.fromJson(Map<String, Object?> json) =>
      _$DecoderDbRepositoryFromJson(json);
}

@freezed
abstract class DecoderDbRepositoryManufacturers
    with _$DecoderDbRepositoryManufacturers {
  const factory DecoderDbRepositoryManufacturers({
    @JsonKey(name: 'nmraListDate') String? nmraListDate,
    @JsonKey(name: 'filename') String? filename,
    @JsonKey(name: 'link') String? link,
    @JsonKey(name: 'lastUpdate') String? lastUpdate,
    @JsonKey(name: 'sha1') String? sha1,
    @JsonKey(name: 'fileSize') int? fileSize,
  }) = _DecoderDbRepositoryManufacturers;

  factory DecoderDbRepositoryManufacturers.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbRepositoryManufacturersFromJson(json);
}

@freezed
abstract class DecoderDbRepositoryDecoderDetections
    with _$DecoderDbRepositoryDecoderDetections {
  const factory DecoderDbRepositoryDecoderDetections({
    @JsonKey(name: 'filename') String? filename,
    @JsonKey(name: 'link') String? link,
    @JsonKey(name: 'lastUpdate') String? lastUpdate,
    @JsonKey(name: 'sha1') String? sha1,
    @JsonKey(name: 'fileSize') int? fileSize,
  }) = _DecoderDbRepositoryDecoderDetections;

  factory DecoderDbRepositoryDecoderDetections.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbRepositoryDecoderDetectionsFromJson(json);
}

@freezed
abstract class DecoderDbRepositoryDecoder with _$DecoderDbRepositoryDecoder {
  const factory DecoderDbRepositoryDecoder({
    @JsonKey(name: 'manufacturerId') int? manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'created') String? created,
    @JsonKey(name: 'filename') String? filename,
    @JsonKey(name: 'link') String? link,
    @JsonKey(name: 'lastUpdate') String? lastUpdate,
    @JsonKey(name: 'sha1') String? sha1,
    @JsonKey(name: 'fileSize') int? fileSize,
  }) = _DecoderDbRepositoryDecoder;

  factory DecoderDbRepositoryDecoder.fromJson(Map<String, Object?> json) =>
      _$DecoderDbRepositoryDecoderFromJson(json);
}

@freezed
abstract class DecoderDbRepositoryFirmware with _$DecoderDbRepositoryFirmware {
  const factory DecoderDbRepositoryFirmware({
    @JsonKey(name: 'manufacturerId') int? manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'version') String? version,
    @JsonKey(name: 'versionExtension') String? versionExtension,
    @JsonKey(name: 'created') String? created,
    @JsonKey(name: 'decoder') List<DecoderDbRepositoryFirmwareDecoder>? decoder,
    @JsonKey(name: 'filename') String? filename,
    @JsonKey(name: 'link') String? link,
    @JsonKey(name: 'lastUpdate') String? lastUpdate,
    @JsonKey(name: 'sha1') String? sha1,
    @JsonKey(name: 'fileSize') int? fileSize,
  }) = _DecoderDbRepositoryFirmware;

  factory DecoderDbRepositoryFirmware.fromJson(Map<String, Object?> json) =>
      _$DecoderDbRepositoryFirmwareFromJson(json);
}

@freezed
abstract class DecoderDbRepositoryFirmwareDecoder
    with _$DecoderDbRepositoryFirmwareDecoder {
  const factory DecoderDbRepositoryFirmwareDecoder({
    @JsonKey(name: 'name') String? name,
  }) = _DecoderDbRepositoryFirmwareDecoder;

  factory DecoderDbRepositoryFirmwareDecoder.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbRepositoryFirmwareDecoderFromJson(json);
}

@freezed
abstract class DecoderDbRepositoryImage with _$DecoderDbRepositoryImage {
  const factory DecoderDbRepositoryImage({
    @JsonKey(name: 'manufacturerId') int? manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'filename') String? filename,
    @JsonKey(name: 'link') String? link,
    @JsonKey(name: 'lastUpdate') String? lastUpdate,
    @JsonKey(name: 'sha1') String? sha1,
    @JsonKey(name: 'fileSize') int? fileSize,
  }) = _DecoderDbRepositoryImage;

  factory DecoderDbRepositoryImage.fromJson(Map<String, Object?> json) =>
      _$DecoderDbRepositoryImageFromJson(json);
}

//

@freezed
abstract class DecoderDbManufacturers with _$DecoderDbManufacturers {
  const factory DecoderDbManufacturers({
    @JsonKey(name: 'version') DecoderDbVersion? version,
    @JsonKey(name: 'manufacturers')
    List<DecoderDbManufacturersManufacturers>? manufacturers,
  }) = _DecoderDbManufacturers;

  factory DecoderDbManufacturers.fromJson(Map<String, Object?> json) =>
      _$DecoderDbManufacturersFromJson(json);
}

@freezed
abstract class DecoderDbManufacturersManufacturers
    with _$DecoderDbManufacturersManufacturers {
  const factory DecoderDbManufacturersManufacturers({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'extendedId') int? extendedId,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'shortName') String? shortName,
    @JsonKey(name: 'decoderDBLink') String? decoderDBLink,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'url') String? url,
  }) = _DecoderDbManufacturersManufacturers;

  factory DecoderDbManufacturersManufacturers.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbManufacturersManufacturersFromJson(json);
}

//

@freezed
abstract class DecoderDbDecoderDetection with _$DecoderDbDecoderDetection {
  const factory DecoderDbDecoderDetection({
    @JsonKey(name: 'version') DecoderDbVersion? version,
    @JsonKey(name: 'protocols')
    List<DecoderDbDecoderDetectionProtocols>? protocols,
  }) = _DecoderDbDecoderDetection;

  factory DecoderDbDecoderDetection.fromJson(Map<String, Object?> json) =>
      _$DecoderDbDecoderDetectionFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionProtocols
    with _$DecoderDbDecoderDetectionProtocols {
  const factory DecoderDbDecoderDetectionProtocols({
    @JsonKey(name: 'default') List<DecoderDbDecoderDetectionDefault>? defaults,
    @JsonKey(name: 'manufacturer')
    List<DecoderDbDecoderDetectionManufacturer>? manufacturer,
    @JsonKey(name: 'type') String? type,
  }) = _DecoderDbDecoderDetectionProtocols;

  factory DecoderDbDecoderDetectionProtocols.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbDecoderDetectionProtocolsFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionDefault
    with _$DecoderDbDecoderDetectionDefault {
  const factory DecoderDbDecoderDetectionDefault({
    @JsonKey(name: 'items') List<DecoderDbDecoderDetectionItems>? items,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'displayFormat') String? displayFormat,
    @JsonKey(name: 'indexHigh') int? indexHigh,
  }) = _DecoderDbDecoderDetectionDefault;

  factory DecoderDbDecoderDetectionDefault.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbDecoderDetectionDefaultFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionItems
    with _$DecoderDbDecoderDetectionItems {
  const factory DecoderDbDecoderDetectionItems({
    @JsonKey(name: 'number') int? number,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'mode') String? mode,
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'triggers')
    List<DecoderDbDecoderDetectionTriggers>? triggers,
    @JsonKey(name: 'cvs') List<DecoderDbDecoderDetectionCvs>? cvs,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
  }) = _DecoderDbDecoderDetectionItems;

  factory DecoderDbDecoderDetectionItems.fromJson(Map<String, Object?> json) =>
      _$DecoderDbDecoderDetectionItemsFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionTriggers
    with _$DecoderDbDecoderDetectionTriggers {
  const factory DecoderDbDecoderDetectionTriggers({
    @JsonKey(name: 'conditions')
    List<DecoderDbDecoderDetectionConditions>? conditions,
    @JsonKey(name: 'value') String? value,
  }) = _DecoderDbDecoderDetectionTriggers;

  factory DecoderDbDecoderDetectionTriggers.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbDecoderDetectionTriggersFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionConditions
    with _$DecoderDbDecoderDetectionConditions {
  const factory DecoderDbDecoderDetectionConditions({
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'operation') String? operation,
    @JsonKey(name: 'cv') String? cv,
    @JsonKey(name: 'value') String? value,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
    @JsonKey(name: 'conditions')
    List<DecoderDbDecoderDetectionConditions>? conditions,
  }) = _DecoderDbDecoderDetectionConditions;

  factory DecoderDbDecoderDetectionConditions.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbDecoderDetectionConditionsFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionCvs
    with _$DecoderDbDecoderDetectionCvs {
  const factory DecoderDbDecoderDetectionCvs({
    @JsonKey(name: 'number') int? number,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'mode') String? mode,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
  }) = _DecoderDbDecoderDetectionCvs;

  factory DecoderDbDecoderDetectionCvs.fromJson(Map<String, Object?> json) =>
      _$DecoderDbDecoderDetectionCvsFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionManufacturer
    with _$DecoderDbDecoderDetectionManufacturer {
  const factory DecoderDbDecoderDetectionManufacturer({
    @JsonKey(name: 'detection')
    List<DecoderDbDecoderDetectionDetection>? detection,
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'extendedId') int? extendedId,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'shortName') String? shortName,
  }) = _DecoderDbDecoderDetectionManufacturer;

  factory DecoderDbDecoderDetectionManufacturer.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbDecoderDetectionManufacturerFromJson(json);
}

@freezed
abstract class DecoderDbDecoderDetectionDetection
    with _$DecoderDbDecoderDetectionDetection {
  const factory DecoderDbDecoderDetectionDetection({
    @JsonKey(name: 'items') List<DecoderDbDecoderDetectionItems>? items,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'displayFormat') String? displayFormat,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
    @JsonKey(name: 'value') String? value,
    @JsonKey(name: 'valueName') String? valueName,
  }) = _DecoderDbDecoderDetectionDetection;

  factory DecoderDbDecoderDetectionDetection.fromJson(
    Map<String, Object?> json,
  ) =>
      _$DecoderDbDecoderDetectionDetectionFromJson(json);
}
