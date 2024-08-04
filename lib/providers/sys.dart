import 'package:Frontend/models/info.dart';
import 'package:Frontend/providers/sys_service.dart';
import 'package:Frontend/services/sys_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sys.g.dart';

@Riverpod(keepAlive: true)
class Sys extends _$Sys {
  late final SysService _service;

  @override
  FutureOr<Info> build() async {
    _service = ref.read(sysServiceProvider);
    return _service.fetch(); // TODO this can potentially still fail
  }

  Future<void> fetchInfo() async {
    state = await AsyncValue.guard(() async => _service.fetch());
  }
}
