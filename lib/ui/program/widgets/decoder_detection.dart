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
  final String _option = 'Cancel';
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
          LinearProgressIndicator(value: _progress),
          Text(_status),
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

    debugPrint(_decoder?.decoderDefinition.decoder.name);
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
      // Only continue if condition is met
      if (!_conditions(detection.conditions)) continue;

      // Read either CVs...
      if (detection.cvs.isNotEmpty) {
        final cvs =
            await Future.wait(detection.cvs.map((cv) => _read(cv.number)));
        // TODO correct displayFormat
        _values[detection.type] = cvs.join('.');
      }

      // ... or an entire group
      for (final cvGroup in detection.cvGroups) {
        final cvs =
            await Future.wait(cvGroup.cvs.map((cv) => _read(cv.number)));
        assert(['int', 'long'].contains(cvGroup.type));
        _values[detection.type] =
            cvs.reversed.fold(0, (value, cv) => value << 8 | cv).toString();
      }
    }
  }

  /// \todo document
  bool _conditions(List<Condition> conditions) {
    for (final condition in conditions) {
      for (final trigger in condition.triggers) {
        for (final condition in trigger.conditions) {
          final cvs = ref.read(z21CvProvider(widget.decoder));
          final command = cvs[(condition.cv! - 1, 0, 1)] as LanXCvResult;
          if (command.value != int.tryParse(condition.value!)) return false;
        }
      }
    }

    return true;
  }

  /// \todo document
  Future<int> _read(int number) async {
    final result =
        await ref.read(z21CvProvider(widget.decoder).notifier).read(number - 1);
    if (result is LanXCvResult) {
      return result.value;
    } else {
      // not sure if that's a good idea
      throw 'Reading CV$number failed';
    }
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
          true,
    );
    assert(filesWithId.length == 1);
    _decoder = filesWithId.first;
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
    _firmware = filesWithName.first;
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
