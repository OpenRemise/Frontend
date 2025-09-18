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
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locos.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
class Locos extends _$Locos {
  /// \todo document
  @override
  SplayTreeSet<Loco> build() {
    return const String.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES') ==
            'true'
        ? SplayTreeSet<Loco>.of([
            Loco(address: 3, name: 'Vectron'),
            Loco(address: 98, name: 'L45H'),
            Loco(address: 208, name: 'Gruppo 740', speedSteps: 2),
            Loco(address: 726, name: 'Gem 4/4'),
            Loco(address: 1337, name: 'Reihe 498', speedSteps: 0),
            Loco(address: 2811, name: 'ASF EL 16'),
          ])
        : SplayTreeSet<Loco>();
  }

  /// \todo document
  void updateLocos(SplayTreeSet<Loco> locos) {
    state = locos;
  }

  /// \todo document
  void updateLoco(int address, Loco loco) {
    state = SplayTreeSet<Loco>.from(state)
      ..remove(state.firstWhereOrNull((l) => l.address == address))
      ..add(loco);
  }

  /// \todo document
  void deleteLocos() {
    state = SplayTreeSet<Loco>();
  }

  /// \todo document
  void deleteLoco(int address) {
    state = SplayTreeSet<Loco>.from(state)
      ..remove(state.firstWhereOrNull((l) => l.address == address));
  }
}
