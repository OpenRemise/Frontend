import 'dart:async';

import 'package:Frontend/models/info.dart';
import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/selected_loco_index.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Cab extends ConsumerStatefulWidget {
  const Cab({super.key});

  @override
  ConsumerState<Cab> createState() => _CabState();
}

class _CabState extends ConsumerState<Cab> {
  static final int _minWidth = int.parse(const String.fromEnvironment('WIDTH'));
  late final Timer _timer;
  late Loco _loco;

  @override
  void initState() {
    super.initState();
    debugPrint('Cab init');
    final selectedIndex = ref.read(selectedLocoIndexProvider);
    assert(selectedIndex != null);
    final locos = ref.read(locosProvider);
    _loco = locos.requireValue[selectedIndex!];
    _timer = Timer.periodic(const Duration(milliseconds: 200), _timerCallack);
  }

  @override
  void dispose() {
    debugPrint('Cab dispose');
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update state if loco index changes and not null
    ref.listen(selectedLocoIndexProvider, (previous, next) {
      if (next == null) return;
      final locos = ref.watch(locosProvider);
      setState(() {
        _loco = locos.requireValue[next];
      });
    });

    final sys = ref.watch(sysProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 480,
        maxHeight: 800,
      ),
      child: AppBar(
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
        title: ListTile(
          title: Text(_loco.name),
          subtitle:
              Text('${Locales.string(context, 'address')} ${_loco.address}'),
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
      ),
    );
  }

  Widget _buttons() {
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
            isSelected: [_loco.functions & (1 << i) != 0],
            onPressed: (_) {
              final int mask = 1 << i;
              setState(() {
                _loco = _loco.copyWith(
                  functions: _loco.functions & mask != 0
                      ? _loco.functions & ~mask
                      : _loco.functions | mask,
                );
              });
            },
            borderRadius: BorderRadius.circular(12),
            children: [Text('F$i')],
          ),
      ],
    );
  }

  Widget _slider() {
    return LinearGauge(
      end: 126,
      gaugeOrientation: GaugeOrientation.vertical,
      rulers: RulerStyle(
        textStyle: Theme.of(context).textTheme.labelLarge,
        rulerPosition: RulerPosition.right,
      ),
      pointers: [
        Pointer(
          value: _loco.speed.toDouble(),
          height: 20,
          color: Theme.of(context).dividerColor,
          width: 20,
          shape: PointerShape.triangle,
          pointerPosition: PointerPosition.left,
        ),
        Pointer(
          value: _loco.speed.toDouble(),
          height: 50,
          color: Colors.transparent,
          shape: PointerShape.circle,
          isInteractive: true,
          onChanged: (double speed) {
            setState(() {
              _loco = _loco.copyWith(speed: speed.toInt());
            });
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
    return ToggleButtons(
      isSelected: [!(_loco.dir > 0)],
      onPressed: (_) => setState(() {
        _loco = _loco.copyWith(dir: _loco.dir > 0 ? -1 : 1);
      }),
      borderRadius: BorderRadius.circular(12),
      children: [
        Icon(
          _loco.dir > 0
              ? Icons.arrow_forward_outlined
              : Icons.arrow_back_outlined,
        ),
      ],
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

  void _timerCallack(_) {
    ref.read(locosProvider.notifier).updateLoco(_loco.address, _loco);
  }
}
