import 'package:Frontend/models/config.dart';

abstract interface class SettingsService {
  Future<Config> fetch();
  Future<void> update(Config setting);
}
