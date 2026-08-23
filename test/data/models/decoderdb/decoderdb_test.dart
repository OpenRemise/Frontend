import 'dart:convert';

import 'package:Frontend/data/models/decoderdb/repository.dart';
import 'package:Frontend/data/models/decoderdb/utility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('parse repository.json', () async {
    final response = await http
        .get(Uri.parse('https://decoderdb.bidib.org/repository.json'));
    final json = jsonDecode(response.body);
    final repo = Repository.fromJson(json);
    expect(repo.version, isPositive);
    expect(repo.decoders, isNotEmpty);
    expect(repo.firmwares, isNotEmpty);
    expect(repo.images, isNotEmpty);
  });

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
