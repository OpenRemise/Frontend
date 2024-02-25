import 'package:Frontend/models/sound_database.dart';
import 'package:Frontend/providers/http_client.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sound_database.g.dart';

@Riverpod(keepAlive: true)
Future<SoundDatabase> soundDatabase(ref, Locale locale) async {
  final http.Client client = ref.watch(httpClientProvider);
  final uri = Uri.http(
    'www.zimo.at',
    locale.languageCode == 'de'
        ? '/web2010/sound/tableindex.htm'
        : '/web2010/sound/tableindex_EN.htm',
  );
  final response = await client.get(uri);
  final document = parse(response.body);
  SoundDatabaseVisitor vis = SoundDatabaseVisitor()..visit(document);
  return vis.soundDatabase;
}
