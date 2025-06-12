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

import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/services/zimo/fake_mdu_service.dart';
import 'package:Frontend/services/zimo/mdu_service.dart';
import 'package:Frontend/services/zimo/ws_mdu_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mdu_service.g.dart';

/// \todo document
@riverpod
MduService mduService(ref, String unencodedPath) =>
    const String.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES') == 'true'
        ? FakeMduService()
        : WsMduService(ref.read(domainProvider), unencodedPath);
