import 'dart:convert';

import 'package:Frontend/models/info.dart';
import 'package:Frontend/services/sys_service.dart';
import 'package:http/http.dart' as http;

class HttpSysService implements SysService {
  final http.Client _client;
  final String _domain;

  HttpSysService(this._client, this._domain);

  @override
  Future<Info> fetch() async {
    final uri = Uri.http(_domain, 'sys/');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return Info.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch sys');
    }
  }

  @override
  Future<void> update(Info info) async {
    final uri = Uri.http(_domain, 'sys/');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(info.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update sys');
    }
  }
}
