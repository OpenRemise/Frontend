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

/// Decoder detection state
///
/// \file   ui/program/view_models/decoder_detection_state.dart
/// \author Vincent Hamp
/// \date   24/09/2026

// ignore_for_file: constant_identifier_names

import 'package:Frontend/data/models/decoderdb/decoder_definition.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'decoder_detection_state.freezed.dart';

enum DecoderDetectionStatus { Idle, Detecting, Completed, Failed }

@freezed
abstract class DecoderDetectionState with _$DecoderDetectionState {
  const factory DecoderDetectionState({
    @Default(DecoderDetectionStatus.Idle) DecoderDetectionStatus status,
    @Default('') String message,
    double? progress,
    DecoderDefinitionFile? decoderDefinition,
  }) = _DecoderDetectionState;
}
