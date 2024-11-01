import 'package:Frontend/models/config.dart';
import 'package:Frontend/providers/settings_service.dart';
import 'package:Frontend/services/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

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
}
