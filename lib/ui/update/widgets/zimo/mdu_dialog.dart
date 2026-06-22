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

/// Dialog to update or upload ZIMO MS, MN, FS and FN decoders
///
/// \file   ui/update/widgets/zimo/mdu_dialog.dart
/// \author Vincent Hamp
/// \date   01/11/2024

import 'package:Frontend/data/models/zimo/zpp.dart';
import 'package:Frontend/data/models/zimo/zsu.dart';
import 'package:Frontend/ui/core/widgets/default_animated_size.dart';
import 'package:Frontend/ui/update/view_models/state.dart';
import 'package:Frontend/ui/update/view_models/zimo/mdu_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dialog to update or upload ZIMO MS, MN, FS and FN decoders
///
/// MduDialog is a manufacturer-specific dialog for ZIMO MS, MN, FS and FN
/// decoders. It uses the eponymous [MDU](https://github.com/ZIMO-Elektronik/MDU)
/// protocol to update or load sound via tracks.
class MduDialog extends ConsumerStatefulWidget {
  final Zpp? _zpp;
  final Zsu? _zsu;

  const MduDialog.zpp(this._zpp, {super.key}) : _zsu = null;
  const MduDialog.zsu(this._zsu, {super.key}) : _zpp = null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MduDialogState();
}

/// \todo document
class _MduDialogState extends ConsumerState<MduDialog> {
  /// \todo document
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(
            mduViewModelProvider(widget._zpp != null ? 'zpp/' : 'zsu/')
                .notifier,
          )
          .update(widget._zpp ?? widget._zsu)
          .catchError((_) {}),
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(mduViewModelProvider(widget._zpp != null ? 'zpp/' : 'zsu/'));

    return AlertDialog(
      title: const Text('MDU'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: state.progress),
          Text(state.message),
          DefaultAnimateSize(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final device in state.devices)
                  ListTile(
                    leading: Icon(
                      switch (device.status) {
                        UpdateStatus.Idle => Icons.circle,
                        UpdateStatus.Connecting => Icons.pending,
                        UpdateStatus.Updating => Icons.download_for_offline,
                        UpdateStatus.Completed => Icons.check_circle,
                        UpdateStatus.Failed => Icons.error,
                      },
                    ),
                    title: Text(device.name),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(state.status == UpdateStatus.Completed ? 'OK' : 'Cancel'),
        ),
      ],
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
