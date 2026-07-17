import 'package:Frontend/utils/parse_display_format.dart';
import 'package:flutter_test/flutter_test.dart';

/*
formatDecoderDb("{0}.{1:F0#}.{2}", [1, 11, 255]);
// 1.11.255

formatDecoderDb("V{0:X}.{1:X}", [125, 11]);
// V7D.B

formatDecoderDb("V{0:M0d110}.{0:M0d1}", [125]);
// V12.5

formatDecoderDb("{0:M0xFF00}", [0x4001]);
// 64

formatDecoderDb("{0:M0xFF00:00#}", [0x4001]);
// 064
*/

void main() {
  group('display_format', () {
    test('ESU', () {
      expect(parseDisplayFormat('{0}.{1}.{2}', [4, 14, 9207]), '4.14.9207');
    });

    test('D&H', () {
      expect(parseDisplayFormat('{0}.{1:F0#}.{2}', [3, 12, 50]), '3.12.50');
    });

    test('ESU (HEX)', () {
      expect(parseDisplayFormat('{0:X:F0000000#}', [0x020000CE]), '020000CE');
    });

    // https://forum.opendcc.de/wiki/doku.php?id=decoderdb#displayformat
    test('decoderdb', () {
      expect(parseDisplayFormat('V{0:X}.{1:X}', [125, 11]), 'V7D.B');
      expect(parseDisplayFormat('{1:F00#}', [0, 11]), '011');
      expect(parseDisplayFormat('{0:M0xFF00}', [0x4001]), '64');
      expect(parseDisplayFormat('{0:M0xFF00:00#}', [0x4001]), '064');
      expect(parseDisplayFormat('{0:X:F0000000#}', [0x40]), '00000040');
    });
  });
}
