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

import 'package:Frontend/constants/small_screen_width.dart';
import 'package:Frontend/providers/dcc.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/selected_loco_index.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/widgets/controller.dart';
import 'package:Frontend/widgets/delete_loco_dialog.dart';
import 'package:Frontend/widgets/edit_loco_dialog.dart';
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
    final selectedIndex = ref.watch(selectedLocoIndexProvider);

    // On small screens show only either locos or controller
    if (selectedIndex != null &&
        MediaQuery.of(context).size.width < smallScreenWidth) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: Controller(),
        ),
      );
    }
    // On big screens show locos and controller side by side
    else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _locos(),
      );
    }
  }

  /// \todo document
  Widget _locos() {
    final dcc = ref.watch(dccProvider);
    final locos = ref.watch(locosProvider);
    final selectedIndex = ref.watch(selectedLocoIndexProvider);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  onPressed: z21Status.hasValue
                      ? (z21Status.requireValue.trackVoltageOff()
                          ? z21.lanXSetTrackPowerOn
                          : z21.lanXSetTrackPowerOff)
                      : null,
                  tooltip: 'On/off',
                  isSelected: z21Status.hasValue &&
                      !z21Status.requireValue.trackVoltageOff(),
                  selectedIcon: const Icon(Icons.power_off_outlined),
                  icon: const Icon(Icons.power_outlined),
                ),
                title: const IconButton(
                  onPressed: null,
                  tooltip: 'Search',
                  icon: Icon(Icons.search),
                ),
                actions: [
                  IconButton(
                    onPressed: () => showEditLocoDialog(context: context),
                    tooltip: 'Add',
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  IconButton(
                    onPressed: () => showDeleteLocoDialog(context: context),
                    tooltip: 'Delete all',
                    icon: const Icon(Icons.delete_outline),
                  ),
                  IconButton(
                    onPressed: () {
                      // Clear index, otherwise cab might do B$
                      ref
                          .read(selectedLocoIndexProvider.notifier)
                          .update((state) => null);
                      ref.read(dccProvider.notifier).fetchLocos();
                    },
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.sync_outlined),
                  ),
                ],
                floating: true,
              ),
              dcc.when(
                data: (data) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        index < locos.length ? _tile(index) : null,
                    childCount: locos.length,
                  ),
                ),
                error: (error, stackTrace) =>
                    const SliverToBoxAdapter(child: Icon(Icons.error_outline)),
                loading: () =>
                    const SliverFillRemaining(child: Text('loading')),
              ),
            ],
          ),
        ),
        if (selectedIndex != null &&
            MediaQuery.of(context).size.width >= smallScreenWidth)
          const Controller(),
      ],
    );
  }

  /// \todo document
  Widget _tile(int index) {
    final locos = ref.watch(locosProvider);
    final selectedIndex = ref.watch(selectedLocoIndexProvider);

    return Card.outlined(
      child: ListTile(
        leading: const Icon(Icons.train_outlined),
        title: Text(locos[index].name),
        subtitle: Text(
          'Address ${locos[index].address}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () =>
                  showEditLocoDialog(context: context, index: index),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: () =>
                  showDeleteLocoDialog(context: context, index: index),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        onTap: () => ref
            .read(selectedLocoIndexProvider.notifier)
            .update((state) => selectedIndex != index ? index : null),
        selected: selectedIndex == index,
      ),
    );
  }
}
