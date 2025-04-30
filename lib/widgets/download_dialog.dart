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

import 'dart:typed_data';

import 'package:Frontend/providers/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';

/// \todo document
class DownloadDialog extends ConsumerStatefulWidget {
  final String _url;

  const DownloadDialog(this._url, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DownloadDialogState();
}

/// \todo document
class _DownloadDialogState extends ConsumerState<DownloadDialog> {
  final List<int> _bytes = [];
  String _status = '';
  double? _progress;

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
    final params = Uri.parse(widget._url).queryParameters;
    final fileName =
        params['f'] ?? params['id'] ?? File(widget._url).uri.pathSegments.last;

    return AlertDialog(
      title: const Text('Download'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: _progress),
          Text(_status),
          Text(fileName),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  /// \todo document
  Future<void> _execute() async {
    final client = ref.read(httpClientProvider);
    final request = http.Request('GET', Uri.parse(widget._url));
    final response = await client.send(request);
    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      response.stream.listen(
        (chunk) => setState(() {
          _bytes.addAll(chunk);
          _status = 'Downloading';
          if (contentLength > 0) {
            _status +=
                ' ${_bytes.length ~/ 1024} / ${contentLength ~/ 1024} kB';
            _progress = _bytes.length / contentLength;
          }
        }),
        onDone: () {
          if (mounted) Navigator.pop(context, Uint8List.fromList(_bytes));
        },
        onError: (error) => setState(() {
          _status = 'Downloading failed';
        }),
      );
    } else {
      setState(() {
        _status = 'Downloading failed';
      });
    }
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
