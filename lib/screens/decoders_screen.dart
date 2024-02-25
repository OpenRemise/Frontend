import 'package:Frontend/models/info.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/selected_loco_index.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:Frontend/widgets/cab.dart';
import 'package:Frontend/widgets/delete_loco_dialog.dart';
import 'package:Frontend/widgets/edit_loco_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DecodersScreen extends ConsumerStatefulWidget {
  const DecodersScreen({super.key});

  @override
  ConsumerState<DecodersScreen> createState() => _DecodersScreenState();
}

class _DecodersScreenState extends ConsumerState<DecodersScreen> {
  static final int _minWidth = int.parse(const String.fromEnvironment('WIDTH'));

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedLocoIndexProvider);

    // On small screens show only either locos or cab
    if (selectedIndex != null &&
        MediaQuery.of(context).size.width < _minWidth) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Cab(),
      );
    }
    // On big screens show locos and cab side by side
    else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _locos(),
      );
    }
  }

  Widget _locos() {
    final sys = ref.watch(sysProvider);
    final locos = ref.watch(locosProvider);
    final selectedIndex = ref.watch(selectedLocoIndexProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  onPressed: sys.value?.mode == 'Suspended' ||
                          sys.value?.mode == 'DCCOperations'
                      ? _powerAction
                      : null,
                  tooltip: Locales.string(context, 'on_off'),
                  isSelected: sys.value?.mode == 'DCCOperations',
                  selectedIcon: const Icon(Icons.power_off_outlined),
                  icon: const Icon(Icons.power_outlined),
                ),
                title: IconButton(
                  onPressed: null,
                  tooltip: Locales.string(context, 'search'),
                  icon: const Icon(Icons.search),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Clear index, otherwise cab might do B$
                      ref
                          .read(selectedLocoIndexProvider.notifier)
                          .update((state) => null);
                      ref.read(locosProvider.notifier).fetchLocos();
                    },
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.sync_outlined),
                  ),
                  IconButton(
                    onPressed: () => showEditLocoDialog(context: context),
                    tooltip: Locales.string(context, 'add'),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  IconButton(
                    onPressed: () => showDeleteLocoDialog(context: context),
                    tooltip: Locales.string(context, 'delete_all'),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
                floating: true,
              ),
              locos.when(
                data: (data) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        index < data.length ? _tile(index) : null,
                    childCount: locos.value?.length,
                  ),
                ),
                error: (error, stackTrace) =>
                    const SliverToBoxAdapter(child: Text('error')),
                loading: () => SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/loading.gif'),
                      const Text('loading...'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (selectedIndex != null &&
            MediaQuery.of(context).size.width >= _minWidth)
          const Cab(),
      ],
    );
  }

  Widget _tile(int index) {
    final locos = ref.watch(locosProvider);
    final selectedIndex = ref.watch(selectedLocoIndexProvider);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.train_outlined),
        title: Text(locos.requireValue[index].name),
        subtitle: Text(
          '${Locales.string(context, 'address')} ${locos.requireValue[index].address}',
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

  void _powerAction() async {
    final sys = ref.watch(sysProvider);
    await ref.read(sysProvider.notifier).updateInfo(
          Info(
            mode: sys.requireValue.mode == 'Suspended'
                ? 'DCCOperations'
                : 'Suspended',
          ),
        );
  }
}
