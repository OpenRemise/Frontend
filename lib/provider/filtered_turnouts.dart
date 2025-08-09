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
import 'package:Frontend/provider/decoder_filter.dart';
import 'package:Frontend/provider/turnouts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filtered_turnouts.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
SplayTreeSet<Turnout> filteredTurnouts(ref) {
  final turnouts = ref.watch(turnoutsProvider);
  try {
    final exp = RegExp(ref.watch(decoderFilterProvider));
    return SplayTreeSet<Turnout>.of(
      turnouts.where(
        (turnout) =>
            exp.hasMatch(turnout.name) ||
            exp.hasMatch(turnout.address.toString()),
      ),
    );
  } on FormatException {
    return turnouts;
  }
}
