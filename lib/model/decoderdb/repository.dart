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

/// Top-level repository index
@freezed
abstract class Repository with _$Repository {
  const factory Repository({
    @JsonKey(name: 'version') required int version,
    @JsonKey(name: 'manufacturers') required RepositoryFileRef manufacturers,
    @JsonKey(name: 'decoderDetections')
    required RepositoryFileRef decoderDetections,
    @Default([])
    @JsonKey(name: 'decoder')
    List<RepositoryDecoderEntry> decoders,
    @Default([])
    @JsonKey(name: 'firmware')
    List<RepositoryFirmwareEntry> firmwares,
    @Default([]) @JsonKey(name: 'image') List<RepositoryMediaEntry> images,
    @Default([]) @JsonKey(name: 'manual') List<RepositoryMediaEntry> manuals,
  }) = _Repository;

  factory Repository.fromJson(Map<String, Object?> json) =>
      _$RepositoryFromJson(json);
}

/// Reference to a downloadable file in the repository
@freezed
abstract class RepositoryFileRef with _$RepositoryFileRef {
  const factory RepositoryFileRef({
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'nmraListDate') String? nmraListDate,
    @JsonKey(name: 'lastUpdate') required String lastUpdate,
    @JsonKey(name: 'fileSize') required String fileSize,
    @JsonKey(name: 'sha1') required String sha1,
  }) = _RepositoryFileRef;

  factory RepositoryFileRef.fromJson(Map<String, Object?> json) =>
      _$RepositoryFileRefFromJson(json);
}

/// Decoder entry in the repository index
@freezed
abstract class RepositoryDecoderEntry with _$RepositoryDecoderEntry {
  const factory RepositoryDecoderEntry({
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'lastUpdate') required String lastUpdate,
    @JsonKey(name: 'created') String? created,
    @JsonKey(name: 'fileSize') required String fileSize,
    @JsonKey(name: 'sha1') required String sha1,
  }) = _RepositoryDecoderEntry;

  factory RepositoryDecoderEntry.fromJson(Map<String, Object?> json) =>
      _$RepositoryDecoderEntryFromJson(json);
}

/// Firmware entry in the repository index
@freezed
abstract class RepositoryFirmwareEntry with _$RepositoryFirmwareEntry {
  const factory RepositoryFirmwareEntry({
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'version') required String version,
    @JsonKey(name: 'versionExtension') String? versionExtension,
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'lastUpdate') required String lastUpdate,
    @JsonKey(name: 'created') String? created,
    @JsonKey(name: 'fileSize') required String fileSize,
    @JsonKey(name: 'sha1') required String sha1,
  }) = _RepositoryFirmwareEntry;

  factory RepositoryFirmwareEntry.fromJson(Map<String, Object?> json) =>
      _$RepositoryFirmwareEntryFromJson(json);
}

/// Image or manual entry in the repository index
@freezed
abstract class RepositoryMediaEntry with _$RepositoryMediaEntry {
  const factory RepositoryMediaEntry({
    @JsonKey(name: 'filename') required String filename,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'lastUpdate') required String lastUpdate,
    @JsonKey(name: 'fileSize') required String fileSize,
    @JsonKey(name: 'sha1') required String sha1,
  }) = _RepositoryMediaEntry;

  factory RepositoryMediaEntry.fromJson(Map<String, Object?> json) =>
      _$RepositoryMediaEntryFromJson(json);
}
