import 'dart:convert';

import 'package:Frontend/model/decoderdb/decoder_definition.dart';
import 'package:Frontend/model/decoderdb/decoder_detection.dart';
import 'package:Frontend/model/decoderdb/firmware_definition.dart';
import 'package:Frontend/model/decoderdb/manufacturers_list.dart';
import 'package:Frontend/model/decoderdb/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('DecoderDB', () {
    test('parse repository.json', () async {
      final response =
          await http.get(Uri.parse('https://decoderdb.de/?listAllJson'));
      final json = jsonDecode(response.body);
      final repo = Repository.fromJson(json);
      expect(repo.version, isPositive);
      expect(repo.decoders, isNotEmpty);
      expect(repo.firmwares, isNotEmpty);
      expect(repo.images, isNotEmpty);
      expect(repo.manuals, isNotEmpty);
    });

    test('parse Manufacturers.json', () async {
      final response = await http.get(
        Uri.parse(
          'https://www.decoderdb.de/?manufacturersFile=Manufacturers.json',
        ),
      );
      final json = jsonDecode(response.body);
      final mfg = ManufacturersListFile.fromJson(json);
      expect(
        mfg.manufacturersList.manufacturers.manufacturer,
        isNotEmpty,
      );
    });

    test('parse DecoderDetection.json', () async {
      final response = await http.get(
        Uri.parse(
          'https://www.decoderdb.de/?decoderdetectionFile=DecoderDetection.json',
        ),
      );
      final json = jsonDecode(response.body);
      final dd = DecoderDetectionFile.fromJson(json);
      expect(dd.decoderDetection.protocols, isNotEmpty);
    });

    test(
      'parse all decoder files',
      () async {
        final response =
            await http.get(Uri.parse('https://decoderdb.de/?listAllJson'));
        final json = jsonDecode(response.body);
        final repo = Repository.fromJson(json);
        for (final decoder in repo.decoders) {
          final response = await http.get(Uri.parse(decoder.link));
          final json = jsonDecode(response.body);
          final dec = DecoderDefinitionFile.fromJson(json);
          expect(dec.decoderDefinition.decoder.name, isNotEmpty);
        }
      },
      timeout: Timeout(const Duration(minutes: 5)),
    );

    test(
      'parse all firmware files',
      () async {
        final response =
            await http.get(Uri.parse('https://decoderdb.de/?listAllJson'));
        final json = jsonDecode(response.body);
        final repo = Repository.fromJson(json);
        for (final firmware in repo.firmwares) {
          final response = await http.get(Uri.parse(firmware.link));
          final json = jsonDecode(response.body);
          final fw = FirmwareDefinitionFile.fromJson(json);
          expect(fw.decoderFirmwareDefinition.firmware.version, isNotEmpty);
        }
      },
      timeout: Timeout(const Duration(minutes: 5)),
    );
  });
}
