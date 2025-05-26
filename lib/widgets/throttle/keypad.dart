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

import 'package:Frontend/constants/key_codes.dart';
import 'package:Frontend/models/loco.dart';
import 'package:Frontend/widgets/throttle/key_press_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class Keypad extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final Loco loco;
  final KeyPressNotifier keyPressNotifier;

  const Keypad({
    super.key,
    required this.focusNode,
    required this.loco,
    required this.keyPressNotifier,
  });

  @override
  ConsumerState<Keypad> createState() => KeypadState();
}

/// \todo document
class KeypadState extends ConsumerState<Keypad> {
  int _level = 0;

  /// Workaround for GridButton stealing focus
  bool _focusNodeHadFocus = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => _focusNodeHadFocus = widget.focusNode.hasFocus,
      child: GridButton(
        items: [
          [
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f1),
              1 => _functionButtonItem(KeyCodes.f11),
              2 => _functionButtonItem(KeyCodes.f21),
              3 => _functionButtonItem(KeyCodes.f31),
              _ => throw UnimplementedError(),
            },
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f2),
              1 => _functionButtonItem(KeyCodes.f12),
              2 => _functionButtonItem(KeyCodes.f22),
              3 => _functionButtonItem(KeyCodes.f32, true),
              _ => throw UnimplementedError(),
            },
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f3),
              1 => _functionButtonItem(KeyCodes.f13),
              2 => _functionButtonItem(KeyCodes.f23),
              3 => _functionButtonItem(KeyCodes.f33, true),
              _ => throw UnimplementedError(),
            },
            GridButtonItem(
              value: -3,
              child: Icon(
                (widget.loco.rvvvvvvv ?? 0x80) & 0x80 != 0
                    ? Icons.switch_left
                    : Icons.switch_right,
                size: 32,
              ),
            ),
          ],
          [
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f4),
              1 => _functionButtonItem(KeyCodes.f14),
              2 => _functionButtonItem(KeyCodes.f24),
              3 => _functionButtonItem(KeyCodes.f34, true),
              _ => throw UnimplementedError(),
            },
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f5),
              1 => _functionButtonItem(KeyCodes.f15),
              2 => _functionButtonItem(KeyCodes.f25),
              3 => _functionButtonItem(KeyCodes.f35, true),
              _ => throw UnimplementedError(),
            },
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f6),
              1 => _functionButtonItem(KeyCodes.f16),
              2 => _functionButtonItem(KeyCodes.f26),
              3 => _functionButtonItem(KeyCodes.f36, true),
              _ => throw UnimplementedError(),
            },
            const GridButtonItem(
              title: kDebugMode ? 'MAN' : '',
              textStyle: TextStyle(fontFamily: 'DSEG14'),
              value: KeyCodes.man,
            ),
          ],
          [
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f7),
              1 => _functionButtonItem(KeyCodes.f17),
              2 => _functionButtonItem(KeyCodes.f27),
              3 => _functionButtonItem(KeyCodes.f37, true),
              _ => throw UnimplementedError(),
            },
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f8),
              1 => _functionButtonItem(KeyCodes.f18),
              2 => _functionButtonItem(KeyCodes.f28),
              3 => _functionButtonItem(KeyCodes.f38, true),
              _ => throw UnimplementedError(),
            },
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f9),
              1 => _functionButtonItem(KeyCodes.f19),
              2 => _functionButtonItem(KeyCodes.f29),
              3 => _functionButtonItem(KeyCodes.f39, true),
              _ => throw UnimplementedError(),
            },
            const GridButtonItem(
              value: KeyCodes.backspace,
              longPressValue: KeyCodes.backspaceLong,
              child: Icon(Icons.backspace),
            ),
          ],
          [
            const GridButtonItem(value: KeyCodes.add, child: Icon(Icons.add)),
            switch (_level) {
              0 => _functionButtonItem(KeyCodes.f0),
              1 => _functionButtonItem(KeyCodes.f10),
              2 => _functionButtonItem(KeyCodes.f20),
              3 => _functionButtonItem(KeyCodes.f30),
              _ => throw UnimplementedError(),
            },
            const GridButtonItem(
              value: KeyCodes.remove,
              child: Icon(Icons.remove),
            ),
            const GridButtonItem(
              value: KeyCodes.enter,
              longPressValue: KeyCodes.enterLong,
              child: Icon(Icons.check_circle),
            ),
          ],
        ],
        onPressed: (keyCode) {
          // Only re-focus if it *had* focus before and currently doesn't
          if (_focusNodeHadFocus && keyCode != KeyCodes.dir) {
            FocusScope.of(context).requestFocus(widget.focusNode);
          }

          // Change level
          if (keyCode >= KeyCodes.f0Long && keyCode <= KeyCodes.f9Long) {
            setState(() => _level = (keyCode % KeyCodes.f0Long).clamp(0, 3));
          }

          // Delay to post frame callback to make sure focus is set correctly
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.keyPressNotifier.notifyKeyPress(keyCode),
          );
        },
        hideSurroundingBorder: true,
      ),
    );
  }

  /// \todo document
  GridButtonItem _functionButtonItem(int i, [bool empty = false]) {
    return GridButtonItem(
      title: empty ? '' : i.toString(),
      color: (widget.loco.f31_0 ?? 0) & (1 << i) != 0
          ? Theme.of(context).focusColor
          : null,
      textStyle: const TextStyle(fontFamily: 'DSEG14'),
      value: i,
      longPressValue: KeyCodes.f0Long + i % 10,
    );
  }
}
