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
            //
            Turnout(
              address: 4,
              name: 'Turnout right',
              type: 256 + 0,
              position: 1,
              group: Group(
                addresses: [4],
                positions: [
                  List.unmodifiable([1]),
                  List.unmodifiable([2]),
                ],
              ),
            ),

            //
            Turnout(
              address: 8,
              name: 'Turnout 3-way',
              type: 256 + 3,
              position: 2,
              group: Group(
                addresses: [
                  8,
                  9,
                ],
                positions: [
                  List.unmodifiable([1, 1]),
                  List.unmodifiable([1, 2]),
                  List.unmodifiable([2, 1]),
                ],
              ),
            ),
            Turnout(
              address: 9,
              name: '9',
              type: 0 + 1,
              position: 1,
              group: Group(
                addresses: [8],
                positions: [
                  List.unmodifiable([1]),
                  List.unmodifiable([2]),
                ],
              ),
            ),

            //
            Turnout(
              address: 100,
              name: 'Signal 4 aspects',
              type: 512 + 2,
              position: 1,
              group: Group(
                addresses: [
                  100,
                  101,
                ],
                positions: [
                  List.unmodifiable([1, 1]),
                  List.unmodifiable([1, 2]),
                  List.unmodifiable([2, 1]),
                  List.unmodifiable([2, 2]),
                ],
              ),
            ),
            Turnout(
              address: 101,
              name: '101',
              type: 0 + 1,
              position: 2,
              group: Group(
                addresses: [101],
                positions: [
                  List.unmodifiable([1]),
                  List.unmodifiable([2]),
                ],
              ),
            ),

            //
            Turnout(
              address: 200,
              name: 'Light',
              type: 768 + 0,
              position: 1,
              group: Group(
                addresses: [200],
                positions: [
                  List.unmodifiable([1]),
                  List.unmodifiable([2]),
                ],
              ),
            ),

            //
            Turnout(
              address: 201,
              name: 'Crossing gate',
              type: 768 + 1,
              position: 1,
              group: Group(
                addresses: [201],
                positions: [
                  List.unmodifiable([1]),
                  List.unmodifiable([2]),
                ],
              ),
            ),

            //
            Turnout(
              address: 202,
              name: 'Relay',
              type: 768 + 2,
              position: 1,
              group: Group(
                addresses: [202],
                positions: [
                  List.unmodifiable([1]),
                  List.unmodifiable([2]),
                ],
              ),
            ),
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
      ..remove(state.firstWhereOrNull((t) => t.address == address))
      ..add(turnout);
  }

  /// \todo document
  void deleteTurnouts() {
    state = SplayTreeSet<Turnout>();
  }

  /// \todo document
  void deleteTurnout(int address) {
    state = SplayTreeSet<Turnout>.from(state)
      ..remove(state.firstWhereOrNull((t) => t.address == address));
  }
}
