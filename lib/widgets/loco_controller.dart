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

import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/selected_loco_index.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:gif/gif.dart';

/// \todo document
class LocoController extends ConsumerStatefulWidget {
  const LocoController({super.key});

  @override
  ConsumerState<LocoController> createState() => _LocoControllerState();
}

/// \todo document
class _LocoControllerState extends ConsumerState<LocoController> {
  int _rvvvvvvv = 0;
  int _f31_0 = 0;
  bool _initialized = false;

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedLocoIndexProvider);
    assert(selectedIndex != null);

    final locos = ref.read(locosProvider);
    final loco = locos[selectedIndex!];

    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    // https://github.com/flutter/flutter/issues/112197
    return StreamBuilder(
      // Use loco address as key to ensure snapshot is new each time loco changes
      key: ValueKey(loco.address),
      stream: z21.stream.where(
        (command) => switch (command) { LanXLocoInfo() => true, _ => false },
      ),
      builder: (context, snapshot) {
        // Neither data nor error
        if (!snapshot.hasData && !snapshot.hasError) {
          z21.lanXGetLocoInfo(loco.address);
          Future.delayed(
            Duration.zero,
            () => setState(() {
              _rvvvvvvv = 0;
              _f31_0 = 0;
              _initialized = false;
            }),
          );
        }
        // Data and no error
        else if (snapshot.hasData && !snapshot.hasError && !_initialized) {
          final locoInfo = snapshot.data! as LanXLocoInfo;
          Future.delayed(
            Duration.zero,
            () => setState(() {
              _rvvvvvvv = locoInfo.rvvvvvvv;
              _f31_0 = locoInfo.f31_0;
              _initialized = true;
            }),
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 480,
            maxWidth: 480,
            maxHeight: 800,
          ),
          child: snapshot.hasError
              ? Center(
                  child: Gif(
                    image: AssetImage(
                      ref.watch(darkModeProvider)
                          ? 'data/images/error_dark.gif'
                          : 'data/images/error_light.gif',
                    ),
                    autostart: Autostart.loop,
                    width: 200,
                  ),
                )
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
                            !z21Status.requireValue.trackVoltageOff(),
                        selectedIcon: const Icon(Icons.power_off),
                        icon: const Icon(Icons.power),
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
                          icon: const Icon(Icons.close),
                        ),
                      ],
                      flexibleSpace: SizedBox.expand(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
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
                  : Center(
                      child: Gif(
                        image: AssetImage(
                          ref.watch(darkModeProvider)
                              ? 'data/images/loading_dark.gif'
                              : 'data/images/loading_light.gif',
                        ),
                        autostart: Autostart.loop,
                        width: 200,
                      ),
                    ),
        );
      },
    );
  }

  /// \todo document
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
            isSelected: [_f31_0 & (1 << i) != 0],
            onPressed: (_) {
              final int mask = 1 << i;
              final bool state = _f31_0 & mask != 0;
              setState(() {
                _f31_0 = state
                    ? _f31_0 & ~mask // Clear
                    : _f31_0 | mask; // Set
              });
              ref
                  .read(locosProvider.notifier)
                  .updateLoco(loco.address, loco.copyWith(f31_0: _f31_0));
              z21.lanXSetLocoFunction(loco.address, state ? 0 : 1, i);
            },
            borderRadius: BorderRadius.circular(12),
            children: [Text('F$i')],
          ),
      ],
    );
  }

  /// \todo document
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
          value: (_rvvvvvvv & 0x7F).toDouble(),
          height: 20,
          color: Theme.of(context).dividerColor,
          width: 20,
          shape: PointerShape.triangle,
          pointerPosition: PointerPosition.left,
        ),
        Pointer(
          value: (_rvvvvvvv & 0x7F).toDouble(),
          height: 50,
          color: Colors.transparent,
          shape: PointerShape.circle,
          isInteractive: true,
          onChanged: (double speed) {
            setState(() {
              _rvvvvvvv = (_rvvvvvvv & 0x80) | speed.toInt();
            });
            ref
                .read(locosProvider.notifier)
                .updateLoco(loco.address, loco.copyWith(rvvvvvvv: _rvvvvvvv));
            z21.lanXSetLocoDrive(loco.address, 2, _rvvvvvvv);
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

  /// \todo document
  Widget _footer() {
    final selectedIndex = ref.watch(selectedLocoIndexProvider);
    final locos = ref.read(locosProvider);
    final loco = locos[selectedIndex!];
    final z21 = ref.watch(z21ServiceProvider);

    return ToggleButtons(
      isSelected: [_rvvvvvvv & 0x80 == 1],
      onPressed: (_) {
        setState(() {
          _rvvvvvvv = _rvvvvvvv & 0x80 != 0
              ? _rvvvvvvv & ~0x80 // Clear
              : _rvvvvvvv | 0x80; // Set
        });
        ref
            .read(locosProvider.notifier)
            .updateLoco(loco.address, loco.copyWith(rvvvvvvv: _rvvvvvvv));
        z21.lanXSetLocoDrive(loco.address, 2, _rvvvvvvv);
      },
      borderRadius: BorderRadius.circular(12),
      children: [
        Icon(
          _rvvvvvvv & 0x80 != 0 ? Icons.arrow_forward : Icons.arrow_back,
        ),
      ],
    );
  }
}
