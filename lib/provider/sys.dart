// Copyright (C) 2025 Vincent Hamp
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

import 'package:Frontend/model/info.dart';
import 'package:Frontend/provider/sys_service.dart';
import 'package:Frontend/service/sys_service.dart';
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

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    fetchInfo();
  }

  Future<void> restart() async {
    _service.restart();
  }
}
