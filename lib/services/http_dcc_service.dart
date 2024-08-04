import 'dart:convert';

import 'package:Frontend/models/loco.dart';
import 'package:Frontend/services/dcc_service.dart';
import 'package:http/http.dart' as http;

class HttpDccService implements DccService {
  final http.Client _client;
  final String _domain;

  HttpDccService(this._client, this._domain);

  @override
  Future<List<Loco>> fetchLocos() async {
    final uri = Uri.http(_domain, 'dcc/locos/');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final array = jsonDecode(response.body) as List<dynamic>;
      return [for (final object in array) Loco.fromJson(object)];
    } else {
      throw Exception('Failed to fetch locos');
    }
  }

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
  Future<void> updateLocos(List<Loco> locos) async {
    throw UnimplementedError();
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
  Future<void> deleteLocos() async {
    final uri = Uri.http(_domain, 'dcc/locos/');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) throw Exception('Failed to delete locos');
  }

  @override
  Future<void> deleteLoco(int address) async {
    final uri = Uri.http(_domain, 'dcc/locos/$address');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) throw Exception('Failed to delete loco');
  }
}
