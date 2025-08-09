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

import 'dart:collection';
import 'dart:convert';

import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/service/dcc_service.dart';
import 'package:http/http.dart' as http;

class HttpDccService implements DccService {
  final http.Client _client;
  final String _domain;

  HttpDccService(this._client, this._domain);

  @override
  Future<Loco> fetchLoco(int address) async {
    final uri = Uri.http(_domain, 'dcc/locos/$address');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return Loco.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch loco');
    }
  }

  @override
  Future<SplayTreeSet<Loco>> fetchLocos() async {
    final uri = Uri.http(_domain, 'dcc/locos/');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final array = jsonDecode(response.body) as List<dynamic>;
      return SplayTreeSet.of(
        [for (final object in array) Loco.fromJson(object)],
      );
    } else {
      throw Exception('Failed to fetch locos');
    }
  }

  @override
  Future<void> updateLoco(int address, Loco loco) async {
    final uri = Uri.http(_domain, 'dcc/locos/$address');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loco.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Failed to update loco');
  }

  @override
  Future<void> updateLocos(SplayTreeSet<Loco> locos) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteLoco(int address) async {
    final uri = Uri.http(_domain, 'dcc/locos/$address');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) throw Exception('Failed to delete loco');
  }

  @override
  Future<void> deleteLocos() async {
    final uri = Uri.http(_domain, 'dcc/locos/');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) throw Exception('Failed to delete locos');
  }

  @override
  Future<Turnout> fetchTurnout(int address) async {
    final uri = Uri.http(_domain, 'dcc/turnouts/$address');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return Turnout.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch turnout');
    }
  }

  @override
  Future<SplayTreeSet<Turnout>> fetchTurnouts() async {
    final uri = Uri.http(_domain, 'dcc/turnouts/');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final array = jsonDecode(response.body) as List<dynamic>;
      return SplayTreeSet.of(
        [for (final object in array) Turnout.fromJson(object)],
      );
    } else {
      throw Exception('Failed to fetch turnouts');
    }
  }

  @override
  Future<void> updateTurnout(int address, Turnout turnout) async {
    final uri = Uri.http(_domain, 'dcc/turnouts/$address');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(turnout.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Failed to update turnout');
  }

  @override
  Future<void> updateTurnouts(SplayTreeSet<Turnout> turnouts) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTurnout(int address) async {
    final uri = Uri.http(_domain, 'dcc/turnouts/$address');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) throw Exception('Failed to delete turnout');
  }

  @override
  Future<void> deleteTurnouts() async {
    final uri = Uri.http(_domain, 'dcc/turnouts/');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete turnouts');
    }
  }
}
