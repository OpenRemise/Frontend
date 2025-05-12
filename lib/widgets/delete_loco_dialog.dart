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

import 'package:Frontend/providers/dcc.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class DeleteLocoDialog extends ConsumerStatefulWidget {
  final int? _address;

  const DeleteLocoDialog(this._address, {super.key});

  @override
  ConsumerState<DeleteLocoDialog> createState() => _DeleteLocoDialogState();
}

/// \todo document
class _DeleteLocoDialogState extends ConsumerState<DeleteLocoDialog> {
  @override
  Widget build(BuildContext context) {
    // Don't watch provider here, otherwise this widget might get rebuilt with an invalid index
    // Please be aware that this contradicts the documentation
    final loco = ref
        .read(locosProvider)
        .firstWhereOrNull((l) => l.address == widget._address);

    return AlertDialog(
      title: Text('Delete ${loco == null ? 'all' : loco.name}'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (loco == null) {
              ref.read(dccProvider.notifier).deleteLocos();
            } else {
              ref.read(dccProvider.notifier).deleteLoco(loco.address);
            }
            Navigator.pop(context, true);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
