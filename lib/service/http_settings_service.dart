// Copyright (C) 2025 Vincent Hamp
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:Frontend/model/config.dart';
import 'package:Frontend/service/settings_service.dart';
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
