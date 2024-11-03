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

import 'package:Frontend/providers/dcc.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/selected_loco_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteLocoDialog extends ConsumerStatefulWidget {
  final int? _index;

  const DeleteLocoDialog(int? index, {super.key}) : _index = index;

  @override
  ConsumerState<DeleteLocoDialog> createState() => _DeleteLocoDialogState();
}

class _DeleteLocoDialogState extends ConsumerState<DeleteLocoDialog> {
  @override
  Widget build(BuildContext context) {
    // Don't watch provider here, otherwise this widget might get rebuilt with an invalid index
    // Please be aware that this contradicts the documentation
    final locos = ref.read(locosProvider);
    final loco = widget._index != null ? locos[widget._index!] : null;

    return AlertDialog(
      title: Text('Delete ${loco == null ? 'all' : loco.name}'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (loco != null) {
              ref.read(dccProvider.notifier).deleteLoco(loco.address);
            } else {
              ref.read(dccProvider.notifier).deleteLocos();
            }

            // Deselect
            if (loco == null ||
                widget._index == ref.read(selectedLocoIndexProvider)) {
              ref
                  .read(selectedLocoIndexProvider.notifier)
                  .update((state) => null);
            }

            Navigator.pop(context, true);
          },
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

void showDeleteLocoDialog({required BuildContext context, int? index}) {
  showDialog(
    context: context,
    builder: (_) => DeleteLocoDialog(index),
  );
}
