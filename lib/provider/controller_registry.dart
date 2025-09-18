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

import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/register.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/provider/turnouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'controller_registry.g.dart';

@Riverpod(keepAlive: true)
class ControllerRegistry extends _$ControllerRegistry {
  @override
  LinkedHashSet<Register> build() {
    // Listen for Loco changes
    ref.listen<SplayTreeSet<Loco>>(
      locosProvider,
      (previous, next) => _syncItems<Loco>(previous, next, (l) => l.address),
    );

    // Listen for Turnout changes
    ref.listen<SplayTreeSet<Turnout>>(
      turnoutsProvider,
      (previous, next) => _syncItems<Turnout>(previous, next, (t) => t.address),
    );

    return LinkedHashSet<Register>();
  }

  void _syncItems<T>(
    SplayTreeSet<T>? previous,
    SplayTreeSet<T> next,
    int Function(T) addressSelector,
  ) {
    final prevAddresses = previous?.map(addressSelector).toSet() ?? {};
    final nextAddresses = next.map(addressSelector).toSet();

    final removed = prevAddresses.difference(nextAddresses);
    final added = nextAddresses.difference(prevAddresses);

    final newState = LinkedHashSet<Register>.from(state);

    for (final removedAddress in removed) {
      if (removed.length == 1 &&
          added.length == 1 &&
          prevAddresses.length == nextAddresses.length) {
        // Address change detected
        final controller = state.firstWhereOrNull(
          (r) => r.type == T && r.address == removedAddress,
        );
        if (controller != null) {
          newState
            ..remove(controller)
            ..add(controller.copyWith(address: added.first));
        }
      } else {
        // Normal removal
        newState.removeWhere((r) => r.type == T && r.address == removedAddress);
      }
    }

    // Remove turnouts with type == 1 (Hidden)
    if (T == Turnout) {
      final hidden =
          next.where((t) => (t as Turnout).type == 1).map(addressSelector);
      for (final address in hidden) {
        newState.removeWhere((r) => r.type == Turnout && r.address == address);
      }
    }

    state = newState;
  }

  // Generic update method for any object type
  void updateItem<T>(int oldAddress, int newAddress) {
    final existing = state.firstWhereOrNull(
      (c) => c.type == T && c.address == oldAddress,
    );

    final newState = LinkedHashSet<Register>.from(state);

    if (existing == null) {
      // Add
      newState.add(
        Register(
          key: UniqueKey(),
          type: T,
          address: newAddress,
        ),
      );
    } else if (oldAddress != newAddress) {
      // Address change
      newState
        ..remove(existing)
        ..add(existing.copyWith(address: newAddress));
    } else {
      // Same address → move to end
      newState
        ..remove(existing)
        ..add(existing);
    }

    state = newState;
  }

  // Generic delete by address & type
  void deleteItem<T>(int address) {
    state = LinkedHashSet<Register>.from(state)
      ..removeWhere((c) => c.type == T && c.address == address);
  }
}
