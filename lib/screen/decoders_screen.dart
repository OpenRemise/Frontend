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

import 'package:Frontend/provider/dcc.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/provider/throttle_registry.dart';
import 'package:Frontend/provider/z21_service.dart';
import 'package:Frontend/provider/z21_status.dart';
import 'package:Frontend/widget/dialog/delete_loco.dart';
import 'package:Frontend/widget/dialog/edit_loco.dart';
import 'package:Frontend/widget/error_gif.dart';
import 'package:Frontend/widget/loading_gif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class DecodersScreen extends ConsumerStatefulWidget {
  const DecodersScreen({super.key});

  @override
  ConsumerState<DecodersScreen> createState() => _DecodersScreenState();
}

/// \todo document
class _DecodersScreenState extends ConsumerState<DecodersScreen> {
  /// \todo document
  @override
  Widget build(BuildContext context) {
    final dcc = ref.watch(dccProvider);
    final locos = ref.watch(locosProvider);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: z21Status.hasValue
                  ? (z21Status.requireValue.trackVoltageOff()
                      ? z21.lanXSetTrackPowerOn
                      : z21.lanXSetTrackPowerOff)
                  : null,
              tooltip: z21Status.hasValue &&
                      !z21Status.requireValue.trackVoltageOff()
                  ? 'Power off'
                  : 'Power on',
              isSelected: z21Status.hasValue &&
                  !z21Status.requireValue.trackVoltageOff(),
              selectedIcon: const Icon(Icons.power_off),
              icon: const Icon(Icons.power),
            ),
            actions: [
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const EditLocoDialog(null),
                ),
                tooltip: 'Add',
                icon: const Icon(Icons.add_circle),
              ),
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const DeleteLocoDialog(null),
                ),
                tooltip: 'Delete all',
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () => ref.read(dccProvider.notifier).refresh(),
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
              ),
            ],
            scrolledUnderElevation: 0,
            floating: true,
          ),
          dcc.when(
            data: (data) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => index < locos.length ? _tile(index) : null,
                childCount: locos.length,
              ),
            ),
            error: (error, stackTrace) => const SliverFillRemaining(
              child: Center(child: ErrorGif()),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: LoadingGif()),
            ),
          ),
        ],
      ),
    );
  }

  /// \todo document
  Widget _tile(int index) {
    final locos = ref.watch(locosProvider);
    final loco = locos.elementAt(index);
    final active = ref
        .watch(throttleRegistryProvider)
        .any((c) => c.address == loco.address);

    return Card.outlined(
      child: ListTile(
        leading: Icon(active ? Icons.train : Icons.train_outlined),
        title: Text(loco.name),
        subtitle: Text(
          'Address ${loco.address}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditLocoDialog(loco.address),
              ),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => DeleteLocoDialog(loco.address),
              ),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        onTap: () => active
            ? ref
                .read(throttleRegistryProvider.notifier)
                .deleteLoco(loco.address)
            : ref
                .read(throttleRegistryProvider.notifier)
                .updateLoco(loco.address, loco),
      ),
    );
  }
}
