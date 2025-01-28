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

import 'package:Frontend/constants/open_remise_icons.dart';
import 'package:Frontend/models/zpp.dart';
import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/providers/zusi_mode.dart';
import 'package:Frontend/widgets/decup_dialog.dart';
import 'package:Frontend/widgets/mdu_dialog.dart';
import 'package:Frontend/widgets/ota_dialog.dart';
import 'package:Frontend/widgets/zusi_dialog.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// \todo document
class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

/// \todo document
class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  final List<int> _selected = [];
  int _index = 0;

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);
    final zusiMode = ref.watch(zusiModeProvider);

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
              tooltip: 'On/off',
              isSelected: z21Status.hasValue &&
                  !z21Status.requireValue.trackVoltageOff(),
              selectedIcon: const Icon(Icons.power_off_outlined),
              icon: const Icon(Icons.power_outlined),
            ),
            title: IconButton(
              onPressed: () =>
                  ref.read(zusiModeProvider.notifier).update(!zusiMode),
              tooltip: zusiMode ? 'Tracks mode' : 'ZUSI mode',
              isSelected: zusiMode,
              selectedIcon: const Icon(OpenRemiseIcons.susi),
              icon: const Icon(OpenRemiseIcons.susi_off),
            ),
            actions: [
              IconButton(
                onPressed: () => setState(() {
                  _index = 0;
                  _selected.clear();
                }),
                tooltip: 'Refresh',
                icon: const Icon(Icons.sync_outlined),
              ),
            ],
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Stepper(
              steps: <Step>[
                _step(
                  title: const Text('Select manufacturer'),
                  content: Column(
                    children: [
                      Card.outlined(
                        child: ListTile(
                          title: SvgPicture.asset(
                            ref.watch(darkModeProvider)
                                ? 'data/images/logo_dark.svg'
                                : 'data/images/logo_light.svg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.scaleDown,
                          ),
                          enabled: z21Status.hasValue &&
                              z21Status.requireValue.trackVoltageOff(),
                          onTap: () => setState(() {
                            ++_index;
                            _selected
                              ..removeRange(0, _selected.length)
                              ..add(0);
                          }),
                        ),
                      ),
                      Card.outlined(
                        child: ListTile(
                          title: SvgPicture.asset(
                            'data/images/zimo.svg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.scaleDown,
                          ),
                          enabled: z21Status.hasValue &&
                              z21Status.requireValue.trackVoltageOff(),
                          onTap: () => setState(() {
                            ++_index;
                            _selected
                              ..removeRange(0, _selected.length)
                              ..add(1);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                _step(
                  title: const Text('Select action'),
                  content: Column(
                    children: switch (_selected.elementAtOrNull(0)) {
                      0 => [
                          Card.outlined(
                            child: ListTile(
                              leading:
                                  const Icon(Icons.developer_board_outlined),
                              title: const Text('Update OpenRemise board'),
                              enabled: z21Status.hasValue &&
                                  z21Status.requireValue.trackVoltageOff(),
                              onTap: () => setState(() {
                                ++_index;
                                _selected
                                  ..removeRange(1, _selected.length)
                                  ..add(0);
                              }),
                            ),
                          ),
                        ],
                      1 => [
                          Card.outlined(
                            child: ListTile(
                              leading: const Icon(Icons.memory_outlined),
                              title: const Text('Update ZIMO decoder'),
                              enabled: z21Status.hasValue &&
                                  z21Status.requireValue.trackVoltageOff(),
                              onTap: () => setState(() {
                                ++_index;
                                _selected
                                  ..removeRange(1, _selected.length)
                                  ..add(0);
                              }),
                            ),
                          ),
                          Card.outlined(
                            child: ListTile(
                              leading: const Icon(Icons.music_note_outlined),
                              title: Text(
                                'Upload sound to ZIMO MS decoder via ${zusiMode ? 'ZUSI' : 'tracks'}',
                              ),
                              enabled: z21Status.hasValue &&
                                  z21Status.requireValue.trackVoltageOff(),
                              onTap: () => setState(() {
                                ++_index;
                                _selected
                                  ..removeRange(1, _selected.length)
                                  ..add(1);
                              }),
                            ),
                          ),
                          Card.outlined(
                            child: ListTile(
                              leading: const Icon(Icons.music_note_outlined),
                              title: Text(
                                'Upload sound to ZIMO MX decoder via ${zusiMode ? 'ZUSI' : 'tracks'}',
                              ),
                              enabled: z21Status.hasValue &&
                                  z21Status.requireValue.trackVoltageOff(),
                              onTap: () => setState(() {
                                ++_index;
                                _selected
                                  ..removeRange(1, _selected.length)
                                  ..add(2);
                              }),
                            ),
                          ),
                        ],
                      _ => [ErrorWidget(Exception('Invalid selection'))],
                    },
                  ),
                ),
                _step(
                  title: const Text('Select file'),
                  content: Column(
                    children: switch (_selected.elementAtOrNull(0)) {
                      0 => switch (_selected.elementAtOrNull(1)) {
                          0 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open_outlined),
                                  title: const Text(
                                    'Update OpenRemise board from file',
                                  ),
                                  enabled: z21Status.hasValue &&
                                      z21Status.requireValue.trackVoltageOff(),
                                  onTap: _openRemiseFromFile,
                                ),
                              ),
                            ],
                          _ => [ErrorWidget(Exception('Invalid selection'))],
                        },
                      1 => switch (_selected.elementAtOrNull(1)) {
                          0 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open_outlined),
                                  title: const Text(
                                    'Update ZIMO decoder from file',
                                  ),
                                  enabled: z21Status.hasValue &&
                                      z21Status.requireValue.trackVoltageOff(),
                                  onTap: () =>
                                      _zimoFromFile(allowedExtensions: ['zsu']),
                                ),
                              ),
                            ],
                          1 || 2 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open_outlined),
                                  title: Text(
                                    'Upload sound to ZIMO ${_selected.elementAt(1) == 1 ? 'MS' : 'MX'} decoder via ${zusiMode ? 'ZUSI' : 'tracks'} from file',
                                  ),
                                  enabled: z21Status.hasValue &&
                                      z21Status.requireValue.trackVoltageOff(),
                                  onTap: () =>
                                      _zimoFromFile(allowedExtensions: ['zpp']),
                                ),
                              ),
                            ],
                          _ => [ErrorWidget(Exception('Invalid selection'))],
                        },
                      _ => [ErrorWidget(Exception('Invalid selection'))],
                    },
                  ),
                ),
              ],
              currentStep: _index,
              onStepTapped: (int index) {
                // Only allow going backwards
                if (index <= _index) {
                  setState(() {
                    _index = index;
                  });
                }
              },
              controlsBuilder: (context, details) => const SizedBox.shrink(),
              connectorColor:
                  WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// \todo document
  Step _step({
    required Widget title,
    Widget? subtitle,
    required Widget content,
  }) {
    return Step(
      title: title,
      subtitle: subtitle,
      content: content,
      stepStyle: StepStyle(
        color: Theme.of(context).colorScheme.primary,
        indexStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  /// \todo document
  Future<void> _openRemiseFromFile() async {
    return FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin', 'zip'],
      withData: true,
    )
        .then((FilePickerResult? result) {
      if (result?.files[0].extension == 'bin') {
        showDialog(
          context: context,
          builder: (_) => OtaDialog.fromFile(result!.files.first.bytes!),
          barrierDismissible: false,
        );
      } else if (result?.files[0].extension == 'zip') {
        final archive = ZipDecoder().decodeBytes(result!.files.first.bytes!);
        final bin = archive.findFile('Firmware.bin');
        if (bin != null) {
          showDialog(
            context: context,
            builder: (_) => OtaDialog.fromFile(bin.content),
            barrierDismissible: false,
          );
        }
      } else {
        return null;
      }
    });
  }

  /// \todo document
  Future<void> _zimoFromFile({List<String>? allowedExtensions}) async {
    return FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    )
        .then((FilePickerResult? result) {
      if (result?.files[0].extension == 'zpp') {
        final zpp = Zpp(result!.files.first.bytes!);
        showDialog(
          context: context,
          builder: (_) => ref.read(zusiModeProvider)
              ? ZusiDialog.zpp(zpp)
              : _selected.elementAt(1) == 1
                  ? MduDialog.zpp(zpp)
                  : DecupDialog.zpp(zpp),
          barrierDismissible: false,
        );
      } else if (result?.files[0].extension == 'zsu') {
        final zsu = Zsu(result!.files.first.bytes!);
        showDialog(
          context: context,
          builder: (_) => zsu.firmwares.values.first.type < 3
              ? DecupDialog.zsu(zsu)
              : MduDialog.zsu(zsu),
          barrierDismissible: false,
        );
      } else {
        return null;
      }
    });
  }
}
