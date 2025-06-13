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

import 'package:Frontend/model/register.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'throttle_registry.g.dart';

@Riverpod(keepAlive: true)
class ThrottleRegistry extends _$ThrottleRegistry {
  @override
  Set<Register> build() {
    // Remove deleted addresses
    ref.listen<SplayTreeSet<Loco>>(locosProvider, (previous, next) {
      final previousAddresses = previous?.map((l) => l.address).toSet() ?? {};
      final nextAddresses = next.map((l) => l.address).toSet();

      final removed = previousAddresses.difference(nextAddresses);
      final added = nextAddresses.difference(previousAddresses);

      final newState = Set<Register>.from(state);

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

    return <Register>{};
  }

  /// \todo document
  void updateLoco(int address, Loco loco) {
    final controller = state.firstWhereOrNull((c) => c.address == address);
    // Add
    if (controller == null) {
      state = Set<Register>.from(state)
        ..add(Register(key: UniqueKey(), address: address));
    }
    // Update
    else if (address != loco.address) {
      state = Set<Register>.from(state)
        ..remove(controller)
        ..add(controller.copyWith(address: loco.address));
    }
    // Don't update (but move to end of set)
    else if (address == loco.address) {
      state = Set<Register>.from(state)
        ..remove(controller)
        ..add(controller);
    }
  }

  /// \todo document
  void deleteLocos() {
    state = <Register>{};
  }

  /// \todo document
  void deleteLoco(int address) {
    state = Set<Register>.from(state)
      ..remove(state.firstWhereOrNull((c) => c.address == address));
  }
}
