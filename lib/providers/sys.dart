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

import 'package:Frontend/models/info.dart';
import 'package:Frontend/providers/sys_service.dart';
import 'package:Frontend/services/sys_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sys.g.dart';

/// \todo document
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
