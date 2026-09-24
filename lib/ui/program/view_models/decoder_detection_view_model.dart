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

import 'dart:convert';

import 'package:Frontend/data/models/decoderdb/condition.dart';
import 'package:Frontend/data/models/decoderdb/decoder_definition.dart';
import 'package:Frontend/data/models/decoderdb/decoder_detection.dart';
import 'package:Frontend/data/models/decoderdb/detection_item.dart';
import 'package:Frontend/data/models/decoderdb/repository.dart';
import 'package:Frontend/data/models/decoderdb/utility.dart';
import 'package:Frontend/data/repositories/roco/z21_cv.dart';
import 'package:Frontend/data/services/http_client.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/domain/models/decoder.dart';
import 'package:Frontend/ui/program/view_models/decoder_detection_state.dart';
import 'package:Frontend/ui/program/view_models/exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'decoder_detection_view_model.g.dart';

/// \todo document
@Riverpod()
class DecoderDetectionViewModel extends _$DecoderDetectionViewModel {
  final Map<String, String> _values = {};
  late final Decoder _decoder;
  late final Repository _repository;
  late final DecoderDetectionFile _decoderDetection;

  /// \todo document
  @override
  DecoderDetectionState build(Decoder decoder) {
    _decoder = decoder;
    return DecoderDetectionState();
  }

  /// \todo document
  Future<void> detect() async {
    try {
      await _downloadRepository();
      await _downloadDecoderDetection();
      await _defaultDetections();
      await _manufacturerDetections();
      await _downloadDecoderDefinition();
    } on ProgramException catch (e) {
      state = state.copyWith(
        status: DecoderDetectionStatus.Failed,
        message: e.message,
      );
    }
  }

  /// \todo document
  Future<void> _downloadRepository() async {
    state = state.copyWith(
      status: DecoderDetectionStatus.Downloading,
      message: 'Downloading repository.json',
    );
    final client = ref.read(httpClientProvider);
    final response = await client
        .get(Uri.parse('https://decoderdb.bidib.org/repository.son'));
    _repository = Repository.fromJson(jsonDecode(response.body));
  }

  /// \todo document
  Future<void> _downloadDecoderDetection() async {
    state = state.copyWith(
      message: 'Downloading DecoderDetection.json',
    );
    final client = ref.read(httpClientProvider);
    final response =
        await client.get(Uri.parse(_repository.decoderDetections.link));
    _decoderDetection =
        DecoderDetectionFile.fromJson(jsonDecode(response.body));
  }

  /// \todo document
  Future<void> _downloadDecoderDefinition() async {
    state = state.copyWith(
      status: DecoderDetectionStatus.Completed,
      message: 'Downloading decoder definition',
    );
    final client = ref.read(httpClientProvider);
    final links = _repository.decoders.where(
      (decoder) =>
          decoder.manufacturerId.toString() == _values['manufacturerId'] &&
          decoder.manufacturerExtendedId.toString() ==
              (_values['manufacturerExtendedId'] ?? '0'),
    );
    final responses =
        await Future.wait(links.map((l) => client.get(Uri.parse(l.link))));
    final files = responses
        .map((r) => DecoderDefinitionFile.fromJson(jsonDecode(r.body)));
    final filesWithId = files.where(
      (f) =>
          f.decoder.typeIds?.split(';').contains(_values['decoderId']) ?? false,
    );
    state = state.copyWith(decoderDefinition: filesWithId.first);
  }

  /// \todo document
  Future<void> _defaultDetections() async {
    state = state.copyWith(
      status: DecoderDetectionStatus.Detecting,
      message: 'Default detections',
    );
    final DetectionProtocol dcc = _decoderDetection.protocols
        .firstWhere((protocol) => protocol.type == 'dcc');
    await _detections(dcc.defaults);
  }

  /// \todo document
  Future<void> _manufacturerDetections() async {
    state = state.copyWith(message: 'Manufacturer detections');
    final DetectionProtocol dcc = _decoderDetection.protocols
        .firstWhere((protocol) => protocol.type == 'dcc');
    final DetectionManufacturer manufacturer = dcc.manufacturers.firstWhere(
      (manufacturer) =>
          manufacturer.id.toString() == _values['manufacturerId'] &&
          manufacturer.extendedId.toString() ==
              (_values['manufacturerExtendedId'] ?? '0'),
    );
    await _detections(manufacturer.detections);
  }

  /// \todo document
  Future<void> _detections(List<Detection> detections) async {
    for (final detection in detections) {
      await _detection(detection);
    }
  }

  /// \todo document
  Future<void> _detection(Detection detection) async {
    List<int> values = [];

    for (final item in detection.items) {
      switch (item) {
        case final ConditionsItem condition:
          assert(condition.triggers.length == 1);
          if (!await _trigger(condition.triggers.first)) return;
          break;
        case final Cv cv:
          final value = await _readCv(cv);
          if (value != null) values.add(value);
          break;
        case final CvGroup cvGroup:
          assert(['int', 'long'].contains(cvGroup.type));
          final cvs = await Future.wait(cvGroup.cvs.map((cv) => _readCv(cv)));
          final value = cvs.reversed.fold(0, (value, cv) => value << 8 | cv!);
          values.add(value);
          break;
      }
    }

    _values[detection.type] = detection.displayFormat != null
        ? parseDisplayFormat(detection.displayFormat!, values)
        : values.join('.');
  }

  /// \todo document
  Future<bool> _trigger(Trigger trigger) async {
    assert(trigger.value == 'valid');
    for (final condition in trigger.conditions) {
      if (await _condition(condition)) {
        return true;
      }
    }
    return false;
  }

  /// \todo document
  Future<bool> _condition(Condition condition) async {
    // Leaf
    if (condition.conditions.isEmpty) {
      assert(condition.type == 'relational');
      assert(condition.cv != null);

      final value = await _readCv(
        Cv(
          number: int.parse(condition.cv!),
          type: '',
          indexHigh: condition.indexHigh,
          indexLow: condition.indexLow,
        ),
      );

      switch (condition.operation) {
        case 'equal':
          return value != null && insideValueSpec(value, condition.value!);
        case 'unEqual':
          return value != null && !insideValueSpec(value, condition.value!);
        case 'greater':
          return value != null && value > int.parse(condition.value!);
        case 'greaterEqual':
          return value != null && value >= int.parse(condition.value!);
        case 'less':
          return value != null && value < int.parse(condition.value!);
        case 'lessEqual':
          return value != null && value <= int.parse(condition.value!);
        case 'valid':
          return value != null;
        case 'inValid':
          return value == null;
      }
    }
    // Nested
    else {
      assert(condition.type == 'logical');
      for (final nestedCondition in condition.conditions) {
        final value = await _condition(nestedCondition);
        if (condition.operation == 'and' && !value) return false;
        if (condition.operation == 'or' && value) return true;
      }
    }

    return true;
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
