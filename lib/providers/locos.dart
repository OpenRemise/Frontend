import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/dcc_service.dart';
import 'package:Frontend/services/dcc_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locos.g.dart';

@Riverpod(keepAlive: true)
class Locos extends _$Locos {
  late final DccService _service;

  @override
  FutureOr<List<Loco>> build() async {
    debugPrint('Locos build');
    _service = ref.read(dccServiceProvider);
    return _service.fetchLocos(); // TODO this can potentially still fail
  }

  Future<void> fetchLocos() async {
    // GET /locos/
    debugPrint('Locos fetchLocos');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => _service.fetchLocos());
  }

  Future<void> fetchLoco(int address) async {
    // GET /locos/$address
    debugPrint('Locos fetchLoco');
    state = await AsyncValue.guard(() async {
      final loco = await _service.fetchLoco(address);
      return [
        for (final previousLoco in state.requireValue)
          if (previousLoco.address == address) loco else previousLoco,
      ];
    });
  }

  Future<void> updateLoco(int address, Loco loco) async {
    // PUT /locos/$address
    // debugPrint('Locos updateLoco');
    // debugPrint(loco.toString());
    state = await AsyncValue.guard(() async {
      await _service.updateLoco(address, loco);
      final index = state.requireValue
          .indexWhere((previousLoco) => previousLoco.address == address);
      // Update
      if (index >= 0) {
        return [
          for (var i = 0; i < state.requireValue.length; ++i)
            if (i == index) loco else state.requireValue[i],
        ];
      }
      // Create
      else {
        return [...state.requireValue, loco];
      }
    });
  }

  Future<void> deleteLocos() async {
    // DELETE /locos/
    debugPrint('Locos deleteLocos');
    state = await AsyncValue.guard(() async {
      await _service.deleteLocos();
      return [];
    });
  }

  Future<void> deleteLoco(int address) async {
    // DELETE /locos/$address
    debugPrint('Locos deleteLoco');
    state = await AsyncValue.guard(() async {
      await _service.deleteLoco(address);
      return [
        for (final previousLoco in state.requireValue)
          if (previousLoco.address != address) previousLoco,
      ];
    });
  }
}
