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

/// Dialog to download ZPP project from ZIMO sound database
///
/// \file   widget/dialog/zimo/sound.dart
/// \author Vincent Hamp
/// \date   07/03/2025

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dialog to download ZPP project from ZIMO sound database
///
/// SoundDialog parses the [ZIMO sound database](https://www.zimo.at/web2010/sound/tableindex.htm)
/// and creates a searchable list of [ZPP](https://github.com/ZIMO-Elektronik/ZPP)
/// projects. These projects can then be downloaded directly.
class SoundDialog extends ConsumerStatefulWidget {
  const SoundDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SoundDialogState();
}

/// \todo document
class _SoundDialogState extends ConsumerState<SoundDialog> {
  List<String> _urls = [];
  String _str = '';

  /// \todo document
  @override
  void initState() {
    super.initState();

    // No REST API, no fun :(
    http
        .get(Uri.parse('https://www.zimo.at/web2010/sound/tableindex.htm'))
        .then(
      (response) {
        final exp = RegExp(r'href=".+.zpp"');
        setState(() {
          _urls = exp
              .allMatches(response.body)
              .map(
                (href) =>
                    href
                        .group(0)
                        ?.replaceAll('href="..', 'https://www.zimo.at/web2010')
                        .replaceAll('&amp;', '&')
                        .replaceAll('.zpp"', '.zpp') ??
                    '',
              )
              .toList();
        });
      },
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    RegExp exp;
    try {
      exp = RegExp(_str);
    } on FormatException {
      exp = RegExp('.*');
    }
    final matches = _urls.where((url) => exp.firstMatch(url) != null);
    final nonMatches = _urls.where((url) => exp.firstMatch(url) == null);

    return SimpleDialog(
      title: const Text('ZIMO Sound Database'),
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
      children: [
        ..._urls.isEmpty
            ? [const SimpleDialogOption(child: LinearProgressIndicator())]
            : [
                SimpleDialogOption(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      labelText: 'Search',
                      isDense: true,
                    ),
                    onChanged: (str) => setState(() => _str = str),
                  ),
                ),
                ...matches.map(
                  (url) {
                    final params = Uri.parse(url).queryParameters;
                    final fileName = params['f']!;
                    return SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, url),
                      child: Text(fileName),
                    );
                  },
                ),
                ...nonMatches.map(
                  (url) {
                    final params = Uri.parse(url).queryParameters;
                    final fileName = params['f']!;
                    return SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, url),
                      child: Text(fileName),
                    );
                  },
                ),
              ],
      ],
    );
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
