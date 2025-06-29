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
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/widget/throttle/cv_editing_controller.dart';
import 'package:Frontend/widget/throttle/key_press_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class CvTerminal extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final Loco loco;
  final KeyPressNotifier keyPressNotifier;

  const CvTerminal({
    super.key,
    required this.focusNode,
    required this.loco,
    required this.keyPressNotifier,
  });

  @override
  ConsumerState<CvTerminal> createState() => CvTerminalState();
}

/// \todo document
class CvTerminalState extends ConsumerState<CvTerminal> {
  final CvEditingController _cvEditingController = CvEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _pending = false;

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
  }

  @override
  Widget build(BuildContext context) {
    final z21 = ref.watch(z21ServiceProvider);

    return StreamBuilder(
      stream: z21.stream.where(
        (command) => switch (command) {
          LanXCvNackSc() => true,
          LanXCvNack() => true,
          LanXStatusChanged() => true,
          LanXCvResult() => true,
          _ => false
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && _pending) {
          switch (snapshot.requireData) {
            case LanXCvNackSc():
            case LanXCvNack():
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _cvEditingController.error(),
              );
              _pending = false;
            case LanXCvResult(cvAddress: final cvAddress, value: final value):
              final cv = _cvEditingController.values();
              if (cv.number == cvAddress + 1) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _cvEditingController.success(value),
                );
                _pending = false;
              }
            default:
          }
        }

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
      },
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
    final z21 = ref.watch(z21ServiceProvider);

    final cv = _cvEditingController.values();
    if (cv.number == null) return;

    // Read
    if (cv.value == null) {
      // Service mode
      if (keyCode == KeyCodes.enterLong) {
        z21.lanXCvRead(cv.number! - 1);
        _pending = true;
      }
      // POM
      else {
        z21.lanXCvPomReadByte(widget.loco.address, cv.number! - 1);
        _pending = true;
      }
    }
    // Write
    else {
      // Service mode
      if (keyCode == KeyCodes.enterLong) {
        z21.lanXCvWrite(cv.number! - 1, cv.value!);
        _pending = true;
      }
      // POM
      else {
        z21.lanXCvPomWriteByte(widget.loco.address, cv.number! - 1, cv.value!);
        _cvEditingController.success(cv.value!);
        // Don't set pending flag for POM
      }
    }
  }
}
