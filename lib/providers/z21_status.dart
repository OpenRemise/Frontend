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

import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_status.g.dart';

/// \todo document
@riverpod
Stream<LanXStatusChanged> z21Status(ref) async* {
  final z21 = ref.watch(z21ServiceProvider);
  await for (final status in z21.stream.where(
    (command) => switch (command) { LanXStatusChanged() => true, _ => false },
  )) {
    yield status;
  }
}
