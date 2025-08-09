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
import 'package:Frontend/model/bidi.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/provider/dark_mode.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/provider/roco/z21_status.dart';
import 'package:Frontend/provider/throttle_registry.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/widget/dialog/delete_loco.dart';
import 'package:Frontend/widget/dialog/edit_loco.dart';
import 'package:Frontend/widget/error_gif.dart';
import 'package:Frontend/widget/loading_gif.dart';
import 'package:Frontend/widget/png_picture.dart';
import 'package:Frontend/widget/throttle/cv_terminal.dart';
import 'package:Frontend/widget/throttle/key_press_notifier.dart';
import 'package:Frontend/widget/throttle/keypad.dart';
import 'package:Frontend/widget/throttle/railcom.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_weight_slider/vertical_weight_slider.dart';

/// Throttle
///
/// \todo document
class Throttle extends ConsumerStatefulWidget {
  final Loco initialLoco;

  const Throttle({super.key, required this.initialLoco});

  @override
  ConsumerState<Throttle> createState() => _ThrottleState();
}

/// \todo document
class _ThrottleState extends ConsumerState<Throttle> {
  /// \todo document
  Loco? _loco;

  /// \todo document
  final KeyPressNotifier _keyPressNotifier = KeyPressNotifier();

  /// \todo document
  final KeyPressNotifier _cvKeyPressNotifier = KeyPressNotifier();

  /// \todo document
  final KeyPressNotifier _throttleKeyPressNotifier = KeyPressNotifier();

  /// \todo document
  late final Timer _timer;

  /// \todo document
  WeightSliderController? _sliderController;

  /// \todo document
  final FocusNode _focusNode = FocusNode();

  /// \todo document
  @override
  void initState() {
    super.initState();

    _keyPressNotifier.addListener(
      () => _focusNode.hasFocus
          ? _cvKeyPressNotifier.notifyKeyPress(_keyPressNotifier.lastKeyCode!)
          : _throttleKeyPressNotifier
              .notifyKeyPress(_keyPressNotifier.lastKeyCode!),
    );

    _throttleKeyPressNotifier.addListener(
      () => _onPressedLoco(_throttleKeyPressNotifier.lastKeyCode!),
    );

    _timer = Timer.periodic(const Duration(milliseconds: 500), _railComData);
  }

  /// \todo document
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final z21 = ref.watch(z21ServiceProvider);

    // https://github.com/flutter/flutter/issues/112197
    return StreamBuilder(
      // Changing speed steps requires rebuild of slider
      key: ValueKey(_loco?.speedSteps),
      stream: z21.stream.where(
        (command) => switch (command) {
          LanXLocoInfo(locoAddress: var a)
              when a == widget.initialLoco.address =>
            true,
          LanRailComDataChanged(locoAddress: var a)
              when a == widget.initialLoco.address =>
            true,
          _ => false
        },
      ),
      builder: (context, snapshot) {
        final z21Status = ref.watch(z21StatusProvider);

        if (!snapshot.hasError) {
          // Snapshot does not contain data yet, request it
          if (!snapshot.hasData) {
            z21.lanXGetLocoInfo(widget.initialLoco.address);
            _loco = null;
          }
          // Snapshot contains LAN_X_LOCO_INFO and we are not initialized
          else if (snapshot.data is LanXLocoInfo && _loco == null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _initializeLoco(snapshot.data! as LanXLocoInfo),
            );
          }
          // Snapshot contains LAN_RAILCOM_DATACHANGED and we are initialized
          else if (snapshot.data is LanRailComDataChanged && _loco != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _updateRailCom(snapshot.data! as LanRailComDataChanged),
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              AppBar(
                leading: IconButton(
                  onPressed: z21Status.hasValue
                      ? (z21Status.requireValue.centralState & 0x02 == 0x02
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
                      builder: (_) =>
                          EditLocoDialog(widget.initialLoco.address),
                    ),
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit),
                  ),
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
                      builder: (_) =>
                          DeleteLocoDialog(widget.initialLoco.address),
                    ),
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(throttleRegistryProvider.notifier)
                        .deleteLoco(widget.initialLoco.address),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                  ),
                ],
                scrolledUnderElevation: 0,
              ),
              Expanded(
                child: snapshot.hasError
                    ? const ErrorGif()
                    : snapshot.hasData && _loco != null
                        ? LayoutGrid(
                            // We need some padding here because slider has a pretty big transparent pointer
                            // Without padding, slider and functions wouldn't be on the same height
                            areas: '''
                                   locos   locos   locos   slider
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
                              _locosGridArea().inGridArea('locos'),
                              _imageGridArea().inGridArea('image'),
                              _bidiGridArea().inGridArea('bidi'),
                              _cvGridArea().inGridArea('cv'),
                              _sliderGridArea().inGridArea('slider'),
                              _buttonsGridArea().inGridArea('buttons'),
                            ],
                          )
                        : const LoadingGif(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// \todo document
  Widget _locosGridArea() {
    // Only show locos which are not already open in other controllers
    final freeLocos = SplayTreeSet<Loco>.from(
      ref.watch(locosProvider).where(
            (l) =>
                l.address == _loco!.address ||
                ref
                    .watch(throttleRegistryProvider)
                    .none((c) => c.address == l.address),
          ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<Loco>(
          width: constraints.maxWidth,
          inputDecorationTheme:
              const InputDecorationTheme(border: InputBorder.none),
          initialSelection: _loco,
          onSelected: (selectedLoco) {
            if (selectedLoco != null &&
                selectedLoco.address != _loco!.address) {
              ref
                  .read(throttleRegistryProvider.notifier)
                  .updateLoco(_loco!.address, selectedLoco);
            }
          },
          dropdownMenuEntries: freeLocos
              .map(
                (loco) => DropdownMenuEntry(
                  value: loco,
                  label: '${loco.name} (${loco.address})',
                ),
              )
              .toList(),
        );
      },
    );
  }

  /// \todo document
  Widget _imageGridArea() {
    return const Center(
      child: PngPicture.asset('data/images/loco_placeholder.png'),
    );
  }

  /// \todo document
  Widget _bidiGridArea() {
    return RailCom(loco: _loco!);
  }

  /// \todo document
  Widget _cvGridArea() {
    return CvTerminal(
      key: ValueKey(_loco?.speedSteps),
      focusNode: _focusNode,
      loco: _loco!,
      keyPressNotifier: _cvKeyPressNotifier,
    );
  }

  /// \todo document
  Widget _sliderGridArea() {
    final darkMode = ref.watch(darkModeProvider);
    final speed = decodeRvvvvvvv(_loco!.speedSteps, _loco!.rvvvvvvv!);
    final z21 = ref.watch(z21ServiceProvider);

    //
    void weight2rvvvvvvv(double weight) {
      final rvvvvvvv = encodeRvvvvvvv(
        _loco!.speedSteps,
        _loco!.rvvvvvvv! >= 0x80,
        (_sliderController!.maxWeight - weight).toInt(),
      );
      ref
          .read(locosProvider.notifier)
          .updateLoco(_loco!.address, _loco!.copyWith(rvvvvvvv: rvvvvvvv));
      z21.lanXSetLocoDrive(_loco!.address, _loco!.speedSteps, rvvvvvvv);
    }

    return GestureDetector(
      onTap: () {
        final weight = _sliderController!.maxWeight.toDouble();
        _sliderController!.jumpTo(weight);
        weight2rvvvvvvv(weight);
      },
      onDoubleTap: () {
        // Weight out of slider limits does not trigger onChanged
        final weight = (_sliderController!.maxWeight + 1).toDouble();
        _sliderController!.jumpTo(weight);
        weight2rvvvvvvv(weight);
      },
      onVerticalDragUpdate: (details) {
        final weight =
            _sliderController!.maxWeight - speed - details.delta.dy / 2;
        _sliderController!
            .jumpTo(weight.clamp(0, _sliderController!.maxWeight.toDouble()));
      },
      child: VerticalWeightSlider(
        controller: _sliderController!,
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
                        .clamp(0, _sliderController!.maxWeight)
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
        onChanged: weight2rvvvvvvv,
      ),
    );
  }

  /// \todo document
  Widget _buttonsGridArea() {
    return Keypad(
      key: ValueKey(_loco?.speedSteps),
      focusNode: _focusNode,
      loco: _loco!,
      keyPressNotifier: _keyPressNotifier,
    );
  }

  /// \todo document
  void _onPressedLoco(int keyCode) {
    final speed = decodeRvvvvvvv(_loco!.speedSteps, _loco!.rvvvvvvv!);
    final z21 = ref.watch(z21ServiceProvider);

    switch (keyCode) {
      case KeyCodes.dir:
        final rvvvvvvv = _loco!.rvvvvvvv! & 0x80 != 0
            ? _loco!.rvvvvvvv! & ~0x80 // Clear
            : _loco!.rvvvvvvv! | 0x80; // Set
        ref
            .read(locosProvider.notifier)
            .updateLoco(_loco!.address, _loco!.copyWith(rvvvvvvv: rvvvvvvv));
        z21.lanXSetLocoDrive(_loco!.address, _loco!.speedSteps, rvvvvvvv);
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
            (speed + 1).clamp(0, _sliderController!.maxWeight.toInt());
        final rvvvvvvv = encodeRvvvvvvv(
          _loco!.speedSteps,
          _loco!.rvvvvvvv! >= 0x80,
          newSpeed,
        );
        ref
            .read(locosProvider.notifier)
            .updateLoco(_loco!.address, _loco!.copyWith(rvvvvvvv: rvvvvvvv));
        z21.lanXSetLocoDrive(_loco!.address, _loco!.speedSteps, rvvvvvvv);
        _sliderController!
            .jumpTo((_sliderController!.maxWeight - newSpeed).toDouble());
        break;
      // Remove
      case KeyCodes.remove:
        final newSpeed =
            (speed - 1).clamp(0, _sliderController!.maxWeight.toInt());
        final rvvvvvvv = encodeRvvvvvvv(
          _loco!.speedSteps,
          _loco!.rvvvvvvv! >= 0x80,
          newSpeed,
        );
        ref
            .read(locosProvider.notifier)
            .updateLoco(_loco!.address, _loco!.copyWith(rvvvvvvv: rvvvvvvv));
        z21.lanXSetLocoDrive(_loco!.address, _loco!.speedSteps, rvvvvvvv);
        _sliderController!
            .jumpTo((_sliderController!.maxWeight - newSpeed).toDouble());
        break;
      // Check
      case KeyCodes.enter:
        break;
      // Short press functions
      case >= KeyCodes.f0 && <= KeyCodes.f63:
        final int mask = 1 << keyCode;
        final bool state = _loco!.f31_0! & mask != 0;
        final int f31_0 = state
            ? _loco!.f31_0! & ~mask // Clear
            : _loco!.f31_0! | mask; // Set
        ref
            .read(locosProvider.notifier)
            .updateLoco(_loco!.address, _loco!.copyWith(f31_0: f31_0));
        z21.lanXSetLocoFunction(_loco!.address, state ? 0 : 1, keyCode);
        break;
    }
  }

  /// \todo document
  void _initializeLoco(LanXLocoInfo locoInfo) {
    final speed = decodeRvvvvvvv(locoInfo.speedSteps, locoInfo.rvvvvvvv);

    // Set missing ephemeral state
    setState(() {
      final maxWeight = locoInfo.speedSteps == 0
          ? 14
          : locoInfo.speedSteps == 2
              ? 28
              : 126;
      _sliderController = WeightSliderController(
        initialWeight: maxWeight - (speed.isNegative ? 0 : speed.toDouble()),
        maxWeight: maxWeight,
      );
    });

    // Update loco with LanXLocoInfo
    ref.read(locosProvider.notifier).updateLoco(
          widget.initialLoco.address,
          widget.initialLoco.copyWith(
            mode: locoInfo.mode,
            busy: locoInfo.busy,
            speedSteps: locoInfo.speedSteps,
            rvvvvvvv: locoInfo.rvvvvvvv,
            f31_0: locoInfo.f31_0,
          ),
        );

    // Add listener
    ref.listenManual(
      locosProvider,
      (previous, next) {
        _loco = next
            .firstWhereOrNull((l) => l.address == widget.initialLoco.address);
      },
      fireImmediately: true,
    );
  }

  /// \todo document
  void _updateRailCom(LanRailComDataChanged railComData) {
    if (railComData.options != _loco!.bidi?.options ||
        railComData.speed != _loco!.bidi?.speed ||
        railComData.qos != _loco!.bidi?.qos) {
      ref.read(locosProvider.notifier).updateLoco(
            _loco!.address,
            _loco!.copyWith(
              bidi: BiDi(
                options: railComData.options,
                speed: railComData.speed,
                qos: railComData.qos,
              ),
            ),
          );
    }
  }

  /// \todo document
  void _railComData(_) {
    final z21 = ref.watch(z21ServiceProvider);
    z21.lanRailComGetData(widget.initialLoco.address);
  }
}
