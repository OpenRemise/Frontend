import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Frontend/models/loco.dart';
import 'package:Frontend/services/dcc_service.dart';

class FakeDccService implements DccService {
  final Map<String, int?> _cvs = {};
  File? _file;
  List<Loco> _locos = [
    Loco(address: 42, name: 'BR 85'),
    Loco(address: 3, name: 'Vectron'),
    Loco(address: 100, name: 'BR 247'),
    Loco(address: 1337, name: 'Reihe 498'),
    Loco(address: 14, name: 'BR 248'),
    Loco(address: 130, name: 'Mh6'),
    Loco(address: 98, name: 'L45H'),
    Loco(address: 6, name: 'E2'),
    Loco(address: 75, name: 'Litra F'),
    Loco(address: 1400, name: 'Reihe 5022'),
    Loco(address: 10, name: 'V 36'),
    Loco(address: 167, name: 'BR E 77'),
    Loco(address: 2811, name: 'ASF EL 16'),
    Loco(address: 208, name: 'Gruppo 740'),
    Loco(address: 2, name: 'ET22'),
    Loco(address: 49, name: 'ST44'),
    Loco(address: 330, name: 'Rad 710'),
    Loco(address: 726, name: 'Gem 4/4'),
  ];

  FakeDccService([String? path]) {
    if (path == null) {
      return;
    }

    _file = File(path);
    if (!_file!.existsSync()) {
      _file!.createSync();
      _writeFile([]);
    }
  }

  Future<void> _delay({Duration d = const Duration(seconds: 1)}) async {
    await Future.delayed(d);
  }

  List<Loco> _readFile() {
    if (_file == null) {
      return List.of(_locos);
    } else {
      final array = jsonDecode(_file!.readAsStringSync()) as List<dynamic>;
      return [for (final object in array) Loco.fromJson(object)];
    }
  }

  void _writeFile(List<Loco> locos) {
    if (_file == null) {
      _locos = locos;
    } else {
      _file!.writeAsStringSync(jsonEncode(locos));
    }
  }

  @override
  Future<List<Loco>> fetchLocos() async {
    await _delay();
    return _readFile();
  }

  @override
  Future<Loco> fetchLoco(int address) async {
    await _delay();
    return _readFile().firstWhere(
      (loco) => loco.address == address,
      orElse: () => throw Exception('Failed to fetch loco'),
    );
  }

  @override
  Future<void> updateLocos(List<Loco> locos) async {
    await _delay();
    _writeFile(locos);
  }

  @override
  Future<void> updateLoco(int address, Loco loco) async {
    await _delay();
    final locos = _readFile();
    final index = locos.indexWhere((loco) => loco.address == address);
    if (index >= 0) {
      locos[index] = loco;
    } else {
      locos.add(loco);
    }
    _writeFile(locos);
  }

  @override
  Future<void> deleteLocos() async {
    await _delay();
    _writeFile([]);
  }

  @override
  Future<void> deleteLoco(int address) async {
    await _delay();
    final locos = _readFile();
    final index = locos.indexWhere((loco) => loco.address == address);
    if (index >= 0) locos.removeAt(index);
    _writeFile(locos);
  }

  @override
  Future<Map<String, int?>> fetchCVs() async {
    return _cvs;
  }

  @override
  Future<void> updateCVs(Map<String, int?> cvs) async {
    cvs.forEach((number, value) async {
      await Future.delayed(const Duration(seconds: 1));
      _cvs[number] = value ?? Random().nextInt(255);
    });
  }
}
