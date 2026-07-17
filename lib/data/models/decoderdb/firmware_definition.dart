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

import 'package:Frontend/data/models/decoderdb/common_types.dart';
import 'package:Frontend/data/models/decoderdb/json_helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'firmware_definition.freezed.dart';
part 'firmware_definition.g.dart';

// ---------------------------------------------------------------------------
// Top-level wrappers
// ---------------------------------------------------------------------------

/// Top-level wrapper for individual firmware JSON files
@freezed
abstract class FirmwareDefinitionFile with _$FirmwareDefinitionFile {
  const factory FirmwareDefinitionFile({
    @JsonKey(name: 'decoderFirmwareDefinition')
    required FirmwareDefinition decoderFirmwareDefinition,
  }) = _FirmwareDefinitionFile;

  factory FirmwareDefinitionFile.fromJson(Map<String, Object?> json) =>
      _$FirmwareDefinitionFileFromJson(json);
}

/// Firmware definition containing version and firmware info
@freezed
abstract class FirmwareDefinition with _$FirmwareDefinition {
  const factory FirmwareDefinition({
    @JsonKey(name: 'version') required Version version,
    @JsonKey(name: 'firmware') required FirmwareInfo firmware,
  }) = _FirmwareDefinition;

  factory FirmwareDefinition.fromJson(Map<String, Object?> json) =>
      _$FirmwareDefinitionFromJson(json);
}

// ---------------------------------------------------------------------------
// Firmware info
// ---------------------------------------------------------------------------

/// Detailed firmware information
@freezed
abstract class FirmwareInfo with _$FirmwareInfo {
  const factory FirmwareInfo({
    @JsonKey(name: 'version') required String version,
    @JsonKey(name: 'releaseDate') String? releaseDate,
    @JsonKey(name: 'manufacturerId') required int manufacturerId,
    @JsonKey(name: 'manufacturerExtendedId') int? manufacturerExtendedId,
    @JsonKey(name: 'manufacturerName') String? manufacturerName,
    @JsonKey(name: 'manufacturerShortName') String? manufacturerShortName,
    @JsonKey(name: 'manufacturerUrl') String? manufacturerUrl,
    @JsonKey(name: 'versionExtension') String? versionExtension,
    @JsonKey(name: 'decoderDBLink') String? decoderDBLink,
    @JsonKey(name: 'options') String? options,
    @JsonKey(name: 'decoders') FirmwareDecoders? decoders,
    @JsonKey(name: 'manuals') FirmwareManuals? manuals,
    @Default([])
    @JsonKey(name: 'protocols', readValue: readNestedAsList)
    List<FirmwareProtocol> protocols,
  }) = _FirmwareInfo;

  factory FirmwareInfo.fromJson(Map<String, Object?> json) =>
      _$FirmwareInfoFromJson(json);
}

// ---------------------------------------------------------------------------
// Decoder references
// ---------------------------------------------------------------------------

/// Container for the list of decoder references in a firmware
@freezed
abstract class FirmwareDecoders with _$FirmwareDecoders {
  const factory FirmwareDecoders({
    @Default([])
    @JsonKey(name: 'decoder', readValue: readAsList)
    List<FirmwareDecoderRef> decoder,
  }) = _FirmwareDecoders;

  factory FirmwareDecoders.fromJson(Map<String, Object?> json) =>
      _$FirmwareDecodersFromJson(json);
}

/// Reference to a decoder supported by this firmware.
@freezed
abstract class FirmwareDecoderRef with _$FirmwareDecoderRef {
  const factory FirmwareDecoderRef({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'typeIds') String? typeIds,
    @JsonKey(name: 'type') String? type,
  }) = _FirmwareDecoderRef;

  factory FirmwareDecoderRef.fromJson(Map<String, Object?> json) =>
      _$FirmwareDecoderRefFromJson(json);
}

// ---------------------------------------------------------------------------
// Manuals
// ---------------------------------------------------------------------------

/// Container for the list of manuals in a firmware
@freezed
abstract class FirmwareManuals with _$FirmwareManuals {
  const factory FirmwareManuals({
    @Default([])
    @JsonKey(name: 'manual', readValue: readAsList)
    List<FirmwareManual> manual,
  }) = _FirmwareManuals;

  factory FirmwareManuals.fromJson(Map<String, Object?> json) =>
      _$FirmwareManualsFromJson(json);
}

/// Individual manual metadata
@freezed
abstract class FirmwareManual with _$FirmwareManual {
  const factory FirmwareManual({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'src') required String src,
    @JsonKey(name: 'lastModified') String? lastModified,
    @JsonKey(name: 'fileSize') int? fileSize,
    @JsonKey(name: 'sha1') String? sha1,
    @JsonKey(name: 'copyright') String? copyright,
  }) = _FirmwareManual;

  factory FirmwareManual.fromJson(Map<String, Object?> json) =>
      _$FirmwareManualFromJson(json);
}

// ---------------------------------------------------------------------------
// Protocols
// ---------------------------------------------------------------------------

/// Protocol-specific firmware configuration (DCC, MM, mfx, etc.)
@freezed
abstract class FirmwareProtocol with _$FirmwareProtocol {
  const factory FirmwareProtocol({
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'speedSteps') String? speedSteps,
    @JsonKey(name: 'functions') int? functions,
    @JsonKey(name: 'progModes') String? progModes,
    @JsonKey(name: 'options') String? options,
    @JsonKey(name: 'railcom') String? railcom,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
    @JsonKey(name: 'cvChangelog') CvChangelog? cvChangelog,
    @JsonKey(name: 'cvStructure') CvStructure? cvStructure,
    @JsonKey(name: 'decoderDetection')
    FirmwareDecoderDetection? decoderDetection,
    @JsonKey(name: 'resets') FirmwareResets? resets,
    @JsonKey(name: 'cvs') FirmwareCvs? cvs,
  }) = _FirmwareProtocol;

  factory FirmwareProtocol.fromJson(Map<String, Object?> json) =>
      _$FirmwareProtocolFromJson(json);
}

// ---------------------------------------------------------------------------
// CV changelog
// ---------------------------------------------------------------------------

/// Changelog tracking new and changed CVs for this firmware version
@freezed
abstract class CvChangelog with _$CvChangelog {
  const factory CvChangelog({
    @JsonKey(name: 'new') String? newCvs,
    @JsonKey(name: 'changed') String? changed,
  }) = _CvChangelog;

  factory CvChangelog.fromJson(Map<String, Object?> json) =>
      _$CvChangelogFromJson(json);
}

// ---------------------------------------------------------------------------
// CV structure (categories)
// ---------------------------------------------------------------------------

/// CV structure organizing CVs into categories
@freezed
abstract class CvStructure with _$CvStructure {
  const factory CvStructure({
    @Default([])
    @JsonKey(name: 'category', readValue: readAsList)
    List<CvCategory> category,
  }) = _CvStructure;

  factory CvStructure.fromJson(Map<String, Object?> json) =>
      _$CvStructureFromJson(json);
}

/// Category in the CV structure. Can be recursive (subcategories)
@freezed
abstract class CvCategory with _$CvCategory {
  const factory CvCategory({
    @Default([]) @JsonKey(name: 'description') List<Description> description,
    @Default([])
    @JsonKey(name: 'idReference', readValue: readAsList)
    List<CvIdReference> idReference,
    @Default([])
    @JsonKey(name: 'presetGroupIdReference', readValue: readAsList)
    List<CvIdReference> presetGroupIdReference,
    @Default([])
    @JsonKey(name: 'category', readValue: readAsList)
    List<CvCategory> category,
  }) = _CvCategory;

  factory CvCategory.fromJson(Map<String, Object?> json) =>
      _$CvCategoryFromJson(json);
}

/// Reference to a CV definition by its id
@freezed
abstract class CvIdReference with _$CvIdReference {
  const factory CvIdReference({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'activeItems') String? activeItems,
  }) = _CvIdReference;

  factory CvIdReference.fromJson(Map<String, Object?> json) =>
      _$CvIdReferenceFromJson(json);
}

// ---------------------------------------------------------------------------
// Decoder detection within firmware
// ---------------------------------------------------------------------------

/// Decoder detection entries within a firmware protocol
@freezed
abstract class FirmwareDecoderDetection with _$FirmwareDecoderDetection {
  const factory FirmwareDecoderDetection({
    @Default([])
    @JsonKey(name: 'detection', readValue: readAsList)
    List<Detection> detection,
  }) = _FirmwareDecoderDetection;

  factory FirmwareDecoderDetection.fromJson(Map<String, Object?> json) =>
      _$FirmwareDecoderDetectionFromJson(json);
}

// ---------------------------------------------------------------------------
// Resets
// ---------------------------------------------------------------------------

/// Container for reset entries
@freezed
abstract class FirmwareResets with _$FirmwareResets {
  const factory FirmwareResets({
    @Default([])
    @JsonKey(name: 'reset', readValue: readAsList)
    List<FirmwareReset> reset,
  }) = _FirmwareResets;

  factory FirmwareResets.fromJson(Map<String, Object?> json) =>
      _$FirmwareResetsFromJson(json);
}

/// Individual reset operation
@freezed
abstract class FirmwareReset with _$FirmwareReset {
  const factory FirmwareReset({
    @JsonKey(name: 'cv') required int cv,
    @JsonKey(name: 'value') required String value,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
  }) = _FirmwareReset;

  factory FirmwareReset.fromJson(Map<String, Object?> json) =>
      _$FirmwareResetFromJson(json);
}

// ---------------------------------------------------------------------------
// CVs container
// ---------------------------------------------------------------------------

/// Container for CV definitions and CV group definitions
@freezed
abstract class FirmwareCvs with _$FirmwareCvs {
  const factory FirmwareCvs({
    @Default([]) @JsonKey(name: 'cv') List<CvDefinition> cv,
    @Default([]) @JsonKey(name: 'cvGroup') List<CvGroupDefinition> cvGroup,
  }) = _FirmwareCvs;

  factory FirmwareCvs.fromJson(Map<String, Object?> json) =>
      _$FirmwareCvsFromJson(json);
}

// ---------------------------------------------------------------------------
// CV definition
// ---------------------------------------------------------------------------

/// Full CV definition with all metadata, conditions, and sub-elements
@freezed
abstract class CvDefinition with _$CvDefinition {
  const factory CvDefinition({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'possibleValues') String? possibleValues,
    @JsonKey(name: 'defaultValue') int? defaultValue,
    @JsonKey(name: 'mode') String? mode,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
    @Default([])
    @JsonKey(name: 'conditions', readValue: readNestedAsList)
    List<Condition> conditions,
    @Default([])
    @JsonKey(name: 'valueCalculation')
    List<CvValueCalculation> valueCalculation,
    @Default([]) @JsonKey(name: 'group') List<CvGroupSelect> group,
    @Default([]) @JsonKey(name: 'bit') List<CvBit> bit,
    @Default([])
    @JsonKey(name: 'bitSelection')
    List<CvBitSelection> bitSelection,
    @Default([]) @JsonKey(name: 'partial') List<CvPartial> partial,
    @JsonKey(name: 'pomWriteExclude') bool? pomWriteExclude,
  }) = _CvDefinition;

  factory CvDefinition.fromJson(Map<String, Object?> json) =>
      _$CvDefinitionFromJson(json);
}

// ---------------------------------------------------------------------------
// CV group definition
// ---------------------------------------------------------------------------

/// Full CV group definition (e.g. long address, speed curve)
@freezed
abstract class CvGroupDefinition with _$CvGroupDefinition {
  const factory CvGroupDefinition({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'mode') String? mode,
    @Default([]) @JsonKey(name: 'cv') List<DetectionCv> cv,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
    @JsonKey(name: 'defaultValue') int? defaultValue,
    @JsonKey(name: 'possibleValues') String? possibleValues,
    @Default([])
    @JsonKey(name: 'conditions', readValue: readNestedAsList)
    List<Condition> conditions,
    @JsonKey(name: 'options') String? options,
    @JsonKey(name: 'pomWriteExclude') bool? pomWriteExclude,
    @JsonKey(name: 'stringEncoding') String? stringEncoding,
  }) = _CvGroupDefinition;

  factory CvGroupDefinition.fromJson(Map<String, Object?> json) =>
      _$CvGroupDefinitionFromJson(json);
}

// ---------------------------------------------------------------------------
// CV sub-elements: group select, option, bit, bit selection, partial
// ---------------------------------------------------------------------------

/// Select-group within a CV for enumerated values
@freezed
abstract class CvGroupSelect with _$CvGroupSelect {
  const factory CvGroupSelect({
    @JsonKey(name: 'number') required int number,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
    @Default([]) @JsonKey(name: 'option') List<CvOption> option,
  }) = _CvGroupSelect;

  factory CvGroupSelect.fromJson(Map<String, Object?> json) =>
      _$CvGroupSelectFromJson(json);
}

/// Option within a select-group or bit-selection
@freezed
abstract class CvOption with _$CvOption {
  const factory CvOption({
    @JsonKey(name: 'value') required String value,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
    @JsonKey(name: 'reset') bool? reset,
  }) = _CvOption;

  factory CvOption.fromJson(Map<String, Object?> json) =>
      _$CvOptionFromJson(json);
}

/// Bit definition within a CV
@freezed
abstract class CvBit with _$CvBit {
  const factory CvBit({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'value') String? value,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
  }) = _CvBit;

  factory CvBit.fromJson(Map<String, Object?> json) => _$CvBitFromJson(json);
}

/// Bit-selection within a CV, offering two options
@freezed
abstract class CvBitSelection with _$CvBitSelection {
  const factory CvBitSelection({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'value') String? value,
    @Default([]) @JsonKey(name: 'option') List<CvOption> option,
  }) = _CvBitSelection;

  factory CvBitSelection.fromJson(Map<String, Object?> json) =>
      _$CvBitSelectionFromJson(json);
}

/// Partial CV entry (sub-field within a CV)
@freezed
abstract class CvPartial with _$CvPartial {
  const factory CvPartial({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'possibleValues') String? possibleValues,
    @JsonKey(name: 'multiply') int? multiply,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
    @Default([])
    @JsonKey(name: 'valueCalculation')
    List<CvValueCalculation> valueCalculation,
  }) = _CvPartial;

  factory CvPartial.fromJson(Map<String, Object?> json) =>
      _$CvPartialFromJson(json);
}

// ---------------------------------------------------------------------------
// Value calculation
// ---------------------------------------------------------------------------

/// Value calculation formula for displaying CV values with units
@freezed
abstract class CvValueCalculation with _$CvValueCalculation {
  const factory CvValueCalculation({
    @JsonKey(name: 'unit') String? unit,
    @JsonKey(name: 'digits') String? digits,
    @Default([]) @JsonKey(name: 'item') List<CvValueCalculationItem> item,
    @Default([])
    @JsonKey(name: 'specialValue')
    List<CvSpecialValue> specialValue,
  }) = _CvValueCalculation;

  factory CvValueCalculation.fromJson(Map<String, Object?> json) =>
      _$CvValueCalculationFromJson(json);
}

/// Item in a value calculation expression. Can be recursive
@freezed
abstract class CvValueCalculationItem with _$CvValueCalculationItem {
  const factory CvValueCalculationItem({
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'value') String? value,
    @Default([]) @JsonKey(name: 'item') List<CvValueCalculationItem> item,
  }) = _CvValueCalculationItem;

  factory CvValueCalculationItem.fromJson(Map<String, Object?> json) =>
      _$CvValueCalculationItemFromJson(json);
}

/// Special value override with description
@freezed
abstract class CvSpecialValue with _$CvSpecialValue {
  const factory CvSpecialValue({
    @JsonKey(name: 'value') required String value,
    @Default([]) @JsonKey(name: 'description') List<Description> description,
  }) = _CvSpecialValue;

  factory CvSpecialValue.fromJson(Map<String, Object?> json) =>
      _$CvSpecialValueFromJson(json);
}
