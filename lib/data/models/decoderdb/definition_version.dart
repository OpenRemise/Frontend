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

part 'definition_version.freezed.dart';
part 'definition_version.g.dart';

/// Authorship and revision info carried by every DecoderDB definition file
///
/// Mirrors VersionType of commonTypes.xsd.
@freezed
abstract class DefinitionVersion with _$DefinitionVersion {
  const factory DefinitionVersion({
    @JsonKey(name: 'createdBy') String? createdBy,
    @JsonKey(name: 'creatorLink') String? creatorLink,
    @JsonKey(name: 'author') String? author,
    @JsonKey(name: 'lastUpdate') DateTime? lastUpdate,
    @JsonKey(name: 'created') DateTime? created,
  }) = _DefinitionVersion;

  factory DefinitionVersion.fromJson(Map<String, Object?> json) =>
      _$DefinitionVersionFromJson(json);
}
