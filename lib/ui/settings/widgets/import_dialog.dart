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

/// Dialog to import files
///
/// \file   ui/core/widgets/import_dialog.dart
/// \author Vincent Hamp
/// \date   03/08/2026

import 'dart:collection';
import 'dart:convert';

import 'package:Frontend/data/models/loco.dart';
import 'package:Frontend/data/models/opendcc/locxml.dart';
import 'package:Frontend/data/repositories/dcc.dart';
import 'package:Frontend/data/repositories/locos.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportDialog extends ConsumerWidget {
  const ImportDialog({super.key});

  /// \todo document
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Import'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.data_object),
              title: Text('Import .Locxml'),
              onTap: () async {
                final result = await FilePicker.pickFiles(
                  dialogTitle: 'Open',
                  type: FileType.custom,
                  allowedExtensions: ['Locxml'],
                  withData: true,
                );
                if (result == null) return;
                final newLocos =
                    locosFromLocxml(utf8.decode(result.files.first.bytes!));
                final locos = ref.read(locosProvider);
                ref.read(dccProvider.notifier).updateLocos(
                      SplayTreeSet<Loco>()
                        ..addAll(newLocos)
                        ..addAll(locos),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
