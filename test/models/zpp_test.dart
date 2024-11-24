import 'dart:io';

import 'package:Frontend/models/zpp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('zpp', () {
    test('free', () {
      final Uint8List file =
          File('data/Da_Di_Collection_ZIMO-mfx-16Bit_S02.zpp')
              .readAsBytesSync();
      final zpp = Zpp(file);
      expect(zpp.id.length, 2);
      expect(zpp.id, 'SP');
      expect(zpp.version, 2);
      expect(zpp.flash.length, 16261376);
      expect(zpp.cvs.containsKey(1), true);
      expect(zpp.cvs[0], 3);
      expect(zpp.coded, false);
    });

    test('coded', () {
      final Uint8List file =
          File('data/Taurus_LeoSoundLab_Roco_8-Pol_MX_crypt.zpp')
              .readAsBytesSync();
      final zpp = Zpp(file);
      expect(zpp.id.length, 2);
      expect(zpp.id, 'SP');
      expect(zpp.version, 1);
      expect(zpp.coded, true);
    });
  });
}
