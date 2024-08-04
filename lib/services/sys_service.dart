import 'package:Frontend/models/info.dart';

abstract interface class SysService {
  Future<Info> fetch();
}
