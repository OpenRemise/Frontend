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

import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/provider/roco/z21_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class PowerIconButton extends ConsumerWidget {
  const PowerIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    return IconButton(
      onPressed: !z21Status.hasValue
          ? null
          : z21Status.requireValue.trackVoltageOff()
              ? z21.lanXSetTrackPowerOn
              : z21.lanXSetTrackPowerOff,
      tooltip: !z21Status.hasValue
          ? null
          : z21Status.requireValue.trackVoltageOff()
              ? 'Power on'
              : 'Power off',
      isSelected:
          z21Status.hasValue && !z21Status.requireValue.trackVoltageOff(),
      selectedIcon: const Icon(Icons.power_off),
      icon: const Icon(Icons.power),
    );
  }
}
