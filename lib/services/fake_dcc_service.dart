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

import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/services/dcc_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class FakeDccService implements DccService {
  final ProviderContainer ref;

  FakeDccService(this.ref);

  List<Loco> _readFile() {
    return ref.read(locosProvider);
  }

  void _writeFile(List<Loco> locos) {
    ref.read(locosProvider.notifier).updateLocos(locos);
  }

  @override
  Future<List<Loco>> fetchLocos() {
    return Future.delayed(const Duration(seconds: 1), () => _readFile());
  }

  @override
  Future<Loco> fetchLoco(int address) {
    return Future.delayed(
      const Duration(milliseconds: 250),
      () => _readFile().firstWhere(
        (loco) => loco.address == address,
        orElse: () => throw Exception('Failed to fetch loco'),
      ),
    );
  }

  @override
  Future<void> updateLocos(List<Loco> locos) {
    return Future.delayed(const Duration(seconds: 1), () => _writeFile(locos));
  }

  @override
  Future<void> updateLoco(int address, Loco loco) {
    return Future.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> deleteLocos() {
    return Future.delayed(const Duration(seconds: 1), () => _writeFile([]));
  }

  @override
  Future<void> deleteLoco(int address) {
    return Future.delayed(const Duration(milliseconds: 250));
  }
}
