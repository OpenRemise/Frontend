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

import 'package:Frontend/model/bidib/decoder_db_decoder_detection.dart';
import 'package:Frontend/model/bidib/decoder_db_manufacturers.dart';
import 'package:Frontend/model/bidib/decoder_db_repository.dart';
import 'package:Frontend/provider/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
class DecoderDetectionDialog extends ConsumerStatefulWidget {
  const DecoderDetectionDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DecoderDetectionDialogState();
}

/// \todo document
class _DecoderDetectionDialogState
    extends ConsumerState<DecoderDetectionDialog> {
  /// \todo document
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
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
        children: [Text('hi')],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
    final client = ref.read(httpClientProvider);
    final responses = await Future.wait([
      client.get(Uri.parse('https://decoderdb.bidib.org/repository.json')),
      client
          .get(Uri.parse('https://decoderdb.bidib.org/DecoderDetection.json')),
      client.get(Uri.parse('https://decoderdb.bidib.org/Manufacturers.json')),
    ]);
    final json = responses
        .map((r) => jsonDecode(r.body) as Map<String, dynamic>)
        .toList();
    final repository = DecoderDbRepository.fromJson(json[0]);
    final detection = DecoderDbDecoderDetection.fromJson(json[1]);
    final manufacturers = DecoderDbManufacturers.fromJson(json[2]);

    // https://forum.opendcc.de/viewtopic.php?p=120545#p120545
    // Das is scho mal da 1.Bug
    // Das sollten 3x Sachen sein
    // CV8 - CV107/108 und CV7
    // CV107/108 haben a anders Schema... bravo
    final readFirst = detection.protocols![0].defaultProperty!;

    // Wenn CV8 == 0xEE, dann die andern beiden a lesen
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
