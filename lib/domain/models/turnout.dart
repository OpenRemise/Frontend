// Copyright (C) 2025 Vincent Hamp
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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'turnout.freezed.dart';
part 'turnout.g.dart';

/// \todo document
@freezed
abstract class Turnout with _$Turnout implements Comparable<Turnout> {
  const Turnout._();

  const factory Turnout({
    @JsonKey(name: 'address') required int address,
    @Default('') @JsonKey(name: 'name') String name,
    @Default(0) @JsonKey(name: 'type') int type,
    @Default(0) @JsonKey(name: 'mode') int mode,
    @Default(0) @JsonKey(name: 'position') int position,
    @Default(Group()) @JsonKey(name: 'group') Group group,
  }) = _Turnout;

  factory Turnout.fromJson(Map<String, Object?> json) =>
      _$TurnoutFromJson(json);

  @override
  int compareTo(Turnout other) {
    return address.compareTo(other.address);
  }
}

@freezed
abstract class Group with _$Group {
  const factory Group({
    @Default(<int>[]) @JsonKey(name: 'addresses') List<int> addresses,
    @Default(<List<int>>[])
    @JsonKey(
      name: 'positions',
      fromJson: _groupPositionsFromJson,
      toJson: _groupPositionsToJson,
    )
    List<List<int>> positions,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

List<List<int>> _groupPositionsFromJson(List<dynamic> json) {
  return json
      .map<List<int>>((e) => List.unmodifiable((e as List).cast<int>()))
      .toList(growable: false);
}

List<List<int>> _groupPositionsToJson(List<List<int>> positions) {
  return positions.map((e) => e.toList()).toList();
}
