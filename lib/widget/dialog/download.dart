// Copyright (C) 2025 Vincent Hamp
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

/// Dialog to download file and show progress
///
/// \file   widget/dialog/download.dart
/// \author Vincent Hamp
/// \date   25/02/2025

import 'dart:typed_data';

import 'package:Frontend/provider/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Dialog to download files and show progress
///
/// The DownloadDialog downloads files from URLs and displays the progress
/// during the download. If the download is successful, the files are returned
/// as `List<Uint8List>`.
class DownloadDialog extends ConsumerStatefulWidget {
  final List<Uri> _uris;
  final List<String>? fileNames;

  const DownloadDialog(this._uris, {this.fileNames, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DownloadDialogState();
}

/// \todo document
class _DownloadDialogState extends ConsumerState<DownloadDialog> {
  late List<double?> _progresses;
  late List<String> _msgs;
  String _status = '';

  /// \todo document
  @override
  void initState() {
    super.initState();
    _progresses = List.filled(widget._uris.length, null);
    _msgs = List.filled(widget._uris.length, '');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < widget._uris.length; i++) ...[
            Text(
              widget.fileNames?.asMap()[i] ?? widget._uris[i].pathSegments.last,
            ),
            LinearProgressIndicator(value: _progresses[i]),
            Text(_msgs[i]),
          ],
          Text(_status),
        ],
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

    final results = await Future.wait(
      widget._uris.asMap().entries.map((entry) async {
        final i = entry.key;
        final uri = entry.value;
        final request = http.Request('GET', uri);
        final response = await client.send(request);
        if (response.statusCode == 200) {
          List<int> bytes = [];
          final contentLength = response.contentLength ?? 0;
          try {
            await for (final chunk in response.stream) {
              bytes.addAll(chunk);
              setState(() {
                if (contentLength > 0) {
                  _progresses[i] = bytes.length / contentLength;
                  _msgs[i] =
                      '${bytes.length ~/ 1024} / ${contentLength ~/ 1024} kB';
                } else {
                  _msgs[i] = '${bytes.length ~/ 1024} / ? kB';
                }
                _status = 'Downloading';
              });
            }
            return bytes;
          } catch (_) {
            return null;
          }
        }
      }),
    );

    if (results.contains(null)) {
      setState(() => _status = 'Downloading failed');
    } else if (mounted) {
      Navigator.pop(
        context,
        results.map((l) => Uint8List.fromList(l!)).toList(),
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
