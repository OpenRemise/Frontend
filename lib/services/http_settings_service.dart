import 'dart:convert';

import 'package:Frontend/models/setting.dart';
import 'package:Frontend/services/settings_service.dart';
import 'package:http/http.dart' as http;

class HttpSettingsService implements SettingsService {
  final http.Client _client;
  final String _domain;

  http.Client get client => _client;
  String get domain => _domain;

  HttpSettingsService(this._client, this._domain);

  @override
  Future<Setting> fetch() async {
    final uri = Uri.http(_domain, 'settings/');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return Setting.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch settings');
    }
  }

  @override
  Future<void> update(Setting setting) async {
    final uri = Uri.http(_domain, 'settings/');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(setting.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update settings');
    }
  }
}
