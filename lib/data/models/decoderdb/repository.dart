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

part 'repository.freezed.dart';
part 'repository.g.dart';

/// Index of the entire DecoderDB repository
///
/// This is the entry point of the database. It is downloaded from
/// https://decoderdb.bidib.org/repository.json and lists every decoder,
/// firmware and image file together with the metadata required to fetch and
/// verify them.
@freezed
abstract class Repository with _$Repository {
  const factory Repository({
    @JsonKey(name: 'version') required int version,
    @JsonKey(name: 'manufacturers') required ManufacturersFile manufacturers,
    @JsonKey(name: 'decoderDetections')
    required DecoderDetectionsFile decoderDetections,
    @Default([]) @JsonKey(name: 'decoder') List<DecoderFile> decoders,
    @Default([]) @JsonKey(name: 'firmware') List<FirmwareFile> firmwares,
    @Default([]) @JsonKey(name: 'image') List<ImageFile> images,
  }) = _Repository;

  factory Repository.fromJson(Map<String, Object?> json) =>
      _$RepositoryFromJson(json);
}

/// Reference to the Manufacturers.json file
@freezed
abstract class ManufacturersFile with _$ManufacturersFile {
  const factory ManufacturersFile({
    @JsonKey(name: 'nmraListDate') DateTime? nmraListDate,
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'lastUpdate') required DateTime lastUpdate,
    @JsonKey(name: 'sha1') required String sha1,
    @JsonKey(name: 'fileSize') required int fileSize,
  }) = _ManufacturersFile;

  factory ManufacturersFile.fromJson(Map<String, Object?> json) =>
      _$ManufacturersFileFromJson(json);
}

/// Reference to the DecoderDetection.json file
@freezed
abstract class DecoderDetectionsFile with _$DecoderDetectionsFile {
  const factory DecoderDetectionsFile({
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'lastUpdate') required DateTime lastUpdate,
    @JsonKey(name: 'sha1') required String sha1,
    @JsonKey(name: 'fileSize') required int fileSize,
  }) = _DecoderDetectionsFile;

  factory DecoderDetectionsFile.fromJson(Map<String, Object?> json) =>
      _$DecoderDetectionsFileFromJson(json);
}

/// Reference to a single decoder definition file
@freezed
abstract class DecoderFile with _$DecoderFile {
  const factory DecoderFile({
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @Default(0)
    @JsonKey(name: 'manufacturerExtendedId')
    int manufacturerExtendedId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'lastUpdate') required DateTime lastUpdate,
    @JsonKey(name: 'sha1') required String sha1,
    @JsonKey(name: 'fileSize') required int fileSize,
  }) = _DecoderFile;

  factory DecoderFile.fromJson(Map<String, Object?> json) =>
      _$DecoderFileFromJson(json);
}

/// Reference to a single firmware definition file
@freezed
abstract class FirmwareFile with _$FirmwareFile {
  const factory FirmwareFile({
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @Default(0)
    @JsonKey(name: 'manufacturerExtendedId')
    int manufacturerExtendedId,
    @JsonKey(name: 'version') required String version,
    @JsonKey(name: 'versionExtension') String? versionExtension,
    @JsonKey(name: 'created') DateTime? created,
    @Default([]) @JsonKey(name: 'decoder') List<FirmwareDecoderRef> decoders,
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'lastUpdate') required DateTime lastUpdate,
    @JsonKey(name: 'sha1') required String sha1,
    @JsonKey(name: 'fileSize') required int fileSize,
  }) = _FirmwareFile;

  factory FirmwareFile.fromJson(Map<String, Object?> json) =>
      _$FirmwareFileFromJson(json);
}

/// Name of a decoder a firmware is compatible with
@freezed
abstract class FirmwareDecoderRef with _$FirmwareDecoderRef {
  const factory FirmwareDecoderRef({
    @JsonKey(name: 'name') required String name,
  }) = _FirmwareDecoderRef;

  factory FirmwareDecoderRef.fromJson(Map<String, Object?> json) =>
      _$FirmwareDecoderRefFromJson(json);
}

/// Reference to a single decoder image file
@freezed
abstract class ImageFile with _$ImageFile {
  const factory ImageFile({
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @Default(0)
    @JsonKey(name: 'manufacturerExtendedId')
    int manufacturerExtendedId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'lastUpdate') required DateTime lastUpdate,
    @JsonKey(name: 'sha1') required String sha1,
    @JsonKey(name: 'fileSize') required int fileSize,
  }) = _ImageFile;

  factory ImageFile.fromJson(Map<String, Object?> json) =>
      _$ImageFileFromJson(json);
}
