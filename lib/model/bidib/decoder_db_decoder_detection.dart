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

/// DecoderDB decoder detection
///
/// \file   model/bidib/decoder_db_decoder_detection.dart
/// \author Vincent Hamp
/// \date   27/03/2026

// ignore_for_file: library_private_types_in_public_api, unused_element

import 'package:json_annotation/json_annotation.dart';
part 'decoder_db_decoder_detection.g.dart';

@JsonSerializable()
class DecoderDbDecoderDetection {
  @JsonKey(name: 'version')
  _Version? version;
  @JsonKey(name: 'protocols')
  List<_Protocols>? protocols;

  DecoderDbDecoderDetection({
    this.version,
    this.protocols,
  });

  factory DecoderDbDecoderDetection.fromJson(Map<String, dynamic> json) =>
      _$DecoderDbDecoderDetectionFromJson(json);

  Map<String, dynamic> toJson() => _$DecoderDbDecoderDetectionToJson(this);
}

@JsonSerializable()
class _Version {
  @JsonKey(name: 'createdBy')
  String? createdBy;
  @JsonKey(name: 'creatorLink')
  String? creatorLink;
  @JsonKey(name: 'lastUpdate')
  String? lastUpdate;
  @JsonKey(name: 'created')
  String? created;

  _Version({
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
class _Protocols {
  @JsonKey(name: 'default')
  List<_Default>? defaultProperty;
  @JsonKey(name: 'manufacturer')
  List<_Manufacturer>? manufacturer;
  @JsonKey(name: 'type')
  String? type;

  _Protocols({
    this.defaultProperty,
    this.manufacturer,
    this.type,
  });

  factory _Protocols.fromJson(Map<String, dynamic> json) =>
      _$ProtocolsFromJson(json);

  Map<String, dynamic> toJson() => _$ProtocolsToJson(this);
}

@JsonSerializable()
class _Default {
  @JsonKey(name: 'items')
  List<_Items>? items;
  @JsonKey(name: 'type')
  String? type;

  _Default({
    this.items,
    this.type,
  });

  factory _Default.fromJson(Map<String, dynamic> json) =>
      _$DefaultFromJson(json);

  Map<String, dynamic> toJson() => _$DefaultToJson(this);
}

@JsonSerializable()
class _Items {
  @JsonKey(name: 'number')
  int? number;
  @JsonKey(name: 'type')
  String? type;
  @JsonKey(name: 'mode')
  String? mode;

  _Items({
    this.number,
    this.type,
    this.mode,
  });

  factory _Items.fromJson(Map<String, dynamic> json) => _$ItemsFromJson(json);

  Map<String, dynamic> toJson() => _$ItemsToJson(this);
}

@JsonSerializable()
class _Manufacturer {
  @JsonKey(name: 'detection')
  List<_Detection>? detection;
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'extendedId')
  int? extendedId;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'shortName')
  String? shortName;

  _Manufacturer({
    this.detection,
    this.id,
    this.extendedId,
    this.name,
    this.shortName,
  });

  factory _Manufacturer.fromJson(Map<String, dynamic> json) =>
      _$ManufacturerFromJson(json);

  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);
}

@JsonSerializable()
class _Detection {
  @JsonKey(name: 'items')
  List<_Items>? items;
  @JsonKey(name: 'type')
  String? type;
  @JsonKey(name: 'displayFormat')
  String? displayFormat;

  _Detection({
    this.items,
    this.type,
    this.displayFormat,
  });

  factory _Detection.fromJson(Map<String, dynamic> json) =>
      _$DetectionFromJson(json);

  Map<String, dynamic> toJson() => _$DetectionToJson(this);
}
