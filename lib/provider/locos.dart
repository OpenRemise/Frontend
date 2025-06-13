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
            Loco(address: 2, name: 'ET22'),
            Loco(address: 3, name: 'Vectron'),
            Loco(address: 6, name: 'E2'),
            Loco(address: 10, name: 'V 36'),
            Loco(address: 14, name: 'BR 248'),
            Loco(address: 42, name: 'BR 85'),
            Loco(address: 49, name: 'ST44'),
            Loco(address: 75, name: 'Litra F'),
            Loco(address: 98, name: 'L45H'),
            Loco(address: 100, name: 'BR 247'),
            Loco(address: 130, name: 'Mh6'),
            Loco(address: 167, name: 'BR E 77'),
            Loco(address: 208, name: 'Gruppo 740'),
            Loco(address: 330, name: 'Rad 710'),
            Loco(address: 726, name: 'Gem 4/4'),
            Loco(address: 1337, name: 'Reihe 498'),
            Loco(address: 1400, name: 'Reihe 5022'),
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
