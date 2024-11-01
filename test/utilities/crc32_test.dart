import 'dart:typed_data';

import 'package:Frontend/utilities/crc32.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('crc32', () {
    final List<int> data = [
      0x48,
      0x65,
      0x6C,
      0x6C,
      0x6F,
      0x20,
      0x57,
      0x6F,
      0x72,
      0x6C,
      0x64,
    ];

    test('List<int>', () {
      expect(data.length, 11);
      expect(crc32(data), 0x29EE5C18);
    });

    test('Uint8List', () {
      expect(data.length, 11);
      expect(crc32(Uint8List.fromList(data)), 0x29EE5C18);
    });
  });
}
