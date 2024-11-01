import 'dart:typed_data';

import 'package:Frontend/utilities/crc8.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('crc8', () {
    final List<int> data = [
      0x0B,
      0x0A,
      0x00,
      0x00,
      0x8E,
      0x40,
      0x00,
      0x0D,
      0x67,
      0x00,
      0x01,
      0x00,
    ];

    test('List<int>', () {
      expect(data.length, 12);
      expect(crc8(data), 0x4C);
    });

    test('Uint8List', () {
      expect(data.length, 12);
      expect(crc8(Uint8List.fromList(data)), 0x4C);
    });
  });
}
