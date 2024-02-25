import 'package:Frontend/models/loco.dart';

abstract class DccService {
  Future<List<Loco>> fetchLocos();
  Future<Loco> fetchLoco(int address);
  Future<void> updateLocos(List<Loco> locos);
  Future<void> updateLoco(int address, Loco loco);
  Future<void> deleteLocos();
  Future<void> deleteLoco(int address);

  Future<Map<String, int?>> fetchCVs();
  Future<void> updateCVs(Map<String, int?> cvs);
}
