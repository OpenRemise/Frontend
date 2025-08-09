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

import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/dcc_service.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/provider/turnouts.dart';
import 'package:Frontend/service/dcc_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dcc.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
class Dcc extends _$Dcc {
  late final DccService _service;

  @override
  FutureOr<void> build() async {
    _service = ref.read(dccServiceProvider);
    await fetchLocos();
    await fetchTurnouts();
  }

  Future<void> fetchLocos() async {
    // GET /locos/
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final locos = await _service.fetchLocos();
      ref.read(locosProvider.notifier).updateLocos(locos);
    });
  }

  Future<void> fetchLoco(int address) async {
    // GET /locos/$address
    state = await AsyncValue.guard(() async {
      final loco = await _service.fetchLoco(address);
      ref.read(locosProvider.notifier).updateLoco(address, loco);
    });
  }

  Future<void> updateLoco(int address, Loco loco) async {
    // PUT /locos/$address
    state = await AsyncValue.guard(() async {
      await _service.updateLoco(address, loco);
      ref.read(locosProvider.notifier).updateLoco(address, loco);
    });
  }

  Future<void> deleteLocos() async {
    // DELETE /locos/
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteLocos();
      ref.read(locosProvider.notifier).deleteLocos();
    });
  }

  Future<void> deleteLoco(int address) async {
    // DELETE /locos/$address
    state = await AsyncValue.guard(() async {
      await _service.deleteLoco(address);
      ref.read(locosProvider.notifier).deleteLoco(address);
    });
  }

  Future<void> fetchTurnout(int address) async {
    // GET /turnouts/$address
    state = await AsyncValue.guard(() async {
      final turnout = await _service.fetchTurnout(address);
      ref.read(turnoutsProvider.notifier).updateTurnout(address, turnout);
    });
  }

  Future<void> fetchTurnouts() async {
    // GET /turnouts/
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final turnouts = await _service.fetchTurnouts();
      ref.read(turnoutsProvider.notifier).updateTurnouts(turnouts);
    });
  }

  Future<void> updateTurnout(int address, Turnout turnout) async {
    // PUT /turnouts/$address
    state = await AsyncValue.guard(() async {
      await _service.updateTurnout(address, turnout);
      ref.read(turnoutsProvider.notifier).updateTurnout(address, turnout);
    });
  }

  Future<void> deleteTurnout(int address) async {
    // DELETE /turnouts/$address
    state = await AsyncValue.guard(() async {
      await _service.deleteTurnout(address);
      ref.read(turnoutsProvider.notifier).deleteTurnout(address);
    });
  }

  Future<void> deleteTurnouts() async {
    // DELETE /turnouts/
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteTurnouts();
      ref.read(turnoutsProvider.notifier).deleteTurnouts();
    });
  }

  Future<void> refresh() async {
    fetchLocos();
    fetchTurnouts();
  }
}
