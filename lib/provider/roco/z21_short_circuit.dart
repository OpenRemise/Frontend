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

import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_short_circuit.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
Stream<LanXBcTrackShortCircuit> z21ShortCircuit(ref) async* {
  final z21 = ref.watch(z21ServiceProvider);
  await for (final shortCircuit in z21.stream
      .where(
        (command) =>
            switch (command) { LanXBcTrackShortCircuit() => true, _ => false },
      )
      .distinct()) {
    yield shortCircuit;
  }
}
