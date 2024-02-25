// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:Frontend/models/info.dart';
import 'package:Frontend/services/sys_service.dart';

enum Mode {
  //
  Suspended,
  Blocked,

  // USB protocols
  DCC_EIN,
  DECUP_EIN,
  MDUSNDPREP,
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
  Future<Info> fetch() async {
    Future.delayed(const Duration(seconds: 1));
    return Info(
      version: '1.2.3',
      idfVersion: '5.2.dev',
      compileDate: 'May 5 23',
      heap: Random().nextInt(16384),
      internalHeap: Random().nextInt(16384),
      mode: mode.toString().split('.')[1],
      ip: '127.0.0.1',
      mac: '80:80:80:80:80:80',
      current: Random().nextInt(3500),
      voltage: Random().nextInt(28000),
      temperature: Random().nextDouble() * 80.0,
    );
  }

  @override
  Future<void> update(Info info) async {
    switch (info.mode) {
      case 'Suspended':
        mode = Mode.Blocked;
        Future.delayed(const Duration(seconds: 1), () {
          mode = Mode.Suspended;
        });
        break;
      case 'DCCOperations':
        mode = Mode.DCCOperations;
        break;
      case 'DCCService':
        mode = Mode.DCCService;
        break;
    }
  }
}
