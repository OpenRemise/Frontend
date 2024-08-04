import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/services/dcc_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeDccService implements DccService {
  final ProviderContainer ref;

  FakeDccService(this.ref);

  List<Loco> _readFile() {
    return ref.read(locosProvider);
  }

  void _writeFile(List<Loco> locos) {
    ref.read(locosProvider.notifier).updateLocos(locos);
  }

  @override
  Future<List<Loco>> fetchLocos() {
    return Future.delayed(const Duration(seconds: 1), () => _readFile());
  }

  @override
  Future<Loco> fetchLoco(int address) {
    return Future.delayed(
      const Duration(seconds: 1),
      () => _readFile().firstWhere(
        (loco) => loco.address == address,
        orElse: () => throw Exception('Failed to fetch loco'),
      ),
    );
  }

  @override
  Future<void> updateLocos(List<Loco> locos) {
    return Future.delayed(const Duration(seconds: 1), () => _writeFile(locos));
  }

  @override
  Future<void> updateLoco(int address, Loco loco) {
    return Future.delayed(const Duration(seconds: 1), () {
      final locos = _readFile();
      final index = locos.indexWhere((loco) => loco.address == address);
      if (index >= 0) {
        locos[index] = loco;
      } else {
        locos.add(loco);
      }
      _writeFile(locos);
    });
  }

  @override
  Future<void> deleteLocos() {
    return Future.delayed(const Duration(seconds: 1), () => _writeFile([]));
  }

  @override
  Future<void> deleteLoco(int address) {
    return Future.delayed(const Duration(seconds: 1), () {
      final locos = _readFile();
      final index = locos.indexWhere((loco) => loco.address == address);
      if (index >= 0) locos.removeAt(index);
      _writeFile(locos);
    });
  }
}
