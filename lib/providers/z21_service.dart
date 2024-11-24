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

import 'package:Frontend/constants/fake_provider_container.dart';
import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/services/fake_z21_service.dart';
import 'package:Frontend/services/ws_z21_service.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_service.g.dart';

/// \todo document
@Riverpod(keepAlive: true)
Z21Service z21Service(ref) =>
    const String.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES') == 'true'
        ? FakeZ21Service(fakeProviderContainer)
        : WsZ21Service(ref.read(domainProvider));
