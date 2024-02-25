import 'dart:convert';

import 'package:Frontend/models/ms_database.dart';
import 'package:Frontend/providers/http_client.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ms_database.g.dart';

@Riverpod(keepAlive: true)
Future<MsDatabase> msDatabase(ref, Locale locale) async {
  final http.Client client = ref.watch(httpClientProvider);
  final uri =
      Uri.http('www.zimo.at', '/web2010/support/MS-MN-Decoder-SW-Update.htm');
  final response = await client.get(uri);
  final document = parse(utf8.decode(response.bodyBytes));
  MsDatabaseVisitor vis = MsDatabaseVisitor(locale.languageCode)
    ..visit(document);
  return vis.msDatabase;
}
