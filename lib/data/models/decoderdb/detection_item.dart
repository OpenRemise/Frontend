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

import 'package:Frontend/data/models/decoderdb/condition.dart';
import 'package:Frontend/data/models/decoderdb/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'detection_item.freezed.dart';
part 'detection_item.g.dart';

/// Entry of a detection `items` array
///
/// The schema models this as an unbounded `xs:choice` of `conditions`, `cv` and
/// `cvGroup` (DetectionType in commonTypes.xsd). Serializing that choice to
/// JSON drops the element names, so the array is flattened into the generic key
/// `items` and the variant has to be recovered from the keys that are present.
sealed class DetectionItem {
  const DetectionItem();

  factory DetectionItem.fromJson(Map<String, Object?> json) =>
      const DetectionItemConverter().fromJson(json);

  Map<String, Object?> toJson();
}

/// Single CV to read during detection
///
/// Mirrors CVType of commonTypes.xsd, reduced to the attributes that occur in
/// detections. [indexHigh] and [indexLow] select a CV bank for decoders that
/// use indexed CVs.
@freezed
abstract class Cv extends DetectionItem with _$Cv {
  const Cv._();

  const factory Cv({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'mode') String? mode,
    @JsonKey(name: 'indexHigh') int? indexHigh,
    @JsonKey(name: 'indexLow') int? indexLow,
  }) = _Cv;

  factory Cv.fromJson(Map<String, Object?> json) => _$CvFromJson(json);
}

/// Several CVs combined into one logical value
///
/// Mirrors CVGroupType of commonTypes.xsd. [cvs] is ordered most significant
/// byte first, so `{108, 107}` of a [CvGroupType.integer] group yields
/// `cv108 << 8 | cv107`.
@freezed
abstract class CvGroup extends DetectionItem with _$CvGroup {
  const CvGroup._();

  const factory CvGroup({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'mode') String? mode,
    @Default([]) @JsonKey(name: 'cvs') List<Cv> cvs,
  }) = _CvGroup;

  factory CvGroup.fromJson(Map<String, Object?> json) =>
      _$CvGroupFromJson(json);
}

/// Gate that decides whether the surrounding detection applies at all
///
/// Mirrors ConditionsType of commonTypes.xsd. Only reached when a preceding
/// detection already read the CVs the triggers refer to.
@freezed
abstract class ConditionsItem extends DetectionItem with _$ConditionsItem {
  const ConditionsItem._();

  const factory ConditionsItem({
    @Default([]) @JsonKey(name: 'triggers') List<Trigger> triggers,
  }) = _ConditionsItem;

  factory ConditionsItem.fromJson(Map<String, Object?> json) =>
      _$ConditionsItemFromJson(json);
}

/// Recovers the [DetectionItem] variant from the keys present in the map
class DetectionItemConverter
    implements JsonConverter<DetectionItem, Map<String, Object?>> {
  const DetectionItemConverter();

  @override
  DetectionItem fromJson(Map<String, Object?> json) {
    if (json.containsKey('triggers')) return ConditionsItem.fromJson(json);
    if (json.containsKey('cvs')) return CvGroup.fromJson(json);
    return Cv.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(DetectionItem object) => object.toJson();
}
