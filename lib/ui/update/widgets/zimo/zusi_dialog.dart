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

/// Dialog to upload sound to ZIMO decoders
///
/// \file   ui/update/widgets/zimo/zusi_dialog.dart
/// \author Vincent Hamp
/// \date   01/11/2024

import 'package:Frontend/domain/models/zimo/zpp.dart';
import 'package:Frontend/ui/update/view_models/state.dart';
import 'package:Frontend/ui/update/view_models/zimo/zusi_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dialog to upload sound to ZIMO decoders
///
/// ZusiDialog is a manufacturer-specific dialog for ZIMO decoders. It uses the
/// eponymous [ZUSI](https://github.com/ZIMO-Elektronik/ZUSI) protocol to load
/// sound via [SUSI](https://normen.railcommunity.de/RCN-600.pdf) bus.
class ZusiDialog extends ConsumerStatefulWidget {
  final Zpp _zpp;

  const ZusiDialog.zpp(this._zpp, {super.key});

  @override
  ConsumerState<ZusiDialog> createState() => _ZusiDialogState();
}

/// \todo document
class _ZusiDialogState extends ConsumerState<ZusiDialog> {
  /// \todo document
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(zusiViewModelProvider.notifier)
          .update(widget._zpp)
          .catchError((_) {}),
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zusiViewModelProvider);

    return AlertDialog(
      title: const Text('ZUSI'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: state.progress,
          ),
          Text(state.message),
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
