import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/selected_loco_index.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

class Controller extends ConsumerStatefulWidget {
  const Controller({super.key});

  @override
  ConsumerState<Controller> createState() => _ControllerState();
}

class _ControllerState extends ConsumerState<Controller> {
  @override
  void initState() {
    super.initState();
    debugPrint('Controller init');
  }

  @override
  void dispose() {
    debugPrint('Controller dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedLocoIndexProvider);
    assert(selectedIndex != null);

    final locos = ref.read(locosProvider);
    final loco = locos[selectedIndex!];

    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    return StreamBuilder(
      // Use loco address as key to ensure snapshot is new each time loco changes
      key: ValueKey(loco.address),
      stream: z21.stream.where(
        (command) => switch (command) { LanXLocoInfo() => true, _ => false },
      ),
      builder: (context, snapshot) {
        // data here
        if (snapshot.hasData) {
          final locoInfo = snapshot.data! as LanXLocoInfo;

          // TODO ok... this might not be ideal
          // Maybe we should only update ONCE at the beginning?
          Future.delayed(
            Duration.zero,
            () => ref.read(locosProvider.notifier).updateLoco(
                  locoInfo.address,
                  loco.copyWith(
                    f31_0: locoInfo.f31_0,
                    rvvvvvvv: locoInfo.rvvvvvvv,
                    speedSteps: locoInfo.speedSteps,
                  ),
                ),
          );
        }
        // neither data nor error
        else if (!snapshot.hasError) {
          // request first data?
          z21.lanXGetLocoInfo(loco.address);
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 480,
            maxWidth: 480,
            maxHeight: 800,
          ),
          child: snapshot.hasError
              ? const Text('error')
              : snapshot.hasData
                  ? AppBar(
                      leading: IconButton(
                        onPressed: z21Status.hasValue
                            ? (z21Status.requireValue.centralState & 0x02 ==
                                    0x02
                                ? z21.lanXSetTrackPowerOn
                                : z21.lanXSetTrackPowerOff)
                            : null,
                        tooltip: 'On/off',
                        isSelected: z21Status.hasValue &&
                            z21Status.requireValue.centralState & 0x02 == 0x00,
                        selectedIcon: const Icon(Icons.power_off_outlined),
                        icon: const Icon(Icons.power_outlined),
                      ),
                      title: ListTile(
                        title: Text(loco.name),
                        subtitle: Text('Address ${loco.address}'),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => ref
                              .read(selectedLocoIndexProvider.notifier)
                              .update((state) => null),
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_outlined),
                        ),
                      ],
                      flexibleSpace: SizedBox.expand(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: LayoutGrid(
                            // We need some padding here because slider has a pretty big transparent pointer
                            // Without padding, slider and functions wouldn't be on the same height
                            areas: '''
                header    header
                padding   slider
                functions slider
                special   footer 
              ''',
                            columnSizes: [2.fr, 1.fr],
                            rowSizes: [
                              (AppBar().preferredSize.height - 25).px,
                              25.px,
                              8.fr,
                              AppBar().preferredSize.height.px,
                            ],
                            columnGap: 8,
                            rowGap: 8,
                            children: [
                              // const Center(child: Placeholder()).inGridArea('header'),
                              Center(child: _buttons()).inGridArea('functions'),
                              Center(child: _slider()).inGridArea('slider'),
                              Center(child: _footer()).inGridArea('footer'),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Text('loading'),
        );
      },
    );
  }

  Widget _buttons() {
    final selectedIndex = ref.watch(selectedLocoIndexProvider);
    final locos = ref.read(locosProvider);
    final loco = locos[selectedIndex!];
    final z21 = ref.watch(z21ServiceProvider);

    /*
    I don't get how the childAspectRatio relates to the actual own child size?
    1 -> 6
    2 -> 3
    3 -> 2
    4 -> 1.5
    */
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      crossAxisCount: 4,
      mainAxisSpacing: 8.0,
      childAspectRatio: 1.5,
      children: [
        for (int i = 0; i < 32; ++i)
          ToggleButtons(
            isSelected: [loco.f31_0 & (1 << i) != 0],
            onPressed: (_) {
              final int mask = 1 << i;
              final bool state = loco.f31_0 & mask != 0;
              ref.read(locosProvider.notifier).updateLoco(
                    loco.address,
                    loco.copyWith(
                      f31_0: state
                          ? loco.f31_0 & ~mask // Clear
                          : loco.f31_0 | mask, // Set
                    ),
                  );
              z21.lanXSetLocoFunction(loco.address, state ? 0 : 1, i);
            },
            borderRadius: BorderRadius.circular(12),
            children: [Text('F$i')],
          ),
      ],
    );
  }

  Widget _slider() {
    final selectedIndex = ref.watch(selectedLocoIndexProvider);
    final locos = ref.read(locosProvider);
    final loco = locos[selectedIndex!];
    final z21 = ref.watch(z21ServiceProvider);

    return LinearGauge(
      end: 126,
      gaugeOrientation: GaugeOrientation.vertical,
      rulers: RulerStyle(
        textStyle: Theme.of(context).textTheme.labelLarge,
        rulerPosition: RulerPosition.right,
      ),
      pointers: [
        Pointer(
          value: (loco.rvvvvvvv & 0x7F).toDouble(),
          height: 20,
          color: Theme.of(context).dividerColor,
          width: 20,
          shape: PointerShape.triangle,
          pointerPosition: PointerPosition.left,
        ),
        Pointer(
          value: (loco.rvvvvvvv & 0x7F).toDouble(),
          height: 50,
          color: Colors.transparent,
          shape: PointerShape.circle,
          isInteractive: true,
          onChanged: (double speed) {
            final int rvvvvvvv = (loco.rvvvvvvv & 0x80) | speed.toInt();
            ref
                .read(locosProvider.notifier)
                .updateLoco(loco.address, loco.copyWith(rvvvvvvv: rvvvvvvv));
            z21.lanXSetLocoDrive(loco.address, 2, rvvvvvvv);
          },
        ),
      ],
      curves: const [
        CustomCurve(
          startHeight: 4,
          endHeight: 50,
          midHeight: 15,
          curvePosition: CurvePosition.left,
          end: 126,
          midPoint: 70,
        ),
      ],
    );
  }

  Widget _footer() {
    final selectedIndex = ref.watch(selectedLocoIndexProvider);
    final locos = ref.read(locosProvider);
    final loco = locos[selectedIndex!];
    final z21 = ref.watch(z21ServiceProvider);

    return ToggleButtons(
      isSelected: [loco.rvvvvvvv & 0x80 == 1],
      onPressed: (_) {
        final int rvvvvvvv = loco.rvvvvvvv & 0x80 != 0
            ? loco.rvvvvvvv & ~0x80 // Clear
            : loco.rvvvvvvv | 0x80; // Set
        ref
            .read(locosProvider.notifier)
            .updateLoco(loco.address, loco.copyWith(rvvvvvvv: rvvvvvvv));
        z21.lanXSetLocoDrive(loco.address, 2, rvvvvvvv);
      },
      borderRadius: BorderRadius.circular(12),
      children: [
        Icon(
          loco.rvvvvvvv & 0x80 != 0
              ? Icons.arrow_forward_outlined
              : Icons.arrow_back_outlined,
        ),
      ],
    );
  }
}
