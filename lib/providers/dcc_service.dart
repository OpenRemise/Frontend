import 'package:Frontend/constants/fake_provider_container.dart';
import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/http_client.dart';
import 'package:Frontend/services/dcc_service.dart';
import 'package:Frontend/services/fake_dcc_service.dart';
import 'package:Frontend/services/http_dcc_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dcc_service.g.dart';

@Riverpod(keepAlive: true)
DccService dccService(ref) => const String.fromEnvironment('FAKE_SERVICES') ==
        'true'
    ? FakeDccService(fakeProviderContainer)
    : HttpDccService(ref.read(httpClientProvider), ref.read(domainProvider));
