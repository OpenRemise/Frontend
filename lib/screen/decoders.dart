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

import 'package:Frontend/constant/open_remise_icons.dart';
import 'package:Frontend/constant/small_screen_width.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/controller_registry.dart';
import 'package:Frontend/provider/dcc.dart';
import 'package:Frontend/provider/decoder_filter.dart';
import 'package:Frontend/provider/decoder_selection.dart';
import 'package:Frontend/provider/filtered_locos.dart';
import 'package:Frontend/provider/filtered_turnouts.dart';
import 'package:Frontend/widget/dialog/add_edit.dart';
import 'package:Frontend/widget/dialog/delete.dart';
import 'package:Frontend/widget/error_gif.dart';
import 'package:Frontend/widget/loading_gif.dart';
import 'package:Frontend/widget/power_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Decoders screen
///
/// The decoders screen displays a list of all available decoders in the system.
/// They are organized into the categories locomotives and turnouts. The
/// corresponding data is retrieved via GET requests: locomotives from
/// `/dcc/locos/`, and turnouts from `/dcc/turnouts`.
///
/// The individual decoders are displayed as [tiles](https://api.flutter.dev/flutter/material/ListTile-class.html)
/// within the list. Clicking on a decoder opens the corresponding control
/// element (e.g. a Throttle for locomotives). Depending on the current screen
/// width, this control either takes up the entire screen or is displayed as a
/// draggable window as an overlay.
///
/// Buttons in the upper right corner of the [app bar](https://api.flutter.dev/flutter/material/SliverAppBar-class.html)
/// allow you to add, edit and delete decoders.
class DecodersScreen extends ConsumerStatefulWidget {
  const DecodersScreen({super.key});

  @override
  ConsumerState<DecodersScreen> createState() => _DecodersScreenState();
}

/// \todo document
class _DecodersScreenState extends ConsumerState<DecodersScreen> {
  bool _showSearch = false;

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final dcc = ref.watch(dccProvider);
    final decoderSelection = ref.watch(decoderSelectionProvider);
    final bool smallWidth =
        MediaQuery.of(context).size.width < smallScreenWidth;
    final addEditDialog = decoderSelection.containsAll([Loco, Turnout])
        ? AddEditDialog()
        : decoderSelection.contains(Loco)
            ? AddEditDialog<Loco>()
            : AddEditDialog<Turnout>();
    final deleteDialog = decoderSelection.containsAll([Loco, Turnout])
        ? DeleteDialog()
        : decoderSelection.contains(Loco)
            ? DeleteDialog<Loco>()
            : DeleteDialog<Turnout>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: PowerIconButton(),
            title: Stack(
              children: [
                Row(
                  children: [
                    SegmentedButton(
                      segments: [
                        ButtonSegment(
                          value: Loco,
                          icon: Icon(
                            decoderSelection.contains(Loco)
                                ? Icons.train
                                : Icons.train_outlined,
                          ),
                          tooltip:
                              '${decoderSelection.contains(Loco) ? 'Hide' : 'Show'} locos',
                        ),
                        ButtonSegment(
                          value: Turnout,
                          icon: Icon(
                            decoderSelection.contains(Turnout)
                                ? OpenRemiseIcons.accessory
                                : OpenRemiseIcons.accessory_outlined,
                          ),
                          tooltip:
                              '${decoderSelection.contains(Turnout) ? 'Hide' : 'Show'} turnouts',
                        ),
                      ],
                      selected: ref.watch(decoderSelectionProvider),
                      onSelectionChanged: (Set<Type> newSelection) => ref
                          .read(decoderSelectionProvider.notifier)
                          .update(newSelection),
                      multiSelectionEnabled: true,
                      showSelectedIcon: false,
                    ),
                  ],
                ),
                if (!smallWidth) Center(child: Text('Decoders')),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => setState(() => _showSearch = !_showSearch),
                tooltip: 'Search',
                icon: Icon(
                  ref.watch(decoderFilterProvider).isEmpty
                      ? Icons.search
                      : Icons.saved_search,
                ),
              ),
              Stack(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => addEditDialog,
                        ),
                        tooltip: addEditDialog.tooltip(),
                        icon: const Icon(Icons.add_circle),
                      ),
                      IconButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => deleteDialog,
                        ),
                        tooltip: deleteDialog.tooltip(),
                        icon: const Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(dccProvider.notifier).refresh();
                          ref.read(decoderFilterProvider.notifier).update(
                                ref
                                    .read(decoderFilterProvider.notifier)
                                    .defaultValue,
                              );
                        },
                        tooltip: 'Refresh',
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_showSearch)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.centerRight,
                        color: Theme.of(context).colorScheme.surface,
                        child: TextFormField(
                          initialValue: ref.read(decoderFilterProvider),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            isDense: true,
                          ),
                          autofocus: true,
                          onChanged: (str) => ref
                              .read(decoderFilterProvider.notifier)
                              .update(str),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: smallWidth
                ? null
                : PreferredSize(
                    preferredSize: Size(double.infinity, 0),
                    child: Divider(thickness: 2),
                  ),
            scrolledUnderElevation: 0,
            centerTitle: true,
            floating: true,
          ),
          ...dcc.when(
            data: (data) => [
              if (decoderSelection.contains(Loco)) _locoList(),
              if (decoderSelection.contains(Turnout)) _turnoutList(),
            ],
            error: (error, stackTrace) => [
              const SliverFillRemaining(child: Center(child: ErrorGif())),
            ],
            loading: () => [
              const SliverFillRemaining(child: Center(child: LoadingGif())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locoList() {
    final locos = ref.watch(filteredLocosProvider);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= locos.length) return null;

          final loco = locos.elementAt(index);
          final active = ref
              .watch(controllerRegistryProvider)
              .any((c) => c.type == Loco && c.address == loco.address);

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
                      builder: (_) => AddEditDialog<Loco>(item: loco),
                    ),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => DeleteDialog<Loco>(item: loco),
                    ),
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              onTap: () => active
                  ? ref
                      .read(controllerRegistryProvider.notifier)
                      .deleteItem<Loco>(loco.address)
                  : ref
                      .read(controllerRegistryProvider.notifier)
                      .updateItem<Loco>(loco.address, loco.address),
            ),
          );
        },
        childCount: locos.length,
      ),
    );
  }

  /// \todo document
  Widget _turnoutList() {
    final turnouts = SplayTreeSet<Turnout>.of(
      ref.watch(filteredTurnoutsProvider).where((t) => t.type != 1),
    );

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= turnouts.length) return null;

          final turnout = turnouts.elementAt(index);
          final active = ref
              .watch(controllerRegistryProvider)
              .any((c) => c.type == Turnout && c.address == turnout.address);

          return Card.outlined(
            child: ListTile(
              leading: Icon(
                active
                    ? OpenRemiseIcons.accessory
                    : OpenRemiseIcons.accessory_outlined,
              ),
              title: Text(turnout.name),
              subtitle: Text(
                'Address ${turnout.address}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AddEditDialog<Turnout>(item: turnout),
                    ),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => DeleteDialog<Turnout>(item: turnout),
                    ),
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              onTap: () => active
                  ? ref
                      .read(controllerRegistryProvider.notifier)
                      .deleteItem<Turnout>(turnout.address)
                  : ref
                      .read(controllerRegistryProvider.notifier)
                      .updateItem<Turnout>(turnout.address, turnout.address),
            ),
          );
        },
        childCount: turnouts.length,
      ),
    );
  }
}
