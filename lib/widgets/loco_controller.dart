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

import 'package:Frontend/models/bidi.dart';
import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/loco_controllers.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:Frontend/widgets/delete_loco_dialog.dart';
import 'package:Frontend/widgets/edit_loco_dialog.dart';
import 'package:Frontend/widgets/error_gif.dart';
import 'package:Frontend/widgets/loading_gif.dart';
import 'package:Frontend/widgets/png_picture.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_weight_slider/vertical_weight_slider.dart';

/// \todo document
class LocoController extends ConsumerStatefulWidget {
  final int address;

  const LocoController({super.key, required this.address});

  @override
  ConsumerState<LocoController> createState() => _LocoControllerState();
}

/// \todo document
class _LocoControllerState extends ConsumerState<LocoController> {
  int _rvvvvvvv = 0;
  int _f31_0 = 0;

  /// \todo document
  late final Timer _timer;

  /// \todo document
  WeightSliderController? _sliderController;

  /// \todo document
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _textFieldHadFocusBeforeGridButton = false;

  /// \todo document
  int _buttonsIndex = 0;

  /// \todo document
  bool _initialized = false;

  /// \todo document
  @override
  void initState() {
    super.initState();
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
    final locos = ref.watch(locosProvider);
    final loco = locos.firstWhere((l) => l.address == widget.address);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    // https://github.com/flutter/flutter/issues/112197
    return StreamBuilder(
      // Use loco speed steps as key to ensure snapshot is new each time speed steps change
      key: ValueKey(loco.speedSteps),
      stream: z21.stream.where(
        (command) => switch (command) {
          LanXLocoInfo(locoAddress: var a) when a == loco.address => true,
          LanRailComDataChanged(locoAddress: var a) when a == loco.address =>
            true,
          _ => false
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasError) {
          // Snapshot does not contain data yet, reset
          if (!snapshot.hasData) {
            z21.lanXGetLocoInfo(loco.address);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => setState(() {
                _rvvvvvvv = 0;
                _f31_0 = 0;
                _initialized = false;
              }),
            );
          }
          // Snapshot contains LAN_X_LOCO_INFO and we are not initialized
          else if (snapshot.data is LanXLocoInfo && !_initialized) {
            final locoInfo = snapshot.data! as LanXLocoInfo;
            final maxWeight = locoInfo.speedSteps == 0
                ? 14
                : locoInfo.speedSteps == 2
                    ? 28
                    : 126;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => setState(() {
                _rvvvvvvv = locoInfo.rvvvvvvv;
                _f31_0 = locoInfo.f31_0;
                _sliderController = WeightSliderController(
                  initialWeight: maxWeight -
                      decodeRvvvvvvv(locoInfo.speedSteps, _rvvvvvvv).toDouble(),
                  maxWeight: maxWeight,
                );
                _initialized = true;
              }),
            );
          }
          // Snapshot contains LAN_RAILCOM_DATACHANGED
          else if (snapshot.data is LanRailComDataChanged) {
            final railComData = snapshot.data! as LanRailComDataChanged;
            if (railComData.options != loco.bidi?.options ||
                railComData.speed != loco.bidi?.speed ||
                railComData.qos != loco.bidi?.qos) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => ref.read(locosProvider.notifier).updateLoco(
                      loco.address,
                      loco.copyWith(
                        bidi: BiDi(
                          options: railComData.options,
                          speed: railComData.speed,
                          qos: railComData.qos,
                        ),
                      ),
                    ),
              );
            }
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
                      builder: (_) => const EditLocoDialog(null),
                    ),
                    tooltip: 'Add',
                    icon: const Icon(Icons.add_circle),
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => EditLocoDialog(loco.address),
                    ),
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => DeleteLocoDialog(loco.address),
                    ),
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(locoControllersProvider.notifier)
                        .deleteLoco(loco.address),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                  ),
                ],
                scrolledUnderElevation: 0,
              ),
              Expanded(
                child: snapshot.hasError
                    ? const ErrorGif()
                    : snapshot.hasData && _initialized
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
                              0.1.fr,
                              0.2.fr,
                              0.4.fr,
                            ],
                            columnGap: 8,
                            rowGap: 8,
                            children: [
                              _locos(loco).inGridArea('locos'),
                              _image().inGridArea('image'),
                              _cv().inGridArea('cv'),
                              _bidi(loco).inGridArea('bidi'),
                              _slider(loco).inGridArea('slider'),
                              _buttons(loco).inGridArea('buttons'),
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
  Widget _locos(Loco loco) {
    // Only show locos which are not already open in other controllers
    final freeLocos = SplayTreeSet<Loco>.from(
      ref.watch(locosProvider).where(
            (l) =>
                l.address == loco.address ||
                ref
                    .watch(locoControllersProvider)
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
                  .read(locoControllersProvider.notifier)
                  .updateLoco(loco.address, selectedLoco);
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
  Widget _image() {
    return const Center(
      child: PngPicture.asset('data/images/loco_placeholder.png'),
    );
  }

  /// \todo document
  Widget _bidi(Loco loco) {
    final railComData = LanRailComDataChanged(
      locoAddress: loco.address,
      receiveCounter: loco.bidi?.receiveCounter ?? 0,
      errorCounter: loco.bidi?.errorCounter ?? 0,
      options: loco.bidi?.options ?? 0,
      speed: loco.bidi?.speed ?? 0,
      qos: loco.bidi?.qos ?? 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            const Icon(Icons.speed),
            const SizedBox(width: 4),
            Text(
              (railComData.kmh() ?? 0).toString().padLeft(3, '0'),
              style: const TextStyle(fontFamily: 'DSEG14'),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.network_check),
            const SizedBox(width: 4),
            Text(
              (railComData.qoS() ?? 0).toString().padLeft(3, '0'),
              style: const TextStyle(fontFamily: 'DSEG14'),
            ),
          ],
        ),
      ],
    );
  }

  /// \todo document
  Widget _cv() {
    return TextField(
      controller: _textEditingController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        icon: const Icon(Icons.integration_instructions_outlined),
        hintText: '// TODO\nProgram...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: _textEditingController.text.isNotEmpty
          ? const TextStyle(fontFamily: 'DSEG14')
          : null,
      readOnly: true,
      showCursor: kDebugMode,
      maxLines: null,
      minLines: 1024,
      scrollController: _scrollController,
      onTap: () => // Scroll to end of TextField
          _textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textEditingController.text.length),
      ),
    );
  }

  /// \todo document
  Widget _slider(Loco loco) {
    final darkMode = ref.watch(darkModeProvider);
    final z21 = ref.watch(z21ServiceProvider);

    return GestureDetector(
      onTap: () {
        _sliderController!.jumpTo(_sliderController!.maxWeight.toDouble());
      },
      onVerticalDragUpdate: (details) {
        final speed = decodeRvvvvvvv(loco.speedSteps, _rvvvvvvv).toDouble();
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
              color: Colors.red,
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
                decodeRvvvvvvv(loco.speedSteps, _rvvvvvvv)
                    .clamp(0, _sliderController!.maxWeight)
                    .toString()
                    .padLeft(3, '0'),
                style: const TextStyle(color: Colors.red, fontFamily: 'DSEG14'),
              ),
            ),
          ],
        ),
        onChanged: (double weight) {
          setState(
            () => _rvvvvvvv = encodeRvvvvvvv(
              loco.speedSteps,
              _rvvvvvvv >= 0x80,
              (_sliderController!.maxWeight - weight).toInt(),
            ),
          );
          ref
              .read(locosProvider.notifier)
              .updateLoco(loco.address, loco.copyWith(rvvvvvvv: _rvvvvvvv));
          z21.lanXSetLocoDrive(
            loco.address,
            loco.speedSteps,
            _rvvvvvvv,
          );
        },
      ),
    );
  }

  /// \todo document
  Widget _buttons(Loco loco) {
    return Listener(
      onPointerDown: (event) =>
          _textFieldHadFocusBeforeGridButton = _focusNode.hasFocus,
      child: GridButton(
        items: [
          [
            switch (_buttonsIndex) {
              0 => _FItem(1),
              1 => _FItem(11),
              2 => _FItem(21),
              3 => _FItem(31),
              _ => throw UnimplementedError(),
            },
            switch (_buttonsIndex) {
              0 => _FItem(2),
              1 => _FItem(12),
              2 => _FItem(22),
              3 => _FItem(32, true),
              _ => throw UnimplementedError(),
            },
            switch (_buttonsIndex) {
              0 => _FItem(3),
              1 => _FItem(13),
              2 => _FItem(23),
              3 => _FItem(33, true),
              _ => throw UnimplementedError(),
            },
            GridButtonItem(
              value: -3,
              child: Icon(
                _rvvvvvvv & 0x80 != 0 ? Icons.switch_left : Icons.switch_right,
                size: 32,
              ),
            ),
          ],
          [
            switch (_buttonsIndex) {
              0 => _FItem(4),
              1 => _FItem(14),
              2 => _FItem(24),
              3 => _FItem(34, true),
              _ => throw UnimplementedError(),
            },
            switch (_buttonsIndex) {
              0 => _FItem(5),
              1 => _FItem(15),
              2 => _FItem(25),
              3 => _FItem(35, true),
              _ => throw UnimplementedError(),
            },
            switch (_buttonsIndex) {
              0 => _FItem(6),
              1 => _FItem(16),
              2 => _FItem(26),
              3 => _FItem(36, true),
              _ => throw UnimplementedError(),
            },
            const GridButtonItem(
              title: kDebugMode ? 'MAN' : '',
              textStyle: TextStyle(fontFamily: 'DSEG14'),
              value: -7,
            ),
          ],
          [
            switch (_buttonsIndex) {
              0 => _FItem(7),
              1 => _FItem(17),
              2 => _FItem(27),
              3 => _FItem(37, true),
              _ => throw UnimplementedError(),
            },
            switch (_buttonsIndex) {
              0 => _FItem(8),
              1 => _FItem(18),
              2 => _FItem(28),
              3 => _FItem(38, true),
              _ => throw UnimplementedError(),
            },
            switch (_buttonsIndex) {
              0 => _FItem(9),
              1 => _FItem(19),
              2 => _FItem(29),
              3 => _FItem(39, true),
              _ => throw UnimplementedError(),
            },
            const GridButtonItem(
              value: -11,
              child: Icon(kDebugMode ? Icons.backspace : null),
            ),
          ],
          [
            const GridButtonItem(
              value: -12,
              child: Icon(kDebugMode ? Icons.add : null),
            ),
            switch (_buttonsIndex) {
              0 => _FItem(0),
              1 => _FItem(10),
              2 => _FItem(20),
              3 => _FItem(30),
              _ => throw UnimplementedError(),
            },
            const GridButtonItem(
              value: -14,
              child: Icon(kDebugMode ? Icons.remove : null),
            ),
            const GridButtonItem(
              value: -15,
              child: Icon(kDebugMode ? Icons.check_circle : null),
            ),
          ],
        ],
        onPressed: (value) {
          // Only re-focus if it *had* focus before and currently doesn't
          if (_textFieldHadFocusBeforeGridButton) {
            FocusScope.of(context).requestFocus(_focusNode);

            // CV?
            if (kDebugMode && value >= 0 || value == -11 || value == -15) {
              return _cvButton(loco, value);
            }
          }
          //
          return _functionButton(loco, value);
        },
        hideSurroundingBorder: true,
      ),
    );
  }

  /// \todo document
  GridButtonItem _FItem(int i, [bool empty = false]) {
    return GridButtonItem(
      title: empty ? '' : i.toString(),
      color: _f31_0 & (1 << i) != 0 ? Theme.of(context).focusColor : null,
      textStyle: const TextStyle(fontFamily: 'DSEG14'),
      value: i,
      longPressValue: 100 + i % 10,
    );
  }

  /// \todo document
  void _cvButton(Loco loco, int value) {
    debugPrint('is text');

    switch (value) {
      case >= 0 && <= 9:
        _textEditingController.text += value.toString();
        break;
      case -11:
        _textEditingController.text = _textEditingController.text
            .substring(0, _textEditingController.text.length - 1);
        break;
      case -15:
        _textEditingController.text += '\n';
        break;
    }

    // Scroll to end of TextField
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
    );
  }

  /// \todo document
  void _functionButton(Loco loco, int value) {
    final selectedIndex = 0;
    final locos = ref.read(locosProvider);
    final loco = locos.elementAt(selectedIndex);
    final z21 = ref.watch(z21ServiceProvider);

    // debugPrint("ain't text");

    switch (value) {
      // DIR
      case -3:
        debugPrint('DIR');
        setState(
          () => _rvvvvvvv = _rvvvvvvv & 0x80 != 0
              ? _rvvvvvvv & ~0x80 // Clear
              : _rvvvvvvv | 0x80, // Set
        );
        ref
            .read(locosProvider.notifier)
            .updateLoco(loco.address, loco.copyWith(rvvvvvvv: _rvvvvvvv));
        z21.lanXSetLocoDrive(
          loco.address,
          loco.speedSteps,
          _rvvvvvvv,
        );
        break;
      // MAN
      case -7:
        debugPrint('MAN');
        break;
      // Backspace
      case -11:
        debugPrint('backspace');
        break;
      // Add
      case -12:
        debugPrint('add');
        break;
      // Remove
      case -14:
        debugPrint('remove');
        break;
      // Check
      case -15:
        debugPrint('check');
        break;
      // Short press functions
      case >= 0 && <= 64:
        debugPrint('F $value');
        final int mask = 1 << value;
        final bool state = _f31_0 & mask != 0;
        setState(
          () => _f31_0 = state
              ? _f31_0 & ~mask // Clear
              : _f31_0 | mask, // Set
        );
        ref
            .read(locosProvider.notifier)
            .updateLoco(loco.address, loco.copyWith(f31_0: _f31_0));
        z21.lanXSetLocoFunction(loco.address, state ? 0 : 1, value);
        break;
      // Long press functions
      case >= 100 && <= 164:
        debugPrint('F long $value');
        setState(() => _buttonsIndex = (value % 100).clamp(0, 3));
        break;
    }
  }

  /// \todo document
  void _railComData(_) {
    final z21 = ref.watch(z21ServiceProvider);
    z21.lanRailComGetData(widget.address);
  }
}
