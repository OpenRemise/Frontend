import 'package:Frontend/models/loco.dart';

abstract interface class DccService {
  Future<List<Loco>> fetchLocos();
  Future<Loco> fetchLoco(int address);
  Future<void> updateLocos(List<Loco> locos);
  Future<void> updateLoco(int address, Loco loco);
  Future<void> deleteLocos();
  Future<void> deleteLoco(int address);
}
