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

part 'manufacturers_list.freezed.dart';
part 'manufacturers_list.g.dart';

/// Top-level wrapper for Manufacturers.json
@freezed
abstract class ManufacturersListFile with _$ManufacturersListFile {
  const factory ManufacturersListFile({
    @JsonKey(name: 'manufacturersList')
    required ManufacturersList manufacturersList,
  }) = _ManufacturersListFile;

  factory ManufacturersListFile.fromJson(Map<String, Object?> json) =>
      _$ManufacturersListFileFromJson(json);
}

/// Manufacturers list containing version and manufacturer data
@freezed
abstract class ManufacturersList with _$ManufacturersList {
  const factory ManufacturersList({
    @JsonKey(name: 'version') required ManufacturersListVersion version,
    @JsonKey(name: 'manufacturers') required Manufacturers manufacturers,
  }) = _ManufacturersList;

  factory ManufacturersList.fromJson(Map<String, Object?> json) =>
      _$ManufacturersListFromJson(json);
}

/// Version metadata for the manufacturers list, with NMRA list date
@freezed
abstract class ManufacturersListVersion with _$ManufacturersListVersion {
  const factory ManufacturersListVersion({
    @JsonKey(name: 'createdBy') String? createdBy,
    @JsonKey(name: 'creatorLink') String? creatorLink,
    @JsonKey(name: 'author') String? author,
    @JsonKey(name: 'lastUpdate') required String lastUpdate,
    @JsonKey(name: 'created') String? created,
    @JsonKey(name: 'nmraListDate') required String nmraListDate,
  }) = _ManufacturersListVersion;

  factory ManufacturersListVersion.fromJson(Map<String, Object?> json) =>
      _$ManufacturersListVersionFromJson(json);
}

/// Container for the list of manufacturers and an optional link
@freezed
abstract class Manufacturers with _$Manufacturers {
  const factory Manufacturers({
    @JsonKey(name: 'decoderDBLink') String? decoderDBLink,
    @Default([]) @JsonKey(name: 'manufacturer') List<Manufacturer> manufacturer,
  }) = _Manufacturers;

  factory Manufacturers.fromJson(Map<String, Object?> json) =>
      _$ManufacturersFromJson(json);
}

/// Individual NMRA manufacturer entry
@freezed
abstract class Manufacturer with _$Manufacturer {
  const factory Manufacturer({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'extendedId') String? extendedId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'shortName') required String shortName,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'url') String? url,
    @JsonKey(name: 'decoderDBLink') String? decoderDBLink,
  }) = _Manufacturer;

  factory Manufacturer.fromJson(Map<String, Object?> json) =>
      _$ManufacturerFromJson(json);
}
