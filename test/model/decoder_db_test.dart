import 'dart:convert';

import 'package:Frontend/model/bidib/decoder_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('decoder_db', () {
    test('repository.json', () async {
      final response = await http.get(
        Uri.parse('https://decoderdb.bidib.org/repository.json'),
      );
      final repository =
          DecoderDbRepository.fromJson(jsonDecode(response.body));
      expect(repository.version, 7);
      expect(
        repository.manufacturers!.link,
        'https://decoderdb.bidib.org/Manufacturers.json',
      );
      expect(
        repository.decoderDetections!.link,
        'https://decoderdb.bidib.org/DecoderDetection.json',
      );
    });

    test('Manufacturers.json', () async {
      final response = await http.get(
        Uri.parse('https://decoderdb.bidib.org/Manufacturers.json'),
      );
      final manufacturers =
          DecoderDbManufacturers.fromJson(jsonDecode(response.body));
      expect(manufacturers.version!.createdBy, 'DecoderDB');
    });

    test('DecoderDetection.json', () async {
      final response = await http.get(
        Uri.parse('https://decoderdb.bidib.org/DecoderDetection.json'),
      );
      final decoderDetection =
          DecoderDbDecoderDetection.fromJson(jsonDecode(response.body));
      expect(decoderDetection.version!.createdBy, 'DecoderDB');
      expect(decoderDetection.protocols!.length, 3);
    });
  });
}
