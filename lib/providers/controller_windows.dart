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

import 'dart:collection';

import 'package:Frontend/models/controller_window.dart';
import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'controller_windows.g.dart';

@Riverpod(keepAlive: true)
class ControllerWindows extends _$ControllerWindows {
  @override
  SplayTreeSet<ControllerWindow> build() {
    // Remove deleted addresses
    ref.listen<SplayTreeSet<Loco>>(locosProvider, (previous, next) {
      final previousAddresses = previous?.map((l) => l.address).toSet() ?? {};
      final nextAddresses = next.map((l) => l.address).toSet();

      final removed = previousAddresses.difference(nextAddresses);
      final added = nextAddresses.difference(previousAddresses);

      final newState = SplayTreeSet<ControllerWindow>.from(state);

      for (final removedAddress in removed) {
        // Possible address change
        if (removed.length == 1 &&
            added.length == 1 &&
            previousAddresses.length == nextAddresses.length) {
          // Address change detected
          final window =
              state.firstWhereOrNull((w) => w.locoAddress == removedAddress);
          if (window != null) {
            newState
              ..remove(window)
              ..add(window.copyWith(locoAddress: added.first));
          }
        } else {
          // Normal removal
          newState.removeWhere((w) => w.locoAddress == removedAddress);
        }
      }

      state = newState;
    });

    return SplayTreeSet<ControllerWindow>();
  }

  /// \todo document
  void updateLoco(int address, Loco loco) {
    final window = state.firstWhereOrNull((w) => w.locoAddress == address);
    // Add
    if (window == null) {
      state = SplayTreeSet<ControllerWindow>.from(state)
        ..add(ControllerWindow(key: UniqueKey(), locoAddress: address));
    }
    // Update
    else if (address != loco.address) {
      state = SplayTreeSet<ControllerWindow>.from(state)
        ..remove(window)
        ..add(window.copyWith(locoAddress: loco.address));
    }
  }

  /// \todo document
  void deleteLocos() {
    state = SplayTreeSet<ControllerWindow>();
  }

  /// \todo document
  void deleteLoco(int address) {
    state = SplayTreeSet<ControllerWindow>.from(state)
      ..remove(state.firstWhereOrNull((w) => w.locoAddress == address));
  }
}
