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

import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/dcc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dialog to delete loco or turnout
///
/// DeleteDialog is used to delete locomotives or accessories. The class is
/// generic so the type to be deleted must be passed when creating the dialog
/// (e.g. `%DeleteDialog<Loco>`). If no type is passed it will default to
/// deleting all locomotives and accessories. If a type is passed, you can
/// optionally also pass a specific item that should be deleted, instead of
/// deleting the entire category.
class DeleteDialog<T> extends ConsumerStatefulWidget {
  final dynamic item;

  const DeleteDialog({super.key, this.item});

  /// \todo document
  String tooltip() {
    return item != null
        ? 'Delete ${item.name} (${item.address})'
        : T == Loco
            ? 'Delete locos'
            : T == Turnout
                ? 'Delete accessories'
                : 'Delete all';
  }

  @override
  ConsumerState<DeleteDialog<T>> createState() => _DeleteDialogState<T>();
}

/// \todo document
class _DeleteDialogState<T> extends ConsumerState<DeleteDialog<T>> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tooltip()),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            switch (T) {
              case const (Loco):
                if (widget.item == null) {
                  ref.read(dccProvider.notifier).deleteLocos();
                } else {
                  ref
                      .read(dccProvider.notifier)
                      .deleteLoco(widget.item.address);
                }
                break;

              case const (Turnout):
                if (widget.item == null) {
                  ref.read(dccProvider.notifier).deleteTurnouts();
                } else {
                  ref
                      .read(dccProvider.notifier)
                      .deleteTurnout(widget.item.address);
                }
                break;

              default:
                ref.read(dccProvider.notifier).deleteLocos();
                ref.read(dccProvider.notifier).deleteTurnouts();
                break;
            }

            Navigator.pop(context, true);
          },
          child: const Text('OK'),
        ),
      ],
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
