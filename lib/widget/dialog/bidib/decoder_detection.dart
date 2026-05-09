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
/// \file   widget/dialog/bidib/decoder_db.dart
/// \author Vincent Hamp
/// \date   27/03/2026

import 'dart:convert';

import 'package:Frontend/model/bidib/decoder_db.dart';
import 'package:Frontend/model/decoder.dart';
import 'package:Frontend/provider/http_client.dart';
import 'package:Frontend/provider/roco/z21_cv.dart';
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
  String _status = '';
  String _option = 'Cancel';
  double? _progress;
  late final DecoderDbRepository _repository;
  late final DecoderDbManufacturers _manufacturers;
  late final DecoderDbDecoderDetection _detection;

  /// \todo document
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute()
          .catchError((_) => setState(() => _status = 'Internal error')),
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
    await _download();

    await _readDefaults(
      _detection.protocols!
          .firstWhere((element) => element.type == 'dcc')
          .defaults!,
    );
  }

  /// \todo document
  Future<void> _download() async {
    setState(() => _status = 'Downloading');
    final client = ref.read(httpClientProvider);

    var response = await client
        .get(Uri.parse('https://decoderdb.bidib.org/repository.json'));
    _repository = DecoderDbRepository.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    response = await client.get(Uri.parse(_repository.manufacturers!.link!));
    _manufacturers = DecoderDbManufacturers.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    response =
        await client.get(Uri.parse(_repository.decoderDetections!.link!));
    _detection = DecoderDbDecoderDetection.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// \todo document
  Future<void> _readDefaults(
    List<DecoderDbDecoderDetectionDefault> defaults,
  ) async {
    for (final def in defaults) {
      def.items?.forEach(
        (item) async {
          for (final trigger
              in item.triggers ?? <DecoderDbDecoderDetectionTriggers>[]) {
            for (final condition in trigger.conditions ??
                <DecoderDbDecoderDetectionConditions>[]) {
              // Check condition here, return if false?
              debugPrint('$condition');
            }
          }

          if (item.number != null) {
            debugPrint('${item.number}');
            await ref
                .read(z21CvProvider(widget.decoder).notifier)
                .read(item.number! - 1);
          }

          for (final cv in item.cvs ?? []) {
            debugPrint('${cv.number}');
            if (cv.number != null) {
              await ref
                  .read(z21CvProvider(widget.decoder).notifier)
                  .read(cv.number! - 1);
            }
          }
        },
      );
    }
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
