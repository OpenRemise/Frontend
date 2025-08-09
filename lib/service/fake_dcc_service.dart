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
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/provider/turnouts.dart';
import 'package:Frontend/service/dcc_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class FakeDccService implements DccService {
  final ProviderContainer ref;

  FakeDccService(this.ref);

  @override
  Future<Loco> fetchLoco(int address) {
    return Future.delayed(
      const Duration(milliseconds: 250),
      () => ref.read(locosProvider).firstWhere(
            (l) => l.address == address,
            orElse: () => throw Exception('Failed to fetch loco'),
          ),
    );
  }

  @override
  Future<SplayTreeSet<Loco>> fetchLocos() {
    return Future.delayed(
      const Duration(seconds: 1),
      () => ref.read(locosProvider),
    );
  }

  @override
  Future<void> updateLoco(int address, Loco loco) {
    return Future.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> updateLocos(SplayTreeSet<Loco> locos) {
    return Future.delayed(
      const Duration(seconds: 1),
      () => ref.read(locosProvider.notifier).updateLocos(locos),
    );
  }

  @override
  Future<void> deleteLoco(int address) {
    return Future.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> deleteLocos() {
    return Future.delayed(
      const Duration(seconds: 1),
      () => ref.read(locosProvider.notifier).updateLocos(SplayTreeSet<Loco>()),
    );
  }

  @override
  Future<Turnout> fetchTurnout(int address) {
    return Future.delayed(
      const Duration(milliseconds: 250),
      () => ref.read(turnoutsProvider).firstWhere(
            (t) => t.address == address,
            orElse: () => throw Exception('Failed to fetch turnout'),
          ),
    );
  }

  @override
  Future<SplayTreeSet<Turnout>> fetchTurnouts() {
    return Future.delayed(
      const Duration(seconds: 1),
      () => ref.read(turnoutsProvider),
    );
  }

  @override
  Future<void> updateTurnout(int address, Turnout turnout) {
    return Future.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> updateTurnouts(SplayTreeSet<Turnout> turnouts) {
    return Future.delayed(
      const Duration(seconds: 1),
      () => ref.read(turnoutsProvider.notifier).updateTurnouts(turnouts),
    );
  }

  @override
  Future<void> deleteTurnout(int address) {
    return Future.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> deleteTurnouts() {
    return Future.delayed(
      const Duration(seconds: 1),
      () => ref
          .read(turnoutsProvider.notifier)
          .updateTurnouts(SplayTreeSet<Turnout>()),
    );
  }
}
