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

import 'package:Frontend/data/models/loco.dart';
import 'package:Frontend/data/models/turnout.dart';
import 'package:Frontend/data/repositories/roco/z21_cv.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/domain/models/decoder.dart';
import 'package:Frontend/ui/throttle/widgets/cv_editing_controller.dart';
import 'package:Frontend/ui/throttle/widgets/key_codes.dart';
import 'package:Frontend/ui/throttle/widgets/key_press_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class CvTerminal<T> extends ConsumerStatefulWidget {
  final dynamic item;
  final FocusNode focusNode;
  final KeyPressNotifier keyPressNotifier;

  const CvTerminal({
    super.key,
    required this.item,
    required this.focusNode,
    required this.keyPressNotifier,
  }) : assert(T == Loco || T == Turnout);

  @override
  ConsumerState<CvTerminal<T>> createState() => CvTerminalState<T>();
}

/// \todo document
class CvTerminalState<T> extends ConsumerState<CvTerminal<T>> {
  final CvEditingController _cvEditingController = CvEditingController();
  final ScrollController _scrollController = ScrollController();

  /// \todo document
  @override
  void initState() {
    super.initState();

    widget.keyPressNotifier.addListener(
      () async {
        //
        _cvEditingController
            .appendKeyCode(widget.keyPressNotifier.lastKeyCode!);

        // read / write CVs HERE?
        if (_cvEditingController.text.endsWith('!') &&
            (widget.keyPressNotifier.lastKeyCode! == KeyCodes.enter ||
                widget.keyPressNotifier.lastKeyCode! == KeyCodes.enterLong)) {
          await _cvReadWrite(widget.keyPressNotifier.lastKeyCode!);
        }

        _scrollToMaxExtent();
      },
    );
  }

  @override
  void dispose() {
    _cvEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _cvEditingController,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        icon: const Icon(Icons.integration_instructions_outlined),
        hintText: 'TERMINAL\nR 1:::_\nW 1:::3',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(fontFamily: 'DSEG14'),
      readOnly: true,
      showCursor: true,
      maxLines: null,
      minLines: 1024,
      scrollController: _scrollController,
      enableInteractiveSelection: false,
      onTap: _scrollToMaxExtent,
    );
  }

  /// \todo document
  Future<void> _cvReadWrite(int keyCode) async {
    final cv = _cvEditingController.values();
    if (cv.number == null) return;

    final result =
        await (cv.value == null ? _cvRead(keyCode, cv) : _cvWrite(keyCode, cv));

    switch (result) {
      case LanXCvNackSc():
      case LanXCvNack():
        _cvEditingController.error();
        break;

      case LanXCvResult(cvAddress: final cvAddress, value: final value):
        if (cv.number == cvAddress + 1) _cvEditingController.success(value);
        break;

      default:
        break;
    }
  }

  /// \todo document
  Future<Z21Command> _cvRead(
    int keyCode,
    ({int? number, int? value}) cv,
  ) {
    return keyCode == KeyCodes.enterLong
        ? ref
            .read(z21CvProvider(Decoder(type: T)).notifier)
            .read(cv.number! - 1)
        : ref
            .read(
              z21CvProvider(Decoder(type: T, address: widget.item.address))
                  .notifier,
            )
            .read(cv.number! - 1);
  }

  /// \todo document
  Future<Z21Command> _cvWrite(
    int keyCode,
    ({int? number, int? value}) cv,
  ) {
    final cv = _cvEditingController.values();
    return keyCode == KeyCodes.enterLong
        ? ref
            .read(z21CvProvider(Decoder(type: T)).notifier)
            .write(cv.number! - 1, cv.value!)
        : ref
            .read(
              z21CvProvider(Decoder(type: T, address: widget.item.address))
                  .notifier,
            )
            .write(cv.number! - 1, cv.value!);
  }

  /// \todo document
  void _scrollToMaxExtent() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
