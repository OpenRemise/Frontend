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

import 'package:Frontend/data/models/decoderdb/common_types.dart';
import 'package:Frontend/data/models/decoderdb/decoder_definition.dart';
import 'package:Frontend/data/models/decoderdb/decoder_detection.dart';
import 'package:Frontend/data/models/decoderdb/firmware_definition.dart';
import 'package:Frontend/data/models/decoderdb/repository.dart';
import 'package:Frontend/data/repositories/roco/z21_cv.dart';
import 'package:Frontend/data/services/http_client.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/domain/models/decoder.dart';
import 'package:Frontend/ui/core/widgets/default_animated_size.dart';
import 'package:Frontend/utils/parse_display_format.dart';
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
  late final DecoderDetectionFile _detection;
  DecoderDefinitionFile? _decoder;
  FirmwareDefinitionFile? _firmware;
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
    final manufacturerName =
        _decoder?.decoderDefinition.decoder.manufacturerName;
    final manufacturerUrl = _decoder?.decoderDefinition.decoder.manufacturerUrl;
    final type = _decoder?.decoderDefinition.decoder.type;
    final dimensions =
        _decoder?.decoderDefinition.decoder.specifications?.dimensions;
    final connectors =
        _decoder?.decoderDefinition.decoder.specifications?.connectors;
    final image = _decoder?.decoderDefinition.decoder.images.firstOrNull?.image;

    return AlertDialog(
      title: const Text('DecoderDB'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: _progress),
          Text(_status),
          DefaultAnimateSize(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_decoder != null)
                  ListTile(
                    title: Text(_decoder!.decoderDefinition.decoder.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (manufacturerName != null) Text(manufacturerName),
                        if (manufacturerUrl != null) Text(manufacturerUrl),
                        if (type != null)
                          Text(type[0].toUpperCase() + type.substring(1)),
                        if (dimensions != null)
                          Text(
                            '${dimensions.length}x${dimensions.width}x${dimensions.height}',
                          ),
                        if (connectors != null)
                          Text('${connectors.connectorList}'),
                        if (image != null)
                          Image.network(image.first.src, fit: BoxFit.fitWidth),
                      ],
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
    final DetectionProtocol dcc =
        _detection.decoderDetection.protocols.firstWhere(
      (protocol) => protocol.type == 'dcc',
    );
    await _detections(dcc.defaults.detections);

    setState(() => _status = 'Detect manufacturer');
    final manufacturer = dcc.manufacturers.firstWhere(
      (manufacturer) =>
          manufacturer.id == _values['manufacturerId'] &&
          manufacturer.extendedId == _values['manufacturerExtendedId'],
    );
    await _detections(manufacturer.detections);

    await _downloadDecoderDefinition();

    await _downloadFirmwareDefinition();

    setState(() {
      _status = '';
      _option = 'OK';
      _progress = 0;
    });
  }

  /// \todo document
  Future<void> _downloadRepository() async {
    final client = ref.read(httpClientProvider);
    final response =
        await client.get(Uri.parse('https://decoderdb.de/?listAllJson'));
    _repository = Repository.fromJson(jsonDecode(response.body));
  }

  /// \todo document
  Future<void> _downloadDecoderDetection() async {
    final client = ref.read(httpClientProvider);
    final response =
        await client.get(Uri.parse(_repository.decoderDetections.link));
    _detection = DecoderDetectionFile.fromJson(jsonDecode(response.body));
  }

  /// \todo document
  Future<void> _detections(List<Detection> detections) async {
    for (final detection in detections) {
      // Only continue if conditions are met
      if (!await _conditions(detection.conditions)) continue;

      // Read either CVs...
      if (detection.cvs.isNotEmpty) {
        final cvs =
            await Future.wait(detection.cvs.map((cv) => _read(cv.number)));
        _values[detection.type] = detection.displayFormat != null
            ? parseDisplayFormat(detection.displayFormat!, cvs.cast<int>())
            : cvs.join('.');
      }

      // ... or an entire group
      for (final cvGroup in detection.cvGroups) {
        final cvs =
            await Future.wait(cvGroup.cvs.map((cv) => _read(cv.number)));
        assert(['int', 'long'].contains(cvGroup.type));
        final value = cvs.reversed.fold(0, (value, cv) => value << 8 | cv!);
        _values[detection.type] = detection.displayFormat != null
            ? parseDisplayFormat(detection.displayFormat!, [value])
            : value.toString();
      }
    }
  }

  /// \todo document
  Future<bool> _conditions(List<Condition> conditions) async {
    bool retval = conditions.isEmpty;
    for (final condition in conditions) {
      final results = await Future.wait(condition.conditions.map(_conditionCv));
      switch (condition.value) {
        case 'notRelevant':
          retval = true;
          break;
        case 'notInUse':
          retval = true;
          break;
        case 'reset':
          retval = true;
          break;
        case 'load':
          retval = true;
          break;
        case 'valid':
          retval |= results.every((e) => e);
          break;
      }
    }
    return retval;
  }

  /// \todo document
  Future<bool> _conditionCv(ConditionCv conditionCv) async {
    // Leaf
    if (conditionCv.conditions.isEmpty) {
      assert(conditionCv.type == 'relational');

      /// \todo add those
      assert(conditionCv.indexHigh == null && conditionCv.indexLow == null);

      final cv = await _read(conditionCv.cv!);

      switch (conditionCv.operation) {
        case 'equal':
          return cv == int.parse(conditionCv.value!);
        case 'unEqual':
          return cv != int.parse(conditionCv.value!);
        case 'greater':
          return cv! > int.parse(conditionCv.value!);
        case 'greaterEqual':
          return cv! >= int.parse(conditionCv.value!);
        case 'less':
          return cv! < int.parse(conditionCv.value!);
        case 'lessEqual':
          return cv! <= int.parse(conditionCv.value!);
        case 'valid':
          return cv != null;
        case 'inValid':
          return cv == null;
      }
    }
    // Nested
    else {
      assert(conditionCv.type == 'logical');
      final results =
          await Future.wait(conditionCv.conditions.map(_conditionCv));
      switch (conditionCv.operation) {
        case 'and':
          return results.every((e) => e);
        case 'or':
          return results.any((e) => e);
      }
    }

    return false;
  }

  /// \todo document
  Future<void> _downloadDecoderDefinition() async {
    final client = ref.read(httpClientProvider);
    final links = _repository.decoders.where(
      (decoder) =>
          decoder.manufacturerId.toString() == _values['manufacturerId'] &&
          decoder.manufacturerExtendedId?.toString() ==
              _values['manufacturerExtendedId'],
    );
    final responses =
        await Future.wait(links.map((l) => client.get(Uri.parse(l.link))));
    final files = responses
        .map((r) => DecoderDefinitionFile.fromJson(jsonDecode(r.body)));
    final filesWithId = files.where(
      (f) =>
          f.decoderDefinition.decoder.typeIds
              ?.split(';')
              .contains(_values['decoderId']) ??
          false,
    );
    assert(filesWithId.length == 1);
    setState(() => _decoder = filesWithId.first);
  }

  /// \todo document
  Future<void> _downloadFirmwareDefinition() async {
    final client = ref.read(httpClientProvider);
    final links = _repository.firmwares.where(
      (firmware) =>
          firmware.manufacturerId.toString() == _values['manufacturerId'] &&
          firmware.manufacturerExtendedId?.toString() ==
              _values['manufacturerExtendedId'],
    );
    final responses =
        await Future.wait(links.map((l) => client.get(Uri.parse(l.link))));
    final files = responses
        .map((r) => FirmwareDefinitionFile.fromJson(jsonDecode(r.body)));
    final filesWithName = files.where(
      (f) => f.decoderFirmwareDefinition.firmware.decoders!.decoder
          .any((d) => d.name == _decoder!.decoderDefinition.decoder.name),
    );
    filesWithName.forEach(
      (f) => debugPrint(f.decoderFirmwareDefinition.firmware.version),
    );
    setState(() => _firmware = filesWithName.last);
  }

  /// \todo document
  Future<int?> _read(int number) async {
    final result =
        await ref.read(z21CvProvider(widget.decoder).notifier).read(number - 1);
    return result is LanXCvResult ? result.value : null;
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
