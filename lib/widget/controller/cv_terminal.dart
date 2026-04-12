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

import 'package:Frontend/constant/key_codes.dart';
import 'package:Frontend/model/decoder.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/roco/z21_cv.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/widget/controller/cv_editing_controller.dart';
import 'package:Frontend/widget/controller/key_press_notifier.dart';
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
  late final List<ProviderSubscription> _subs;

  /// \todo document
  @override
  void initState() {
    super.initState();

    widget.keyPressNotifier.addListener(
      () {
        //
        _cvEditingController
            .appendKeyCode(widget.keyPressNotifier.lastKeyCode!);

        // read / write CVs HERE?
        if (_cvEditingController.text.endsWith('!') &&
            (widget.keyPressNotifier.lastKeyCode! == KeyCodes.enter ||
                widget.keyPressNotifier.lastKeyCode! == KeyCodes.enterLong)) {
          _cvReadWrite(widget.keyPressNotifier.lastKeyCode!);
        }

        _scrollToMaxExtent();
      },
    );

    _subs = [
      ref.listenManual<CvMap>(z21CvProvider(Decoder(type: T)), _update),
      ref.listenManual<CvMap>(
        z21CvProvider(Decoder(type: T, address: widget.item.address)),
        _update,
      ),
    ];
  }

  @override
  void dispose() {
    _cvEditingController.dispose();
    for (final sub in _subs) {
      sub.close();
    }
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
  void _scrollToMaxExtent() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// \todo document
  void _cvReadWrite(int keyCode) {
    final cv = _cvEditingController.values();
    if (cv.number == null) return;

    // Read
    if (cv.value == null) {
      // Service mode
      if (keyCode == KeyCodes.enterLong) {
        ref.read(z21CvProvider(Decoder(type: T)).notifier).read(cv.number! - 1);
      }
      // POM
      else {
        ref
            .read(
              z21CvProvider(Decoder(type: T, address: widget.item.address))
                  .notifier,
            )
            .read(cv.number! - 1);
      }
    }
    // Write
    else {
      // Service mode
      if (keyCode == KeyCodes.enterLong) {
        ref
            .read(z21CvProvider(Decoder(type: T)).notifier)
            .write(cv.number! - 1, cv.value!);
      }
      // POM
      else {
        ref
            .read(
              z21CvProvider(Decoder(type: T, address: widget.item.address))
                  .notifier,
            )
            .write(cv.number! - 1, cv.value!);
      }
    }
  }

  /// \todo document
  void _update(_, CvMap next) {
    final cv = _cvEditingController.values();
    if (cv.number == null || !next.containsKey((cv.number! - 1, 0, 1))) return;
    switch (next[(cv.number! - 1, 0, 1)]) {
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
}
