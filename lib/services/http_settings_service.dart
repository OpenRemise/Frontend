import 'dart:convert';

import 'package:Frontend/models/config.dart';
import 'package:Frontend/services/settings_service.dart';
import 'package:http/http.dart' as http;

class HttpSettingsService implements SettingsService {
  final http.Client _client;
  final String _domain;

  HttpSettingsService(this._client, this._domain);

  @override
  Future<Config> fetch() async {
    final uri = Uri.http(_domain, 'settings/');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return Config.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch settings');
    }
  }

  @override
  Future<void> update(Config config) async {
    final uri = Uri.http(_domain, 'settings/');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(config.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update settings');
    }
  }
}
