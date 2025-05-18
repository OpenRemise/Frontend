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

import 'package:Frontend/models/config.dart';
import 'package:Frontend/providers/settings_service.dart';
import 'package:Frontend/services/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  late final SettingsService _service;

  @override
  FutureOr<Config> build() async {
    _service = ref.read(settingsServiceProvider);
    return _service.fetch(); // TODO this can potentially still fail
  }

  Future<void> fetchSettings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => _service.fetch());
  }

  Future<void> updateSettings(Config config) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.update(config);
      return _service.fetch();
    });
  }

  Future<void> refresh() async => fetchSettings();
}
