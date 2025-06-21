// Copyright (C) 2025 Vincent Hamp
// Copyright (C) 2025 Franziska Walter
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

import 'dart:async';

import 'package:Frontend/constant/default_settings.dart';
import 'package:Frontend/model/connection_status.dart';
import 'package:Frontend/provider/settings.dart';
import 'package:Frontend/provider/z21_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_status.g.dart';

@Riverpod(keepAlive: true)
Stream<ConnectionStatus> connectionStatus(ref) async* {
  final timeout = ref.watch(
    settingsProvider.select(
      (config) =>
          config.value?.httpReceiveTimeout ??
          DefaultSettings.values()['http_rx_timeout'].toInt(),
    ),
  );

  ConnectionStatus? previousStatus;

  while (true) {
    final z21 = ref.read(z21ServiceProvider);

    try {
      await for (final _ in z21.stream.timeout(Duration(seconds: timeout))) {
        if (previousStatus != ConnectionStatus.connected) {
          previousStatus = ConnectionStatus.connected;
          debugPrint("conn");
          yield previousStatus;
        }
      }
    } catch (_) {
      if (previousStatus != ConnectionStatus.disconnected) {
        previousStatus = ConnectionStatus.disconnected;
        debugPrint("disc");
        yield previousStatus;
      }
    }
  }
}
