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

import 'package:Frontend/providers/http_client.dart';
import 'package:Frontend/providers/internet_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'available_firmware_version.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
Future<String> availableFirmwareVersion(ref) async {
  ref.watch(internetStatusProvider);
  final client = ref.watch(httpClientProvider);
  final uri =
      Uri.https('api.github.com', 'repos/OpenRemise/Firmware/releases/latest');
  final response = await client.get(uri);
  final data = jsonDecode(response.body);
  final String availableVersion = data['tag_name'];
  return availableVersion.replaceFirst('v', '');
}
