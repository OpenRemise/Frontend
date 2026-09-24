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

/// Decoder detection view model
///
/// \file   ui/update/decoder_detection_view_model.dart
/// \author Vincent Hamp
/// \date   24/09/2026

import 'package:Frontend/data/models/decoderdb/detection_item.dart';
import 'package:Frontend/data/repositories/roco/z21_cv.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/domain/models/decoder.dart';
import 'package:Frontend/ui/program/view_models/decoder_detection_state.dart';
import 'package:Frontend/ui/program/view_models/exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'decoder_detection_view_model.g.dart';

/// \todo document
@Riverpod()
class DecoderDetectionViewModel extends _$DecoderDetectionViewModel {
  late final Decoder _decoder;

  /// \todo document
  @override
  DecoderDetectionState build(Decoder decoder) {
    _decoder = decoder;
    return DecoderDetectionState();
  }

  /// \todo document
  Future<void> detect() async {
    try {} on ProgramException catch (e) {
      state = state.copyWith(
        status: DecoderDetectionStatus.Failed,
        message: e.message,
        progress: 0,
      );
    }
  }

  /// \todo document
  Future<int?> _readCv(Cv cv) async {
    final z21Cv = ref.read(z21CvProvider(_decoder).notifier);
    if ((cv.indexHigh != null &&
            await z21Cv.indexHigh(cv.indexHigh!) is! LanXCvResult) ||
        (cv.indexLow != null &&
            await z21Cv.indexLow(cv.indexLow!) is! LanXCvResult)) {
      return null;
    }
    final result = await z21Cv.read(cv.number - 1);
    return result is LanXCvResult ? result.value : null;
  }
}
