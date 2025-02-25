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

import 'dart:convert';
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
  String _downloadUrl = '';
  String _fileName = '';
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
  void dispose() {
    super.dispose();
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
          LinearProgressIndicator(value: _progress),
          Text(_status),
          Text(_fileName),
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
    await _json();
    await _download();
  }

  /// \todo document
  Future<void> _json() async {
    //
    if (widget._url.contains('OpenRemise')) {
      final response = await http.get(Uri.parse(widget._url));
      final data = jsonDecode(response.body);
      final assets = data['assets'].first;
      setState(() {
        _downloadUrl = assets['browser_download_url'];
        _fileName = File(_downloadUrl).uri.pathSegments.last;
      });
    }
    //
    else {
      setState(() {
        _downloadUrl = widget._url;
        _fileName = File(_downloadUrl).uri.pathSegments.last;
      });
    }
  }

  /// \todo document
  Future<void> _download() async {
    final client = ref.read(httpClientProvider);
    final request = http.Request('GET', Uri.parse(_downloadUrl));
    final response = await client.send(request);
    response.stream.listen(
      (chunk) => setState(() {
        _bytes.addAll(chunk);
        _status =
            'Downloading ${_bytes.length ~/ 1024} / ${response.contentLength! ~/ 1024} kB';
        _progress = _bytes.length / response.contentLength!;
      }),
      onDone: () {
        if (mounted) Navigator.pop(context, Uint8List.fromList(_bytes));
      },
      onError: (error) => debugPrint('OH OH'),
    );
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
