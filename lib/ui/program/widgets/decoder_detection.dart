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

import 'package:Frontend/data/models/decoderdb/decoder_detection.dart';
import 'package:Frontend/data/models/decoderdb/repository.dart';
import 'package:Frontend/data/models/decoderdb/types.dart';
import 'package:Frontend/data/services/http_client.dart';
import 'package:Frontend/domain/models/decoder.dart';
import 'package:Frontend/ui/core/widgets/default_animated_size.dart';
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
          LinearProgressIndicator(value: _progress),
          Text(_status),
          DefaultAnimateSize(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
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
    final DetectionProtocol dcc = _detection.protocols.firstWhere(
      (protocol) => protocol.type == ProtocolType.dcc,
    );
    await _detections(dcc.defaults);

    // setState(() => _status = 'Detect manufacturer');
    // final manufacturer = dcc.manufacturers.firstWhere(
    //   (manufacturer) =>
    //       manufacturer.id == _values['manufacturerId'] &&
    //       manufacturer.extendedId == _values['manufacturerExtendedId'],
    // );
    // await _detections(manufacturer.detections);

    // await _downloadDecoderDefinition();

    // await _downloadFirmwareDefinition();

    // setState(() {
    //   _status = '';
    //   _option = 'OK';
    //   _progress = 0;
    // });
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
    _detection = DecoderDetectionFile.fromJson(jsonDecode(response.body));
  }

  Future<void> _detections(List<Detection> detections) async {
    for (final detection in detections) {}
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
