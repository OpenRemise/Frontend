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

import 'dart:collection';

import 'package:Frontend/config/domain.dart';
import 'package:Frontend/config/fake_services_provider_container.dart';
import 'package:Frontend/data/models/loco.dart';
import 'package:Frontend/data/models/turnout.dart';
import 'package:Frontend/data/services/dcc/fake_dcc.dart';
import 'package:Frontend/data/services/dcc/http_dcc.dart';
import 'package:Frontend/data/services/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
abstract interface class DccService {
  Future<Loco> fetchLoco(int address);
  Future<SplayTreeSet<Loco>> fetchLocos();
  Future<void> updateLoco(int address, Loco loco);
  Future<void> updateLocos(SplayTreeSet<Loco> locos);
  Future<void> deleteLoco(int address);
  Future<void> deleteLocos();

  Future<Turnout> fetchTurnout(int address);
  Future<SplayTreeSet<Turnout>> fetchTurnouts();
  Future<void> updateTurnout(int address, Turnout turnout);
  Future<void> updateTurnouts(SplayTreeSet<Turnout> turnouts);
  Future<void> deleteTurnout(int address);
  Future<void> deleteTurnouts();
}

/// \todo document
final dccServiceProvider = Provider<DccService>(
  (ref) => const bool.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES')
      ? FakeDccService(fakeServicesProviderContainer)
      : HttpDccService(
          ref.read(httpClientProvider),
          ref.read(domainProvider),
        ),
);
