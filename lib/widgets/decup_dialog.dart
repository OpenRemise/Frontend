// Copyright (C) 2024 Vincent Hamp
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

import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/decup_service.dart';
import 'package:Frontend/services/decup_service.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DecupDialog extends ConsumerStatefulWidget {
  final Uint8List? _bytes;
  final Uri? _uri;

  const DecupDialog.fromFile(this._bytes, {super.key}) : _uri = null;
  const DecupDialog.fromUri(this._uri, {super.key}) : _bytes = null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DecupDialogState();
}

class _DecupDialogState extends ConsumerState<DecupDialog> {
  late final Zsu _zsu;
  late final DecupService _decup;
  late final StreamQueue<Uint8List> _events;
  final Map<int, ListTile> _decoders = {};
  String _status = '';
  String _option = 'Cancel';
  double? _progress;

  @override
  void initState() {
    debugPrint('DecupDialog initState');
    super.initState();
    _decup = ref.read(decupServiceProvider);
    _events = StreamQueue(_decup.stream);
    if (widget._bytes != null) _zsu = Zsu(widget._bytes!);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _execute().catchError((_) {}),
    );
  }

  @override
  void dispose() {
    debugPrint('DecupDialog dispose');
    _decup.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('DECUP'),
      children: [
        SimpleDialogOption(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: _progress),
              Text(_status),
            ],
          ),
        ),
        SimpleDialogOption(
          child: AnimatedSize(
            alignment: Alignment.topCenter,
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final tile in _decoders.values) tile],
            ),
          ),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(_option),
          ),
        ),
      ],
    );
  }

  Future<void> _execute() async {}
}
