import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/dcc_service.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/services/dcc_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dcc.g.dart';

@Riverpod(keepAlive: true)
class Dcc extends _$Dcc {
  late final DccService _service;

  @override
  FutureOr<void> build() async {
    _service = ref.read(dccServiceProvider);
    await fetchLocos();
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
}
