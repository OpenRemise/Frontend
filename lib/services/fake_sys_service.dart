// Copyright (C) 2024 Vincent Hamp
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:Frontend/models/info.dart';
import 'package:Frontend/services/sys_service.dart';

enum State {
  // Flags (8 bits)
  Suspended,
  Suspend,
  ShortCircuit,

  // USB protocols
  DCC_EIN,
  DECUP_EIN,
  MDU_EIN,
  SUSIV2,

  // Outputs
  DCCOperations,
  DCCService,
  DECUPZpp,
  DECUPZsu,
  MDUZpp,
  MDUZsu,
  ZUSI,

  // System
  OTA,
}

State state = State.Suspended;

class FakeSysService implements SysService {
  @override
  Future<Info> fetch() {
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => Info(
        state: state.toString().split('.')[1],
        version: '1.2.3',
        projectName: 'Frontend',
        compileTime: '18:31:28',
        compileDate: 'Jul 28 2024',
        idfVersion: '5.2.dev',
        mdns: 'remise.local',
        ip: '127.0.0.1',
        mac: '80:80:80:80:80:80',
        heap: Random().nextInt(384) + 8100000,
        internalHeap: Random().nextInt(384) + 32000,
        current: 0,
        voltage: Random().nextInt(500) + 18000,
        temperature: Random().nextDouble() * 2.0 + 25.0,
      ),
    );
  }
}
