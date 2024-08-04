import 'dart:typed_data';

import 'package:Frontend/utilities/exor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('exor', () {
    final List<int> data = [
      0x09,
      0x00,
      0x40,
      0x00,
      0xE3,
      0xF0,
      (1337 >> 8) & 0xFF,
      (1337 >> 0) & 0xFF,
    ];

    test('List<int>', () {
      expect(data.length, 8);
      expect(exor(data), 0x66);
    });

    test('Uint8List', () {
      expect(data.length, 8);
      expect(exor(Uint8List.fromList(data)), 0x66);
    });
  });
}
