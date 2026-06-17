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

/// Dialog to update OpenRemise boards
///
/// \file   ui/update/widgets/ota_dialog.dart
/// \author Vincent Hamp
/// \date   01/11/2024

import 'package:Frontend/ui/update/state.dart';
import 'package:Frontend/ui/update/view_models/ota_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';

/// Dialog to update OpenRemise boards
///
/// The OtaDialog is an update dialog for OpenRemise boards. [OTA](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/ota.html)
/// stands for over-the-air and is the update mechanism developed by Espressif.
class OtaDialog extends ConsumerStatefulWidget {
  final Uint8List _bin;

  const OtaDialog.fromFile(this._bin, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtaDialogState();
}

/// \todo document
class _OtaDialogState extends ConsumerState<OtaDialog> {
  /// \todo document
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(otaViewModelProvider.notifier).update(widget._bin),
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otaViewModelProvider);

    return AlertDialog(
      title: const Text('OTA'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: state.progress),
          Text(state.message),
        ],
      ),
      actions: [
        state.status == UpdateStatus.Completed
            ? TextButton(onPressed: Restart.restartApp, child: Text('OK'))
            : TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
      ],
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
