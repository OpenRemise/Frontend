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

/// Short circuit popup dialog
///
/// \file   widget/dialog/short_circuit.dart
/// \author Vincent Hamp
/// \date   01/11/2024

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Short circuit popup dialog
///
/// ShortCircuitDialog is a popup dialog that informs the user about short
/// circuits. The necessary listener for the status provided by the
/// z21ShortCircuitProvider is created in the [initState](https://api.flutter.dev/flutter/widgets/State/initState.html)
/// of the HomeView.
class ShortCircuitDialog extends ConsumerWidget {
  const ShortCircuitDialog({super.key});

  /// \todo document
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Short circuit'),
      content: const Icon(Icons.error),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
