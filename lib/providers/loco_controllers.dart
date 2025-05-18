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

import 'package:Frontend/models/controller.dart';
import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loco_controllers.g.dart';

@Riverpod(keepAlive: true)
class LocoControllers extends _$LocoControllers {
  @override
  Set<Controller> build() {
    // Remove deleted addresses
    ref.listen<SplayTreeSet<Loco>>(locosProvider, (previous, next) {
      final previousAddresses = previous?.map((l) => l.address).toSet() ?? {};
      final nextAddresses = next.map((l) => l.address).toSet();

      final removed = previousAddresses.difference(nextAddresses);
      final added = nextAddresses.difference(previousAddresses);

      final newState = Set<Controller>.from(state);

      for (final removedAddress in removed) {
        // Possible address change
        if (removed.length == 1 &&
            added.length == 1 &&
            previousAddresses.length == nextAddresses.length) {
          // Address change detected
          final controller =
              state.firstWhereOrNull((c) => c.address == removedAddress);
          if (controller != null) {
            newState
              ..remove(controller)
              ..add(controller.copyWith(address: added.first));
          }
        } else {
          // Normal removal
          newState.removeWhere((c) => c.address == removedAddress);
        }
      }

      state = newState;
    });

    return <Controller>{};
  }

  /// \todo document
  void updateLoco(int address, Loco loco) {
    final controller = state.firstWhereOrNull((c) => c.address == address);
    // Add
    if (controller == null) {
      state = Set<Controller>.from(state)
        ..add(Controller(key: UniqueKey(), address: address));
    }
    // Update
    else if (address != loco.address) {
      state = Set<Controller>.from(state)
        ..remove(controller)
        ..add(controller.copyWith(address: loco.address));
    }
    // Don't update
    else if (address == loco.address) {
      state = Set<Controller>.from(state)
        ..remove(controller)
        ..add(controller);
    }
  }

  /// \todo document
  void deleteLocos() {
    state = <Controller>{};
  }

  /// \todo document
  void deleteLoco(int address) {
    state = Set<Controller>.from(state)
      ..remove(state.firstWhereOrNull((c) => c.address == address));
  }
}
