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

import 'package:json_annotation/json_annotation.dart';
part 'decoder_db_manufacturers.g.dart';

@JsonSerializable()
class DecoderDbManufacturers {
  @JsonKey(name: 'version')
  _Version? version;
  @JsonKey(name: 'manufacturers')
  List<_Manufacturers>? manufacturers;

  DecoderDbManufacturers({
    this.version,
    this.manufacturers,
  });

  factory DecoderDbManufacturers.fromJson(Map<String, dynamic> json) =>
      _$DecoderDbManufacturersFromJson(json);

  Map<String, dynamic> toJson() => _$DecoderDbManufacturersToJson(this);
}

@JsonSerializable()
class _Version {
  @JsonKey(name: 'nmraListDate')
  String? nmraListDate;
  @JsonKey(name: 'createdBy')
  String? createdBy;
  @JsonKey(name: 'creatorLink')
  String? creatorLink;
  @JsonKey(name: 'lastUpdate')
  String? lastUpdate;
  @JsonKey(name: 'created')
  String? created;

  _Version({
    this.nmraListDate,
    this.createdBy,
    this.creatorLink,
    this.lastUpdate,
    this.created,
  });

  factory _Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);

  Map<String, dynamic> toJson() => _$VersionToJson(this);
}

@JsonSerializable()
class _Manufacturers {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'extendedId')
  int? extendedId;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'shortName')
  String? shortName;
  @JsonKey(name: 'decoderDBLink')
  String? decoderDBLink;
  @JsonKey(name: 'country')
  String? country;
  @JsonKey(name: 'url')
  String? url;

  _Manufacturers({
    this.id,
    this.extendedId,
    this.name,
    this.shortName,
    this.decoderDBLink,
    this.country,
    this.url,
  });

  factory _Manufacturers.fromJson(Map<String, dynamic> json) =>
      _$ManufacturersFromJson(json);

  Map<String, dynamic> toJson() => _$ManufacturersToJson(this);
}
