import 'package:Frontend/models/setting.dart';

abstract class SettingsService {
  Future<Setting> fetch();
  Future<void> update(Setting setting);
}
