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

/// DecoderDB repository
///
/// \file   model/bidib/decoder_db_repository.dart
/// \author Vincent Hamp
/// \date   27/03/2026

import 'package:json_annotation/json_annotation.dart';
part 'decoder_db_repository.g.dart';

@JsonSerializable()
class DecoderDbRepository {
  @JsonKey(name: 'version')
  int? version;
  @JsonKey(name: 'manufacturers')
  _Manufacturers? manufacturers;
  @JsonKey(name: 'decoderDetections')
  _DecoderDetections? decoderDetections;
  @JsonKey(name: 'decoder')
  List<_Decoder>? decoder;
  @JsonKey(name: 'firmware')
  List<_Firmware>? firmware;
  @JsonKey(name: 'image')
  List<_Image>? image;

  DecoderDbRepository({
    this.version,
    this.manufacturers,
    this.decoderDetections,
    this.decoder,
    this.firmware,
    this.image,
  });

  factory DecoderDbRepository.fromJson(Map<String, dynamic> json) =>
      _$DecoderDbRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$DecoderDbRepositoryToJson(this);
}

@JsonSerializable()
class _Manufacturers {
  @JsonKey(name: 'nmraListDate')
  String? nmraListDate;
  @JsonKey(name: 'filename')
  String? filename;
  @JsonKey(name: 'link')
  String? link;
  @JsonKey(name: 'lastUpdate')
  String? lastUpdate;
  @JsonKey(name: 'sha1')
  String? sha1;
  @JsonKey(name: 'fileSize')
  int? fileSize;

  _Manufacturers({
    this.nmraListDate,
    this.filename,
    this.link,
    this.lastUpdate,
    this.sha1,
    this.fileSize,
  });

  factory _Manufacturers.fromJson(Map<String, dynamic> json) =>
      _$ManufacturersFromJson(json);

  Map<String, dynamic> toJson() => _$ManufacturersToJson(this);
}

@JsonSerializable()
class _DecoderDetections {
  @JsonKey(name: 'filename')
  String? filename;
  @JsonKey(name: 'link')
  String? link;
  @JsonKey(name: 'lastUpdate')
  String? lastUpdate;
  @JsonKey(name: 'sha1')
  String? sha1;
  @JsonKey(name: 'fileSize')
  int? fileSize;

  _DecoderDetections({
    this.filename,
    this.link,
    this.lastUpdate,
    this.sha1,
    this.fileSize,
  });

  factory _DecoderDetections.fromJson(Map<String, dynamic> json) =>
      _$DecoderDetectionsFromJson(json);

  Map<String, dynamic> toJson() => _$DecoderDetectionsToJson(this);
}

@JsonSerializable()
class _Decoder {
  @JsonKey(name: 'manufacturerId')
  int? manufacturerId;
  @JsonKey(name: 'manufacturerExtendedId')
  int? manufacturerExtendedId;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'created')
  String? created;
  @JsonKey(name: 'filename')
  String? filename;
  @JsonKey(name: 'link')
  String? link;
  @JsonKey(name: 'lastUpdate')
  String? lastUpdate;
  @JsonKey(name: 'sha1')
  String? sha1;
  @JsonKey(name: 'fileSize')
  int? fileSize;

  _Decoder({
    this.manufacturerId,
    this.manufacturerExtendedId,
    this.name,
    this.created,
    this.filename,
    this.link,
    this.lastUpdate,
    this.sha1,
    this.fileSize,
  });

  factory _Decoder.fromJson(Map<String, dynamic> json) =>
      _$DecoderFromJson(json);

  Map<String, dynamic> toJson() => _$DecoderToJson(this);
}

@JsonSerializable()
class _Firmware {
  @JsonKey(name: 'manufacturerId')
  int? manufacturerId;
  @JsonKey(name: 'manufacturerExtendedId')
  int? manufacturerExtendedId;
  @JsonKey(name: 'version')
  String? version;
  @JsonKey(name: 'versionExtension')
  String? versionExtension;
  @JsonKey(name: 'created')
  String? created;
  @JsonKey(name: 'decoder')
  List<_FirmwareDecoder>? decoder;
  @JsonKey(name: 'filename')
  String? filename;
  @JsonKey(name: 'link')
  String? link;
  @JsonKey(name: 'lastUpdate')
  String? lastUpdate;
  @JsonKey(name: 'sha1')
  String? sha1;
  @JsonKey(name: 'fileSize')
  int? fileSize;

  _Firmware({
    this.manufacturerId,
    this.manufacturerExtendedId,
    this.version,
    this.versionExtension,
    this.created,
    this.decoder,
    this.filename,
    this.link,
    this.lastUpdate,
    this.sha1,
    this.fileSize,
  });

  factory _Firmware.fromJson(Map<String, dynamic> json) =>
      _$FirmwareFromJson(json);

  Map<String, dynamic> toJson() => _$FirmwareToJson(this);
}

@JsonSerializable()
class _FirmwareDecoder {
  @JsonKey(name: 'name')
  String? name;

  _FirmwareDecoder({
    this.name,
  });

  factory _FirmwareDecoder.fromJson(Map<String, dynamic> json) =>
      _$FirmwareDecoderFromJson(json);

  Map<String, dynamic> toJson() => _$FirmwareDecoderToJson(this);
}

@JsonSerializable()
class _Image {
  @JsonKey(name: 'manufacturerId')
  int? manufacturerId;
  @JsonKey(name: 'manufacturerExtendedId')
  int? manufacturerExtendedId;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'filename')
  String? filename;
  @JsonKey(name: 'link')
  String? link;
  @JsonKey(name: 'lastUpdate')
  String? lastUpdate;
  @JsonKey(name: 'sha1')
  String? sha1;
  @JsonKey(name: 'fileSize')
  int? fileSize;

  _Image({
    this.manufacturerId,
    this.manufacturerExtendedId,
    this.name,
    this.filename,
    this.link,
    this.lastUpdate,
    this.sha1,
    this.fileSize,
  });

  factory _Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
