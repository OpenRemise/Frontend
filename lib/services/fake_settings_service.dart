import 'package:Frontend/models/setting.dart';
import 'package:Frontend/services/settings_service.dart';

class FakeSettingsService implements SettingsService {
  Setting _setting = Setting(
    mdns: 'wulf',
    ssid: 'Klettermaxl',
    password: '********',
    httpReceiveTimeout: 5,
    httpTransmitTimeout: 5,
    dccPreambleCount: 21,
    dccBit1Duration: 58,
    dccBit0Duration: 100,
    dccBiDiBitDuration: 60,
  );

  @override
  Future<Setting> fetch() async {
    return _setting;
  }

  @override
  Future<void> update(Setting setting) async {
    _setting = Setting(
      mdns: setting.mdns ?? _setting.mdns,
      ssid: setting.ssid ?? _setting.ssid,
      password: setting.password ?? _setting.password,
      httpReceiveTimeout:
          setting.httpReceiveTimeout ?? _setting.httpReceiveTimeout,
      httpTransmitTimeout:
          setting.httpTransmitTimeout ?? _setting.httpTransmitTimeout,
      dccPreambleCount: setting.dccPreambleCount ?? _setting.dccPreambleCount,
      dccBit1Duration: setting.dccBit1Duration ?? _setting.dccBit1Duration,
      dccBit0Duration: setting.dccBit0Duration ?? _setting.dccBit0Duration,
      dccBiDiBitDuration:
          setting.dccBiDiBitDuration ?? _setting.dccBiDiBitDuration,
    );
  }
}
