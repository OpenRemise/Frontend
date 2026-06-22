import 'dart:io';

import 'package:Frontend/data/models/zimo/zsu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('zsu', () {
    test('MS', () {
      final Uint8List file = File('data/MS-4.235.0.zsu').readAsBytesSync();
      final zsu = Zsu(file);
      expect(zsu.firmwares.length, 44);
      final fw = zsu.firmwares.firstWhere((fw) => fw.id == 0x06043200);
      expect(
        listEquals(
          fw.iv,
          Uint8List.fromList([148, 157, 18, 87, 129, 92, 108, 100]),
        ),
        true,
      );
    });

    test('MX', () {
      final Uint8List file = File('data/DS230503.zsu').readAsBytesSync();
      final zsu = Zsu(file);
      expect(zsu.firmwares.length, 92);
      final fw = zsu.firmwares.firstWhere((fw) => fw.id == 0xDD);
      expect(fw.bootloader, null);
    });
  });
}
