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

///
///
/// \file   ui/program/widgets/decoder_detection.dart
/// \author Vincent Hamp
/// \date   27/03/2026

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
import 'package:Frontend/ui/core/widgets/default_animated_size.dart';
import 'package:Frontend/ui/core/widgets/fill_available_width.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
class DecoderDetectionDialog extends ConsumerStatefulWidget {
  final Decoder decoder;

  const DecoderDetectionDialog({super.key, required this.decoder});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DecoderDetectionDialogState();
}

/// \todo document
class _DecoderDetectionDialogState
    extends ConsumerState<DecoderDetectionDialog> {
  final Map<String, String> _values = {};
  late final Repository _repository;
  late final DecoderDetectionFile _decoderDetection;
  DecoderDefinitionFile? _decoderDefinition;
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  /// \todo document
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((e) => setState(() => _status = '$e')),
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('DecoderDB'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultAnimateSize(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_decoderDefinition == null)
                  ? [LinearProgressIndicator(value: _progress), Text(_status)]
                  : [
                      Text(_decoderDefinition!.decoder.name),
                      Text(_decoderDefinition!.decoder.type),
                      /*
                      loco
                      loco-sound
                      function
                      function-sound
                      car
                      car-sound
                      susi
                      susi-sound
                      standardAccessory
                      extendedAccessory
                      */
                      FillAvailableWidth(
                        child: Image.network(
                          'https://decoderdb.bidib.org/decoder/145/images/MS450P22_persp.png',
                          // fit: BoxFit.contain,
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_option),
        ),
      ],
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// \todo document
  Future<void> _execute() async {
    setState(() => _status = 'Downloading');
    await _downloadRepository();
    await _downloadDecoderDetection();

    setState(() => _status = 'Detect defaults');
    final DetectionProtocol dcc = _decoderDetection.protocols
        .firstWhere((protocol) => protocol.type == 'dcc');
    for (final detection in dcc.defaults) {
      await _detection(detection);
    }

    setState(() => _status = 'Detect manufacturer');
    final DetectionManufacturer manufacturer = dcc.manufacturers.firstWhere(
      (manufacturer) =>
          manufacturer.id.toString() == _values['manufacturerId'] &&
          manufacturer.extendedId.toString() ==
              (_values['manufacturerExtendedId'] ?? '0'),
    );
    for (final detection in manufacturer.detections) {
      await _detection(detection);
    }

    await _downloadDecoderDefinition();

    debugPrint('$_decoderDefinition');
  }

  /// \todo document
  Future<void> _downloadRepository() async {
    final client = ref.read(httpClientProvider);
    final response = await client
        .get(Uri.parse('https://decoderdb.bidib.org/repository.json'));
    _repository = Repository.fromJson(jsonDecode(response.body));
  }

  /// \todo document
  Future<void> _downloadDecoderDetection() async {
    final client = ref.read(httpClientProvider);
    final response =
        await client.get(Uri.parse(_repository.decoderDetections.link));
    _decoderDetection =
        DecoderDetectionFile.fromJson(jsonDecode(response.body));
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
  Future<void> _downloadDecoderDefinition() async {
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
    setState(() => _decoderDefinition = filesWithId.first);
  }

  /// \todo document
  Future<int?> _readCv(Cv cv) async {
    final z21Cv = ref.read(z21CvProvider(widget.decoder).notifier);
    if ((cv.indexHigh != null &&
            await z21Cv.indexHigh(cv.indexHigh!) is! LanXCvResult) ||
        (cv.indexLow != null &&
            await z21Cv.indexLow(cv.indexLow!) is! LanXCvResult)) {
      return null;
    }
    final result = await z21Cv.read(cv.number - 1);
    return result is LanXCvResult ? result.value : null;
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
