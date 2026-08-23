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

import 'package:json_annotation/json_annotation.dart';

/// Digital command protocol a definition applies to
///
/// Mirrors ProtocolTypeType of commonTypes.xsd. Note that the schema spells
/// sx2 in lower case, but the published data uses sX2.
enum ProtocolType {
  @JsonValue('dcc')
  dcc,
  @JsonValue('mm')
  mm,
  @JsonValue('mfx')
  mfx,
  @JsonValue('sx')
  sx,
  @JsonValue('sX2')
  sx2,
  @JsonValue('susi')
  susi,
}

/// Property of a decoder that can be read out to identify it
///
/// Mirrors DetectionTypeType of commonTypes.xsd.
enum DetectionType {
  @JsonValue('manufacturerId')
  manufacturerId,
  @JsonValue('manufacturerExtendedId')
  manufacturerExtendedId,
  @JsonValue('decoderId')
  decoderId,
  @JsonValue('firmwareVersion')
  firmwareVersion,
  @JsonValue('serialNumber')
  serialNumber,
}

/// Interpretation of a single CV value
///
/// Mirrors CVTypeType of commonTypes.xsd.
enum CvType {
  @JsonValue('byte')
  byte,
  @JsonValue('select')
  select,
  @JsonValue('signedByte')
  signedByte,
}

/// Access mode of a CV
///
/// Mirrors CVModeType of commonTypes.xsd.
enum CvMode {
  @JsonValue('rw')
  readWrite,
  @JsonValue('ro')
  readOnly,
  @JsonValue('wo')
  writeOnly,
}

/// Interpretation of several CVs combined into one logical value
///
/// Mirrors CVGroupTypeType of commonTypes.xsd.
enum CvGroupType {
  @JsonValue('list')
  list,
  @JsonValue('dccLongAddr')
  dccLongAddr,
  @JsonValue('dccSpeedCurve')
  dccSpeedCurve,
  @JsonValue('dccAccAddr')
  dccAccAddr,
  @JsonValue('int')
  integer,
  @JsonValue('long')
  long,
  @JsonValue('matrix')
  matrix,
  @JsonValue('string')
  string,
  @JsonValue('dccAddrRG')
  dccAddrRG,
  @JsonValue('dccLongConsist')
  dccLongConsist,
  @JsonValue('rgbColor')
  rgbColor,
  @JsonValue('centesimalInt')
  centesimalInt,
}

/// Kind of check a condition performs
enum ConditionType {
  @JsonValue('relational')
  relational,
  @JsonValue('logical')
  logical,
  @JsonValue('decoderName')
  decoderName,
  @JsonValue('action')
  action,
}

/// Operator a condition applies
enum ConditionOperation {
  @JsonValue('equal')
  equal,
  @JsonValue('unEqual')
  unEqual,
  @JsonValue('greater')
  greater,
  @JsonValue('lessEqual')
  lessEqual,
  @JsonValue('valid')
  valid,
  @JsonValue('and')
  and,
  @JsonValue('or')
  or,
  @JsonValue('write')
  write,
}

/// Effect applied to the target when all conditions of a trigger match
enum TriggerValue {
  @JsonValue('valid')
  valid,
  @JsonValue('notRelevant')
  notRelevant,
  @JsonValue('notInUse')
  notInUse,
  @JsonValue('reset')
  reset,
  @JsonValue('load')
  load,
}
