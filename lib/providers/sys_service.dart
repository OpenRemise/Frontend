import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/http_client.dart';
import 'package:Frontend/services/fake_sys_service.dart';
import 'package:Frontend/services/http_sys_service.dart';
import 'package:Frontend/services/sys_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sys_service.g.dart';

@Riverpod(keepAlive: true)
SysService sysService(ref) =>
    const String.fromEnvironment('FAKE_SERVICES') == 'true'
        ? FakeSysService()
        : HttpSysService(
            ref.read(httpClientProvider),
            ref.read(domainProvider),
          );
