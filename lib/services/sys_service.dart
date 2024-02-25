import 'package:Frontend/models/info.dart';

abstract class SysService {
  Future<Info> fetch();
  Future<void> update(Info info);
}
