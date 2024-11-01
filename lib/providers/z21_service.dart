import 'package:Frontend/constants/fake_provider_container.dart';
import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/services/fake_z21_service.dart';
import 'package:Frontend/services/ws_z21_service.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_service.g.dart';

@Riverpod(keepAlive: true)
Z21Service z21Service(ref) =>
    const String.fromEnvironment('FAKE_SERVICES') == 'true'
        ? FakeZ21Service(fakeProviderContainer)
        : WsZ21Service(ref.read(domainProvider));
