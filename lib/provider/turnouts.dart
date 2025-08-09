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

import 'package:Frontend/model/turnout.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'turnouts.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
class Turnouts extends _$Turnouts {
  /// \todo document
  @override
  SplayTreeSet<Turnout> build() {
    return const String.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES') ==
            'true'
        ? SplayTreeSet<Turnout>.of([
            Turnout(address: 5, name: 'North right'),
            Turnout(address: 20, name: 'South left'),
            Turnout(address: 21, name: 'South right'),
            Turnout(address: 30, name: 'Yard'),
          ])
        : SplayTreeSet<Turnout>();
  }

  /// \todo document
  void updateTurnouts(SplayTreeSet<Turnout> turnouts) {
    state = turnouts;
  }

  /// \todo document
  void updateTurnout(int address, Turnout turnout) {
    state = SplayTreeSet<Turnout>.from(state)
      ..remove(state.firstWhereOrNull((l) => l.address == address))
      ..add(turnout);
  }

  /// \todo document
  void deleteTurnouts() {
    state = SplayTreeSet<Turnout>();
  }

  /// \todo document
  void deleteTurnout(int address) {
    state = SplayTreeSet<Turnout>.from(state)
      ..remove(state.firstWhereOrNull((l) => l.address == address));
  }
}
