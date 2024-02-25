import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/services/fake_zusi_service.dart';
import 'package:Frontend/services/ws_zusi_service.dart';
import 'package:Frontend/services/zusi_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'zusi_service.g.dart';

@riverpod
ZusiService zusiService(ref) =>
    const String.fromEnvironment('FAKE_SERVICES') == 'true'
        ? FakeZusiService()
        : WsZusiService(ref.read(domainProvider));
