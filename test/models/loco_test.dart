import 'dart:convert';
import 'dart:io';

import 'package:Frontend/models/loco.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Loco', () {
    test('contains address and name', () {
      final file = File('data/address_name.json').readAsStringSync();
      final loco = Loco.fromJson(jsonDecode(file) as Map<String, dynamic>);
      expect(loco.address, 42);
      expect(loco.name, 'Loco42');
    });

    test('address is mandatory', () {
      final file = File('data/no_address.json').readAsStringSync();
      expect(
        () => Loco.fromJson(jsonDecode(file) as Map<String, dynamic>),
        throwsA(isA<TypeError>()),
      );
    });

    test('contains address, name and unknown parameter', () {
      final file = File('data/unknown_parameter.json').readAsStringSync();
      final loco = Loco.fromJson(jsonDecode(file) as Map<String, dynamic>);
      expect(loco.address, 42);
      expect(loco.name, 'Loco42');
    });
  });
}
