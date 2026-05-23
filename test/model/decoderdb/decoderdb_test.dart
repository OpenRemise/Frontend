import 'dart:convert';
import 'dart:io';

import 'package:Frontend/model/decoderdb/decoder_definition.dart';
import 'package:Frontend/model/decoderdb/decoder_detection.dart';
import 'package:Frontend/model/decoderdb/firmware_definition.dart';
import 'package:Frontend/model/decoderdb/manufacturers_list.dart';
import 'package:Frontend/model/decoderdb/repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecoderDB', () {
    test('parse repository.json', () {
      final file = File('lib/model/decoderdb/repository.json');
      final json = jsonDecode(file.readAsStringSync());
      final repo = Repository.fromJson(json);
      expect(repo.version, isPositive);
      expect(repo.decoders, isNotEmpty);
      expect(repo.firmwares, isNotEmpty);
      expect(repo.images, isNotEmpty);
      expect(repo.manuals, isNotEmpty);
    });

    test('parse Manufacturers.json', () {
      final file = File('lib/model/decoderdb/Manufacturers.json');
      final json = jsonDecode(file.readAsStringSync());
      final mfg = ManufacturersListFile.fromJson(json);
      expect(
        mfg.manufacturersList.manufacturers.manufacturer,
        isNotEmpty,
      );
    });

    test('parse DecoderDetection.json', () {
      final file = File('lib/model/decoderdb/DecoderDetection.json');
      final json = jsonDecode(file.readAsStringSync());
      final dd = DecoderDetectionFile.fromJson(json);
      expect(dd.decoderDetection.protocols, isNotEmpty);
    });

    test('parse all decoder files', () {
      final dir = Directory('lib/model/decoderdb/decoder');
      var count = 0;
      for (final f in dir.listSync().whereType<File>()) {
        if (!f.uri.pathSegments.last.contains('_Decoder_')) continue;
        final json = jsonDecode(f.readAsStringSync());
        final dec = DecoderDefinitionFile.fromJson(json);
        expect(dec.decoderDefinition.decoder.name, isNotEmpty);
        count++;
      }
      expect(count, isPositive);
    });

    test('parse all firmware files', () {
      final dir = Directory('lib/model/decoderdb/firmware');
      var count = 0;
      for (final f in dir.listSync().whereType<File>()) {
        if (!f.uri.pathSegments.last.contains('_Firmware_')) continue;
        final json = jsonDecode(f.readAsStringSync());
        final fw = FirmwareDefinitionFile.fromJson(json);
        expect(fw.decoderFirmwareDefinition.firmware.version, isNotEmpty);
        count++;
      }
      expect(count, isPositive);
    });
  });
}
