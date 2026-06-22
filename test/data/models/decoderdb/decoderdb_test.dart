import 'dart:convert';
import 'dart:math';

import 'package:Frontend/data/models/decoderdb/decoder_definition.dart';
import 'package:Frontend/data/models/decoderdb/decoder_detection.dart';
import 'package:Frontend/data/models/decoderdb/firmware_definition.dart';
import 'package:Frontend/data/models/decoderdb/manufacturers_list.dart';
import 'package:Frontend/data/models/decoderdb/repository.dart';
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
      'parse random decoder file',
      () async {
        var response =
            await http.get(Uri.parse('https://decoderdb.de/?listAllJson'));
        var json = jsonDecode(response.body);
        final repo = Repository.fromJson(json);
        final decoder = repo.decoders[Random().nextInt(repo.decoders.length)];
        response = await http.get(Uri.parse(decoder.link));
        json = jsonDecode(response.body);
        final dec = DecoderDefinitionFile.fromJson(json);
        expect(dec.decoderDefinition.decoder.name, isNotEmpty);
      },
      timeout: Timeout(const Duration(minutes: 5)),
    );

    test(
      'parse random firmware file',
      () async {
        var response =
            await http.get(Uri.parse('https://decoderdb.de/?listAllJson'));
        var json = jsonDecode(response.body);
        final repo = Repository.fromJson(json);
        final firmware =
            repo.firmwares[Random().nextInt(repo.firmwares.length)];
        response = await http.get(Uri.parse(firmware.link));
        json = jsonDecode(response.body);
        final fw = FirmwareDefinitionFile.fromJson(json);
        expect(fw.decoderFirmwareDefinition.firmware.version, isNotEmpty);
      },
      timeout: Timeout(const Duration(minutes: 5)),
    );
  });
}
