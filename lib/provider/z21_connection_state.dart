// Copyright (C) 2025 Vincent Hamp
// Created by Franziska Walter
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
import 'package:Frontend/provider/z21_service.dart';
import 'package:Frontend/provider/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_connection_state.g.dart';

@Riverpod(keepAlive: true)
Stream<bool> z21ConnectionState(Z21ConnectionStateRef ref) async* {
  final z21 = ref.watch(z21ServiceProvider);

  while (true) {
    try {
      z21.lanXGetStatus();

      final z21Timeout = ref.watch(
        settingsProvider.select((config) => config.value?.connTimeout ?? 2),
      );

      await z21.stream
          .timeout(Duration(seconds: z21Timeout))
          .firstWhere((_) => true);

      yield true;
    } catch (_) {
      yield false;
    }

    await Future.delayed(const Duration(seconds: 1));
  }
}
