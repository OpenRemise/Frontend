import 'package:Frontend/models/config.dart';
import 'package:Frontend/services/settings_service.dart';

class FakeSettingsService implements SettingsService {
  Config _config = Config(
    mdns: 'remise',
    ssid: 'Klettermaxl',
    password: '********',
    httpReceiveTimeout: 5,
    httpTransmitTimeout: 5,
    usbReceiveTimeout: 1,
    currentLimit: 3,
    currentShortCircuitTime: 20,
    dccPreamble: 21,
    dccBit1Duration: 58,
    dccBit0Duration: 100,
    dccBiDiBitDuration: 60,
    dccProgrammingType: 3,
    dccStartupResetPacketCount: 25,
    dccContinueResetPacketCount: 6,
    dccProgramPacketCount: 7,
    dccBitVerifyTo1: true,
    dccProgrammingAckCurrent: 50,
    dccFlags: 2,
    mduPreamble: 14,
    mduAckreq: 10,
  );

  @override
  Future<Config> fetch() {
    return Future.delayed(const Duration(milliseconds: 500), () => _config);
  }

  @override
  Future<void> update(Config config) {
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => _config = Config(
        mdns: config.mdns ?? _config.mdns,
        ssid: config.ssid ?? _config.ssid,
        password: config.password ?? _config.password,
        httpReceiveTimeout:
            config.httpReceiveTimeout ?? _config.httpReceiveTimeout,
        httpTransmitTimeout:
            config.httpTransmitTimeout ?? _config.httpTransmitTimeout,
        usbReceiveTimeout:
            config.usbReceiveTimeout ?? _config.usbReceiveTimeout,
        currentLimit: config.currentLimit ?? _config.currentLimit,
        currentShortCircuitTime:
            config.currentShortCircuitTime ?? _config.currentShortCircuitTime,
        dccPreamble: config.dccPreamble ?? _config.dccPreamble,
        dccBit1Duration: config.dccBit1Duration ?? _config.dccBit1Duration,
        dccBit0Duration: config.dccBit0Duration ?? _config.dccBit0Duration,
        dccBiDiBitDuration:
            config.dccBiDiBitDuration ?? _config.dccBiDiBitDuration,
        dccProgrammingType:
            config.dccProgrammingType ?? _config.dccProgrammingType,
        dccStartupResetPacketCount: config.dccStartupResetPacketCount ??
            _config.dccStartupResetPacketCount,
        dccContinueResetPacketCount: config.dccContinueResetPacketCount ??
            _config.dccContinueResetPacketCount,
        dccProgramPacketCount:
            config.dccProgramPacketCount ?? _config.dccProgramPacketCount,
        dccBitVerifyTo1: config.dccBitVerifyTo1 ?? _config.dccBitVerifyTo1,
        dccProgrammingAckCurrent:
            config.dccProgrammingAckCurrent ?? _config.dccProgrammingAckCurrent,
        dccFlags: config.dccFlags ?? _config.dccFlags,
        mduPreamble: config.mduPreamble ?? _config.mduPreamble,
        mduAckreq: config.mduAckreq ?? _config.mduAckreq,
      ),
    );
  }
}
