import 'dart:io';

import 'package:Frontend/models/zsu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('zsu', () {
    test('MS', () {
      final Uint8List file = File('data/MS_4.235.0.zsu').readAsBytesSync();
      Zsu zsu = Zsu(file);
      expect(zsu.entries.length, 40);
      expect(zsu.entries.containsKey(0x06043200), true);
      expect(
        listEquals(
          zsu.entries[0x06043200]?.iv,
          Uint8List.fromList([148, 157, 18, 87, 129, 92, 108, 100]),
        ),
        true,
      );
    });

    test('MX', () {
      final Uint8List file = File('data/DS230503.zsu').readAsBytesSync();
      Zsu zsu = Zsu(file);
      expect(zsu.entries.length, 92);
      expect(zsu.entries.containsKey(0xDD), true);
      expect(zsu.entries[0xDD]?.bootloader, null);
    });
  });
}
