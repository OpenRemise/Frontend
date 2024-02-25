import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/http_client.dart';
import 'package:Frontend/services/fake_settings_service.dart';
import 'package:Frontend/services/http_settings_service.dart';
import 'package:Frontend/services/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_service.g.dart';

@Riverpod(keepAlive: true)
SettingsService settingsService(ref) =>
    const String.fromEnvironment('FAKE_SERVICES') == 'true'
        ? FakeSettingsService()
        : HttpSettingsService(
            ref.read(httpClientProvider),
            ref.read(domainProvider),
          );
