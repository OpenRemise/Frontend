// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:Frontend/models/info.dart';
import 'package:Frontend/services/sys_service.dart';

enum Mode {
  //
  Suspended,
  Shutdown,

  // USB protocols
  DCC_EIN,
  DECUP_EIN,
  MDU_EIN,
  SUSIV2,

  //
  DCCOperations,
  DCCService,

  //
  ZUSI,

  //
  MDUFirmware,
  MDUZpp,

  //
  OTA
}

Mode mode = Mode.Suspended;

class FakeSysService implements SysService {
  @override
  Future<Info> fetch() {
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => Info(
        mode: mode.toString().split('.')[1],
        version: '1.2.3',
        projectName: 'Frontend',
        compileTime: '18:31:28',
        compileDate: 'Jul 28 2024',
        idfVersion: '5.2.dev',
        mdns: 'wulf.local',
        ip: '127.0.0.1',
        mac: '80:80:80:80:80:80',
        heap: Random().nextInt(16384),
        internalHeap: Random().nextInt(16384),
        current: Random().nextInt(3500),
        voltage: Random().nextInt(28000),
        temperature: Random().nextDouble() * 80.0,
      ),
    );
  }
}
