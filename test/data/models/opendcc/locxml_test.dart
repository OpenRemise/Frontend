import 'dart:io';

import 'package:Frontend/data/models/opendcc/locxml.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Locxml', () {
    test('locosFromLocxml', () {
      final file =
          File('test/data/models/opendcc/datensatz.Locxml').readAsStringSync();
      final locos = locosFromLocxml(file);
      expect(locos.length, 5);
      expect(locos.first.address, 3);
      expect(locos.first.name, 'Vectr');
      expect(locos.first.mode, 0);
      expect(locos.first.speedSteps, 4);
    });
  });
}
