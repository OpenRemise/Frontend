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

/// Dialog to export files
///
/// \file   ui/core/widgets/export_dialog.dart
/// \author Vincent Hamp
/// \date   03/08/2026

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:Frontend/data/models/loco.dart';
import 'package:Frontend/data/models/opendcc/locxml.dart';
import 'package:Frontend/data/repositories/locos.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class ExportDialog extends ConsumerWidget {
  const ExportDialog({super.key});

  /// \todo document
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Export'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.data_object),
              title: Text('Export .Locxml'),
              onTap: () async {
                final locos = ref.read(locosProvider);
                if (await _locxml(locos) == null) return;
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.pest_control_rodent),
              title: Text(
                'Export locos to ᴡʟᴀɴMAUS',
              ),
              onTap: () {
                final service = ref.read(z21ServiceProvider);
                final locos = ref.read(locosProvider);
                unawaited(_wlanmaus(service, locos));
                Navigator.pop(context);
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

  /// \todo document
  Future<String?> _locxml(SplayTreeSet<Loco> locos) async {
    final locxml = locosToLocxml(locos);
    return await FilePicker.saveFile(
      dialogTitle: 'Save',
      fileName: 'OpenRemise.Locxml',
      allowedExtensions: ['Locxml'],
      bytes: utf8.encode(locxml),
    );
  }

  /// \todo document
  Future<void> _wlanmaus(Z21Service service, SplayTreeSet<Loco> locos) async {
    for (final (index, loco) in locos.indexed) {
      for (int i = 0; i < 2; ++i) {
        service(
          LanXSetLocoEntry(
            locoAddress: loco.address,
            index: index,
            size: locos.length,
            name: loco.name,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
}
