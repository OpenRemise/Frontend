import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/services/fake_ota_service.dart';
import 'package:Frontend/services/ota_service.dart';
import 'package:Frontend/services/ws_ota_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ota_service.g.dart';

@riverpod
OtaService otaService(ref) =>
    const String.fromEnvironment('FAKE_SERVICES') == 'true'
        ? FakeOtaService()
        : WsOtaService(ref.read(domainProvider));
