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

import 'dart:async';
import 'dart:collection';

import 'package:Frontend/constant/key_codes.dart';
import 'package:Frontend/constant/turnout_map.dart';
import 'package:Frontend/model/config.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/controller_registry.dart';
import 'package:stream_summary_builder/stream_summary_builder.dart';
import 'package:Frontend/provider/dark_mode.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/provider/settings.dart';
import 'package:Frontend/provider/turnouts.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/utility/dark_mode_color_mapper.dart';
import 'package:Frontend/widget/controller/cv_terminal.dart';
import 'package:Frontend/widget/controller/key_press_notifier.dart';
import 'package:Frontend/widget/controller/keypad.dart';
import 'package:Frontend/widget/controller/railcom.dart';
import 'package:Frontend/widget/dialog/add_edit.dart';
import 'package:Frontend/widget/dialog/delete.dart';
import 'package:Frontend/widget/error_gif.dart';
import 'package:Frontend/widget/loading_gif.dart';
import 'package:Frontend/widget/png_picture.dart';
import 'package:Frontend/widget/power_icon_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vertical_weight_slider/vertical_weight_slider.dart';

/// Controller
///
/// \todo document
class Controller<T> extends ConsumerStatefulWidget {
  final dynamic item;

  const Controller({super.key, required this.item})
      : assert(T == Loco || T == Turnout);

  @override
  ConsumerState<Controller<T>> createState() => _ControllerState<T>();
}

/// \todo document
class _ControllerState<T> extends ConsumerState<Controller<T>> {
  Loco get loco => widget.item as Loco;
  Turnout get turnout => widget.item as Turnout;

  /// \todo document
  final KeyPressNotifier _allKeysNotifier = KeyPressNotifier();

  /// \todo document
  final KeyPressNotifier _cvKeysNotifier = KeyPressNotifier();

  /// \todo document
  final KeyPressNotifier _functionKeysNotifier = KeyPressNotifier();

  /// \todo document
  Timer? _timer;
  static const _period = Duration(milliseconds: 500);

  /// \todo document
  WeightSliderController? _locoSliderController;

  /// \todo document
  Timer? _settleTimer;

  /// \todo document
  static const _settleDelay = Duration(milliseconds: 1000);

  /// \todo document
  bool _settleActive = false;

  /// \todo document
  final FocusNode _cvFocusNode = FocusNode();

  /// \todo document
  bool _initialized = false;

  /// \todo document
  List<int> _turnoutPositions = [];

  /// \todo document
  int _turnoutState = -1;

  /// \todo document
  @override
  void initState() {
    super.initState();

    _allKeysNotifier.addListener(
      () => _cvFocusNode.hasFocus
          ? _cvKeysNotifier.notifyKeyPress(_allKeysNotifier.lastKeyCode!)
          : _functionKeysNotifier.notifyKeyPress(_allKeysNotifier.lastKeyCode!),
    );

    switch (T) {
      case const (Loco):
        _initLoco();
        break;

      case const (Turnout):
        _initTurnout();
        break;
    }
  }

  /// \todo document
  void _initLoco() async {
    //
    _functionKeysNotifier.addListener(
      () => _locoOnPressed(_functionKeysNotifier.lastKeyCode!),
    );

    //
    final z21 = ref.read(z21ServiceProvider);
    final locoInfoFuture = z21.stream
        .where(
          (c) => c is LanXLocoInfo && c.locoAddress == loco.address,
        )
        .cast<LanXLocoInfo>()
        .first;

    //
    z21.lanXGetLocoInfo(loco.address);

    //
    final locoInfo = await locoInfoFuture;

    // Update loco from LAN_X_LOCO_INFO
    ref.read(locosProvider.notifier).updateLoco(
          loco.address,
          loco.copyWith(
            mode: locoInfo.mode,
            busy: locoInfo.busy,
            speedSteps: locoInfo.speedSteps,
            rvvvvvvv: locoInfo.rvvvvvvv,
            f31_0: locoInfo.f31_0,
          ),
        );

    // Set missing ephemeral state
    final maxWeight = locoInfo.speedSteps == 0
        ? 14
        : locoInfo.speedSteps == 2
            ? 28
            : 126;
    final speed = locoInfo.speed();
    final weight = maxWeight - (speed.isNegative ? 0 : speed);
    setState(
      () {
        _locoSliderController = WeightSliderController(
          initialWeight: weight.toDouble(),
          maxWeight: maxWeight,
        );
        _initialized = true;
      },
    );

    //
    _timer = Timer.periodic(
      _period,
      (_) => ref.watch(z21ServiceProvider).lanRailComGetData(loco.address),
    );
  }

  /// \todo document
  void _initTurnout() async {
    //
    _functionKeysNotifier.addListener(
      () => _turnoutOnPressed(_functionKeysNotifier.lastKeyCode!),
    );

    //
    final z21 = ref.read(z21ServiceProvider);
    final turnoutInfoFutures = turnout.group.addresses.map(
      (address) => z21.stream
          .where((c) => c is LanXTurnoutInfo && c.accyAddress == address)
          .cast<LanXTurnoutInfo>()
          .first,
    );

    //
    for (final address in turnout.group.addresses) {
      z21.lanXGetTurnoutInfo(address);
    }

    //
    final turnoutInfos = await Future.wait(turnoutInfoFutures);

    // Set missing ephemeral state
    setState(() {
      _turnoutPositions = turnoutInfos.map((e) => e.zz).toList();
      _turnoutState = turnout.group.positions.indexWhere(
        (p) => ListEquality<int>().equals(p, _turnoutPositions),
      );
      _initialized = true;
    });
  }

  /// \todo document
  @override
  void dispose() {
    _allKeysNotifier.dispose();
    _cvKeysNotifier.dispose();
    _functionKeysNotifier.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return StreamSummaryBuilder(
      initialData: <Command>[],
      fold: (summary, value) => [...summary, value],
      stream: _stream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) _syncFromCommands(snapshot.requireData);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              AppBar(
                leading: PowerIconButton(),
                actions: [
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AddEditDialog<T>(item: widget.item),
                    ),
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AddEditDialog<T>(),
                    ),
                    tooltip: 'Add',
                    icon: const Icon(Icons.add_circle),
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => DeleteDialog<T>(item: widget.item),
                    ),
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(controllerRegistryProvider.notifier)
                        .deleteItem<T>(widget.item.address),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                  ),
                ],
                scrolledUnderElevation: 0,
              ),
              Expanded(
                child: snapshot.hasError
                    ? const ErrorGif()
                    : _initialized
                        ? _layoutGrid()
                        : const LoadingGif(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// \todo document
  void _syncFromCommands(List<Command> commands) {
    if (!_initialized || commands.isEmpty) return;

    switch (T) {
      case const (Loco):
        _locoSyncFromCommands(commands);
        break;

      case const (Turnout):
        _turnoutSyncFromCommands(commands);
        break;
    }
  }

  /// \todo document
  void _locoSyncFromCommands(List<Command> commands) {
    Loco newLoco = loco;

    for (final command in commands) {
      switch (command) {
        case LanXLocoInfo locoInfo:
          // Speed changed
          if (loco.rvvvvvvv != locoInfo.rvvvvvvv && !_settleActive) {
            newLoco = newLoco.copyWith(rvvvvvvv: locoInfo.rvvvvvvv);
            final speed = locoInfo.speed();
            final weight = speed.isNegative
                ? _locoSliderController!.maxWeight + 1
                : _locoSliderController!.maxWeight - speed;
            _locoSliderController!.jumpTo(weight.toDouble());
          }

          // Functions changed
          if (loco.f31_0 != locoInfo.f31_0) {
            newLoco = newLoco.copyWith(f31_0: locoInfo.f31_0);
          }
          break;

        case LanRailComDataChanged railComData:
          // RailCom data changed
          final bidi = railComData.bidi();
          if (loco.bidi != bidi) newLoco = newLoco.copyWith(bidi: bidi);
          break;

        default:
          break;
      }
    }

    // Update loco at the end of this frame
    if (newLoco != loco) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) =>
            ref.read(locosProvider.notifier).updateLoco(loco.address, newLoco),
      );
    }
  }

  /// \todo document
  void _turnoutSyncFromCommands(List<Command> commands) {
    final turnouts = ref.read(turnoutsProvider);
    final notifier = ref.read(turnoutsProvider.notifier);

    for (final command in commands) {
      switch (command) {
        case LanXTurnoutInfo turnoutInfo:
          // Find index of address
          final i = turnout.group.addresses
              .indexWhere((a) => a == turnoutInfo.accyAddress);

          // Update group positions (must be immutable)
          _turnoutPositions = List.from(_turnoutPositions)
            ..[i] = turnoutInfo.zz;

          // Find new state
          final state = turnout.group.positions.indexWhere(
            (p) => ListEquality<int>().equals(p, _turnoutPositions),
          );

          // Only update if known
          final newTurnout = turnouts
              .firstWhere((t) => t.address == turnoutInfo.accyAddress)
              .copyWith(position: turnoutInfo.zz);

          // Update turnout at the end of this frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _turnoutState = state);
            notifier.updateTurnout(newTurnout.address, newTurnout);
          });
          break;

        default:
          break;
      }
    }
  }

  /// \todo document
  Stream<Command> _stream() {
    final z21 = ref.watch(z21ServiceProvider);

    return switch (T) {
      const (Loco) => z21.stream.where(
          (command) => switch (command) {
            LanXLocoInfo(locoAddress: var a) when a == loco.address => true,
            LanRailComDataChanged(locoAddress: var a) when a == loco.address =>
              true,
            _ => false
          },
        ),
      const (Turnout) => z21.stream.where(
          (command) => switch (command) {
            LanXTurnoutInfo(accyAddress: var a)
                when turnout.group.addresses.contains(a) =>
              true,
            _ => false
          },
        ),
      _ => z21.stream
    };
  }

  /// \todo document
  Widget _layoutGrid() {
    return switch (T) {
      const (Loco) => LayoutGrid(
          areas: '''
                 locos   locos   locos   locos
                 image   image   image   slider
                 bidi    bidi    bidi    slider
                 cv      cv      cv      slider
                 buttons buttons buttons buttons
                 ''',
          columnSizes: [1.fr, 1.fr, 1.fr, 1.fr],
          rowSizes: [
            0.05.fr,
            0.25.fr,
            0.05.fr,
            0.25.fr,
            0.4.fr,
          ],
          columnGap: 8,
          rowGap: 8,
          children: [
            _locoDropdownMenuGridArea().inGridArea('locos'),
            _locoImageGridArea().inGridArea('image'),
            _locoBidiGridArea().inGridArea('bidi'),
            _cvGridArea().inGridArea('cv'),
            _locoSliderGridArea().inGridArea('slider'),
            _buttonsGridArea().inGridArea('buttons'),
          ],
        ),
      const (Turnout) => LayoutGrid(
          areas: '''
                 turnouts turnouts turnouts turnouts
                 image    image    image    image
                 image    image    image    image
                 cv       cv       cv       .
                 buttons  buttons  buttons  buttons
                 ''',
          columnSizes: [1.fr, 1.fr, 1.fr, 1.fr],
          rowSizes: [
            0.05.fr,
            0.25.fr,
            0.05.fr,
            0.25.fr,
            0.4.fr,
          ],
          columnGap: 8,
          rowGap: 8,
          children: [
            _turnoutDropdownMenuGridArea().inGridArea('turnouts'),
            _turnoutImageGridArea().inGridArea('image'),
            _cvGridArea().inGridArea('cv'),
            _buttonsGridArea().inGridArea('buttons'),
          ],
        ),
      _ => ErrorWidget(Exception('Invalid type'))
    };
  }

  /// \todo document
  Widget _cvGridArea() {
    return CvTerminal<T>(
      item: widget.item,
      focusNode: _cvFocusNode,
      keyPressNotifier: _cvKeysNotifier,
    );
  }

  /// \todo document
  Widget _buttonsGridArea() {
    return Listener(
      onPointerDown: (_) {
        _settleTimer?.cancel();
        _settleActive = true;
      },
      onPointerUp: (_) {
        _settleTimer?.cancel();
        _settleTimer = Timer(_settleDelay, () => _settleActive = false);
      },
      onPointerCancel: (_) {
        _settleTimer?.cancel();
        _settleTimer = Timer(_settleDelay, () => _settleActive = false);
      },
      behavior: HitTestBehavior.translucent,
      child: Keypad<T>(
        item: widget.item,
        focusNode: _cvFocusNode,
        keyPressNotifier: _allKeysNotifier,
      ),
    );
  }

  /// \todo document
  Widget _locoDropdownMenuGridArea() {
    // Only show locos which are not already open in other controllers
    final locos = SplayTreeSet<Loco>.from(
      ref.watch(locosProvider).where(
            (l) =>
                l.address == loco.address ||
                ref
                    .watch(controllerRegistryProvider)
                    .none((c) => c.address == l.address),
          ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<Loco>(
          width: constraints.maxWidth,
          inputDecorationTheme:
              const InputDecorationTheme(border: InputBorder.none),
          initialSelection: loco,
          onSelected: (selectedLoco) {
            if (selectedLoco != null && selectedLoco.address != loco.address) {
              ref
                  .read(controllerRegistryProvider.notifier)
                  .updateItem<Loco>(loco.address, selectedLoco.address);
            }
          },
          dropdownMenuEntries: locos
              .map(
                (l) => DropdownMenuEntry(
                  value: l,
                  label: '${l.name} (${l.address})',
                ),
              )
              .toList(),
        );
      },
    );
  }

  /// \todo document
  Widget _locoImageGridArea() {
    return const Center(
      child: PngPicture.asset('data/images/locos/placeholder.png'),
    );
  }

  /// \todo document
  Widget _locoBidiGridArea() {
    return RailCom(loco: loco);
  }

  /// \todo document
  Widget _locoSliderGridArea() {
    final darkMode = ref.watch(darkModeProvider);
    final speed = decodeRvvvvvvv(loco.speedSteps, loco.rvvvvvvv);

    return Listener(
      onPointerDown: (_) {
        _settleTimer?.cancel();
        _settleActive = true;
      },
      onPointerMove: (_) {
        _settleTimer?.cancel();
        _settleActive = true;
      },
      onPointerUp: (_) {
        _settleTimer?.cancel();
        _settleTimer = Timer(_settleDelay, () => _settleActive = false);
      },
      onPointerCancel: (_) {
        _settleTimer?.cancel();
        _settleTimer = Timer(_settleDelay, () => _settleActive = false);
      },
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _settleTimer?.cancel();
          _settleActive = true;
          _settleTimer = Timer(_settleDelay, () => _settleActive = false);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onTap: () {
          final weight = _locoSliderController!.maxWeight.toDouble();
          _locoSliderController!.jumpTo(weight);
          _lanXSetLocoDrive(
            loco.copyWith(
              rvvvvvvv: encodeRvvvvvvv(
                loco.speedSteps,
                loco.rvvvvvvv >= 0x80,
                (_locoSliderController!.maxWeight - weight).toInt(),
              ),
            ),
          );
        },
        onDoubleTap: () {
          // Weight out of slider limits does not trigger onChanged
          final weight = (_locoSliderController!.maxWeight + 1).toDouble();
          _locoSliderController!.jumpTo(weight);
          _lanXSetLocoDrive(
            loco.copyWith(
              rvvvvvvv: encodeRvvvvvvv(
                loco.speedSteps,
                loco.rvvvvvvv >= 0x80,
                (_locoSliderController!.maxWeight - weight).toInt(),
              ),
            ),
          );
        },
        onVerticalDragUpdate: (details) {
          final weight =
              _locoSliderController!.maxWeight - speed - details.delta.dy / 2;
          _locoSliderController!.jumpTo(
            weight.clamp(0, _locoSliderController!.maxWeight.toDouble()),
          );
        },
        child: VerticalWeightSlider(
          controller: _locoSliderController!,
          height: double.infinity,
          decoration: PointerDecoration(
            height: 3.0,
            largeColor: Color(darkMode ? 0xFF898989 : 0xFF767676),
            mediumColor: Color(darkMode ? 0xFFC5C5C5 : 0xFF3A3A3A),
            smallColor: Color(darkMode ? 0xFFF0F0F0 : 0xFF0F0F0F),
            gap: 30.0,
          ),
          indicator: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Theme.of(context).colorScheme.error,
                height: 3.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  speed.isNegative
                      ? 'ETS'
                      : speed
                          .clamp(0, _locoSliderController!.maxWeight)
                          .toString()
                          .padLeft(3, '0'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontFamily: 'DSEG14',
                  ),
                ),
              ),
            ],
          ),
          onChanged: (weight) => _lanXSetLocoDrive(
            loco.copyWith(
              rvvvvvvv: encodeRvvvvvvv(
                loco.speedSteps,
                loco.rvvvvvvv >= 0x80,
                (_locoSliderController!.maxWeight - weight).toInt(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// \todo document
  Widget _turnoutDropdownMenuGridArea() {
    // Only show turnouts which are not hidden or already open in other controllers
    final turnouts = SplayTreeSet<Turnout>.from(
      ref.watch(turnoutsProvider).where(
            (t) =>
                t.type != 1 &&
                (t.address == turnout.address ||
                    ref
                        .watch(controllerRegistryProvider)
                        .none((c) => c.address == t.address)),
          ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<Turnout>(
          width: constraints.maxWidth,
          inputDecorationTheme:
              const InputDecorationTheme(border: InputBorder.none),
          initialSelection: turnout,
          onSelected: (selectedTurnout) {
            if (selectedTurnout != null &&
                selectedTurnout.address != turnout.address) {
              ref
                  .read(controllerRegistryProvider.notifier)
                  .updateItem<T>(turnout.address, selectedTurnout.address);
            }
          },
          dropdownMenuEntries: turnouts
              .map(
                (t) => DropdownMenuEntry(
                  value: t,
                  label: '${t.name} (${t.address})',
                ),
              )
              .toList(),
        );
      },
    );
  }

  /// \todo document
  Widget _turnoutImageGridArea() {
    return Center(
      child: SvgPicture.asset(
        _turnoutState > -1
            ? turnoutMap[turnout.type]!.assets[_turnoutState]
            : 'data/images/unknown.svg',
        width: double.infinity,
        height: double.infinity,
        colorMapper: DarkModeColorMapper(ref.watch(darkModeProvider)),
      ),
    );
  }

  /// \todo document
  void _locoOnPressed(int keyCode) {
    final speed = decodeRvvvvvvv(loco.speedSteps, loco.rvvvvvvv);

    switch (keyCode) {
      case KeyCodes.dir:
        final rvvvvvvv = loco.rvvvvvvv & 0x80 != 0
            ? loco.rvvvvvvv & ~0x80 // Clear
            : loco.rvvvvvvv | 0x80; // Set
        _lanXSetLocoDrive(loco.copyWith(rvvvvvvv: rvvvvvvv));
        break;
      // MAN
      case KeyCodes.man:
        break;
      // Backspace
      case KeyCodes.backspace:
        break;
      // Add
      case KeyCodes.add:
        final newSpeed =
            (speed + 1).clamp(0, _locoSliderController!.maxWeight.toInt());
        _locoSliderController!
            .jumpTo((_locoSliderController!.maxWeight - newSpeed).toDouble());
        _lanXSetLocoDrive(
          loco.copyWith(
            rvvvvvvv: encodeRvvvvvvv(
              loco.speedSteps,
              loco.rvvvvvvv >= 0x80,
              newSpeed,
            ),
          ),
        );
        break;
      // Remove
      case KeyCodes.remove:
        final newSpeed =
            (speed - 1).clamp(0, _locoSliderController!.maxWeight.toInt());
        _locoSliderController!
            .jumpTo((_locoSliderController!.maxWeight - newSpeed).toDouble());
        _lanXSetLocoDrive(
          loco.copyWith(
            rvvvvvvv: encodeRvvvvvvv(
              loco.speedSteps,
              loco.rvvvvvvv >= 0x80,
              newSpeed,
            ),
          ),
        );
        break;
      // Check
      case KeyCodes.enter:
        break;
      // Short press functions
      case >= KeyCodes.f0 && <= KeyCodes.f63:
        final int mask = 1 << keyCode;
        final bool state = loco.f31_0 & mask != 0;
        final int f31_0 = state
            ? loco.f31_0 & ~mask // Clear
            : loco.f31_0 | mask; // Set
        _lanXSetLocoFunction(
          loco.copyWith(f31_0: f31_0),
          state ? 0 : 1,
          keyCode,
        );
        break;
    }
  }

  /// \todo document
  void _turnoutOnPressed(int keyCode) {
    switch (keyCode) {
      // Add
      case KeyCodes.add:
        _lanXSetTurnout(
          _turnoutState > -1
              ? (_turnoutState + 1) % turnout.group.positions.length
              : 0,
        );
        break;
      // Remove
      case KeyCodes.remove:
        _lanXSetTurnout(
          _turnoutState > -1
              ? (_turnoutState - 1) % turnout.group.positions.length
              : 0,
        );
        break;
      // Short press functions
      case >= KeyCodes.f0 && <= KeyCodes.f63:
        if (keyCode < turnout.group.positions.length) {
          _lanXSetTurnout(keyCode);
        }
        break;
    }
  }

  /// \todo document
  void _lanXSetLocoDrive(Loco loco) {
    ref
        .watch(z21ServiceProvider)
        .lanXSetLocoDrive(loco.address, loco.speedSteps, loco.rvvvvvvv);
    ref.read(locosProvider.notifier).updateLoco(loco.address, loco);
  }

  /// \todo document
  void _lanXSetLocoFunction(Loco loco, int state, int index) {
    ref
        .watch(z21ServiceProvider)
        .lanXSetLocoFunction(loco.address, state, index);
    ref.read(locosProvider.notifier).updateLoco(loco.address, loco);
  }

  /// \todo document
  void _lanXSetTurnout(int state) {
    final z21 = ref.watch(z21ServiceProvider);
    final turnouts = ref.read(turnoutsProvider);
    final notifier = ref.read(turnoutsProvider.notifier);

    for (int i = 0; i < turnout.group.positions[state].length; ++i) {
      final address = turnout.group.addresses[i];
      final position = turnout.group.positions[state][i];

      // Turn on
      z21.lanXSetTurnout(address, position == 2, true);

      // Turn off after accessory switch time
      Future.delayed(
        Duration(
          milliseconds: (ref.read(settingsProvider).value?.dccAccySwitchTime ??
                  Config().dccAccySwitchTime) *
              100,
        ),
        () => z21.lanXSetTurnout(address, position == 2, false),
      );

      // Only update if known
      final newTurnout = turnouts
          .firstWhereOrNull((t) => t.address == address)
          ?.copyWith(position: position);

      // Update turnout
      if (newTurnout != null) {
        notifier.updateTurnout(newTurnout.address, newTurnout);
      }
    }

    setState(() {
      _turnoutPositions = List.from(turnout.group.positions[state]);
      _turnoutState = state;
    });
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
