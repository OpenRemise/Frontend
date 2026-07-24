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

/// Dialog to import or export files
///
/// \file   ui/core/widgets/import_export_dialog.dart
/// \author Vincent Hamp
/// \date   23/07/2026

import 'dart:collection';
import 'dart:convert';

import 'package:Frontend/data/models/loco.dart';
import 'package:Frontend/data/models/opendcc/locxml.dart';
import 'package:Frontend/data/repositories/dcc.dart';
import 'package:Frontend/data/repositories/locos.dart';
import 'package:Frontend/ui/core/themes/text_scaler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class ImportExportDialog extends ConsumerStatefulWidget {
  const ImportExportDialog({super.key});

  @override
  ConsumerState<ImportExportDialog> createState() => _ImportExportDialogState();
}

/// \todo document
class _ImportExportDialogState extends ConsumerState<ImportExportDialog> {
  final List<int> _selected = [];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Import/export'),
      content: SizedBox(
        width: 0,
        child: Stepper(
          steps: [
            _step(
              title: Text('Select action'),
              content: Column(
                children: [
                  Card.outlined(
                    child: ListTile(
                      leading: const Icon(Icons.arrow_downward),
                      title: const Text('Import'),
                      onTap: () => setState(() {
                        ++_index;
                        _selected
                          ..removeRange(0, _selected.length)
                          ..add(0);
                      }),
                    ),
                  ),
                  Card.outlined(
                    child: ListTile(
                      leading: const Icon(Icons.arrow_upward),
                      title: const Text('Export'),
                      onTap: () => setState(() {
                        ++_index;
                        _selected
                          ..removeRange(0, _selected.length)
                          ..add(1);
                      }),
                    ),
                  ),
                ],
              ),
            ),
            _step(
              title: Text('Select format'),
              content: Column(
                children: [
                  Card.outlined(
                    child: ListTile(
                      leading: const Icon(Icons.data_object),
                      title: Text(
                        '${_selected.firstOrNull == 0 ? 'Import' : 'Export'}\u200B.Locxml',
                      ),
                      onTap: () => _selected.first == 0
                          ? _importLocxml()
                          : _exportLocxml(),
                    ),
                  ),
                ],
              ),
            ),
          ],
          physics: const NeverScrollableScrollPhysics(),
          currentStep: _index,
          onStepTapped: (int index) {
            // Only allow going backwards
            if (index <= _index) {
              setState(() {
                _index = index;
              });
            }
          },
          controlsBuilder: (context, details) => const SizedBox.shrink(),
          connectorColor:
              WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
        ),
      ),
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// \todo document
  Step _step({
    required Widget title,
    Widget? subtitle,
    required Widget content,
  }) {
    return Step(
      title: title,
      subtitle: subtitle,
      content: content,
      stepStyle: StepStyle(
        color: Theme.of(context).colorScheme.primary,
        indexStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 14 / ref.watch(textScalerProvider),
        ),
      ),
    );
  }

  /// \todo document
  Future<void> _importLocxml() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Open',
      type: FileType.custom,
      allowedExtensions: ['Locxml'],
      withData: true,
    );
    if (result == null) return;
    final newLocos = locosFromLocxml(utf8.decode(result.files.first.bytes!));
    final locos = ref.read(locosProvider);
    ref.read(dccProvider.notifier).updateLocos(
          SplayTreeSet<Loco>()
            ..addAll(newLocos)
            ..addAll(locos),
        );
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  /// \todo document
  Future<void> _exportLocxml() async {
    final locos = ref.read(locosProvider);
    final locxml = locosToLocxml(locos);
    await FilePicker.saveFile(
      dialogTitle: 'Save',
      fileName: 'OpenRemise.Locxml',
      allowedExtensions: ['Locxml'],
      bytes: utf8.encode(locxml),
    );
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
