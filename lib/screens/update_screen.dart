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

import 'dart:typed_data';

import 'package:Frontend/constants/open_remise_icons.dart';
import 'package:Frontend/models/zpp.dart';
import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/available_firmware_version.dart';
import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/internet_status.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:Frontend/providers/text_scaler.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/widgets/decup_dialog.dart';
import 'package:Frontend/widgets/download_dialog.dart';
import 'package:Frontend/widgets/mdu_dialog.dart';
import 'package:Frontend/widgets/ota_dialog.dart';
import 'package:Frontend/widgets/zimo_sound_dialog.dart';
import 'package:Frontend/widgets/zusi_dialog.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pub_semver/pub_semver.dart';

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
    final availableFirmwareVersion =
        ref.watch(availableFirmwareVersionProvider);
    final internetStatus = ref.watch(internetStatusProvider);
    final sys = ref.watch(sysProvider);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    final bool online = internetStatus.hasValue &&
        internetStatus.requireValue == InternetStatus.connected;
    final bool firmwareUpdateAvailable = availableFirmwareVersion.hasValue &&
        sys.hasValue &&
        Version.parse(availableFirmwareVersion.requireValue) >
            Version.parse(sys.requireValue.version);
    final bool trackVoltageOff =
        z21Status.hasValue && z21Status.requireValue.trackVoltageOff();

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
                onPressed: () => setState(() {
                  _index = 0;
                  _selected.clear();
                }),
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
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
                          enabled: trackVoltageOff,
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
                          enabled: trackVoltageOff,
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
                              leading: const Icon(Icons.developer_board),
                              title: const Text('Update OpenRemise board'),
                              enabled: trackVoltageOff,
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
                              leading: const Icon(Icons.memory),
                              title: const Text('Update ZIMO MS decoder'),
                              enabled: trackVoltageOff,
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
                              leading: const Icon(Icons.memory),
                              title: const Text('Update ZIMO MX decoder'),
                              enabled: trackVoltageOff,
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
                              leading: const Icon(Icons.music_note),
                              title: RichText(
                                text: TextSpan(
                                  text: 'Upload sound to ZIMO MS decoder via ',
                                  children: const [
                                    WidgetSpan(
                                      child: Icon(OpenRemiseIcons.track),
                                    ),
                                  ],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                textScaler: TextScaler.linear(
                                  ref.watch(textScalerProvider),
                                ),
                              ),
                              enabled: trackVoltageOff,
                              onTap: () => setState(() {
                                ++_index;
                                _selected
                                  ..removeRange(1, _selected.length)
                                  ..add(2);
                              }),
                            ),
                          ),
                          Card.outlined(
                            child: ListTile(
                              leading: const Icon(Icons.music_note),
                              title: RichText(
                                text: TextSpan(
                                  text: 'Upload sound to ZIMO MX decoder via ',
                                  children: const [
                                    WidgetSpan(
                                      child: Icon(OpenRemiseIcons.track),
                                    ),
                                  ],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                textScaler: TextScaler.linear(
                                  ref.watch(textScalerProvider),
                                ),
                              ),
                              enabled: trackVoltageOff,
                              onTap: () => setState(() {
                                ++_index;
                                _selected
                                  ..removeRange(1, _selected.length)
                                  ..add(3);
                              }),
                            ),
                          ),
                          Card.outlined(
                            child: ListTile(
                              leading: const Icon(Icons.music_note),
                              title: RichText(
                                text: TextSpan(
                                  text: 'Upload sound to ZIMO decoder via ',
                                  children: const [
                                    WidgetSpan(
                                      child: Icon(OpenRemiseIcons.susi),
                                    ),
                                  ],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                textScaler: TextScaler.linear(
                                  ref.watch(textScalerProvider),
                                ),
                              ),
                              enabled: trackVoltageOff,
                              onTap: () => setState(() {
                                ++_index;
                                _selected
                                  ..removeRange(1, _selected.length)
                                  ..add(4);
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
                      // OpenRemise
                      0 => switch (_selected.elementAtOrNull(1)) {
                          0 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.language),
                                  title: const Text(
                                    'Update OpenRemise board from web',
                                  ),
                                  enabled: trackVoltageOff &&
                                      online &&
                                      firmwareUpdateAvailable,
                                  onTap: () => _openRemiseFromWeb(),
                                ),
                              ),
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open),
                                  title: const Text(
                                    'Update OpenRemise board from file',
                                  ),
                                  enabled: trackVoltageOff,
                                  onTap: _openRemiseFromFile,
                                ),
                              ),
                            ],
                          _ => [ErrorWidget(Exception('Invalid selection'))],
                        },
                      // ZIMO
                      1 => switch (_selected.elementAtOrNull(1)) {
                          0 || 1 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.language),
                                  title: Text(
                                    'Update ZIMO ${_selected.elementAtOrNull(1) == 0 ? 'MS' : 'MX'} decoder from web',
                                  ),
                                  enabled: trackVoltageOff && online,
                                  onTap: () => _zimoFirmwareFromWeb(),
                                ),
                              ),
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open),
                                  title: Text(
                                    'Update ZIMO ${_selected.elementAtOrNull(1) == 0 ? 'MS' : 'MX'} decoder from file',
                                  ),
                                  enabled: trackVoltageOff,
                                  onTap: () => _zimoFromFile(),
                                ),
                              ),
                            ],
                          2 || 3 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.language),
                                  title: RichText(
                                    text: TextSpan(
                                      text:
                                          'Upload sound to ZIMO ${_selected.elementAtOrNull(1) == 2 ? 'MS' : 'MX'} decoder via ',
                                      children: const [
                                        WidgetSpan(
                                          child: Icon(OpenRemiseIcons.track),
                                        ),
                                        TextSpan(text: ' from web'),
                                      ],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    textScaler: TextScaler.linear(
                                      ref.watch(textScalerProvider),
                                    ),
                                  ),
                                  enabled: trackVoltageOff,
                                  onTap: () => _zimoSoundFromWeb(),
                                ),
                              ),
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open),
                                  title: RichText(
                                    text: TextSpan(
                                      text:
                                          'Upload sound to ZIMO ${_selected.elementAtOrNull(1) == 2 ? 'MS' : 'MX'} decoder via ',
                                      children: const [
                                        WidgetSpan(
                                          child: Icon(OpenRemiseIcons.track),
                                        ),
                                        TextSpan(text: ' from file'),
                                      ],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    textScaler: TextScaler.linear(
                                      ref.watch(textScalerProvider),
                                    ),
                                  ),
                                  enabled: trackVoltageOff,
                                  onTap: () => _zimoFromFile(),
                                ),
                              ),
                            ],
                          4 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.language),
                                  title: RichText(
                                    text: TextSpan(
                                      text: 'Upload sound to ZIMO decoder via ',
                                      children: const [
                                        WidgetSpan(
                                          child: Icon(OpenRemiseIcons.susi),
                                        ),
                                        TextSpan(text: ' from web'),
                                      ],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    textScaler: TextScaler.linear(
                                      ref.watch(textScalerProvider),
                                    ),
                                  ),
                                  enabled: trackVoltageOff,
                                  onTap: () => _zimoSoundFromWeb(),
                                ),
                              ),
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open),
                                  title: RichText(
                                    text: TextSpan(
                                      text: 'Upload sound to ZIMO decoder via ',
                                      children: const [
                                        WidgetSpan(
                                          child: Icon(OpenRemiseIcons.susi),
                                        ),
                                        TextSpan(text: ' from file'),
                                      ],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    textScaler: TextScaler.linear(
                                      ref.watch(textScalerProvider),
                                    ),
                                  ),
                                  enabled: trackVoltageOff,
                                  onTap: () => _zimoFromFile(),
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
              physics: const NeverScrollableScrollPhysics(),
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
  Future<void> _openRemiseFromWeb() async {
    final availableFirmwareVersion = ref.read(availableFirmwareVersionProvider);
    showDialog<Uint8List>(
      context: context,
      builder: (_) => DownloadDialog(
        'https://openremise.at/Firmware/releases/download/v${availableFirmwareVersion.requireValue}/Firmware-${availableFirmwareVersion.requireValue}.zip',
      ),
      barrierDismissible: false,
    ).then((value) {
      if (value == null) return;
      final archive = ZipDecoder().decodeBytes(value);
      final bin = archive.findFile('Firmware.bin');
      if (bin == null) return;
      showDialog(
        context: context,
        builder: (_) => OtaDialog.fromFile(bin.content),
        barrierDismissible: false,
      );
    });
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
        if (bin == null) return;
        showDialog(
          context: context,
          builder: (_) => OtaDialog.fromFile(bin.content),
          barrierDismissible: false,
        );
      } else {
        return null;
      }
    });
  }

  /// \todo document
  Future<void> _zimoFirmwareFromWeb() async {
    showDialog<Uint8List>(
      context: context,
      builder: (_) => DownloadDialog(
        switch (_selected.elementAtOrNull(1)) {
          0 => 'https://www.zimo.at/update/FlashFiles/MS_5_5.zip',
          1 => 'https://www.zimo.at/update/FlashFiles/DS240307.zip',
          _ => 'Invalid selection',
        },
      ),
      barrierDismissible: false,
    ).then(
      (value) {
        if (value == null) return;
        final archive = ZipDecoder().decodeBytes(value);
        final archiveFile = archive.findFile(
          _selected.elementAtOrNull(1) == 0 ? 'MS-5.5.0.zsu' : 'DS240307.zsu',
        );
        if (archiveFile == null) return;
        final zsu = Zsu(archiveFile.content);
        showDialog(
          context: context,
          builder: (_) => switch (_selected.elementAtOrNull(1)) {
            0 => MduDialog.zsu(zsu),
            1 => DecupDialog.zsu(zsu),
            _ => ErrorWidget(Exception('Invalid selection')),
          },
          barrierDismissible: false,
        );
      },
    );
  }

  /// \todo document
  Future<void> _zimoSoundFromWeb() async {
    showDialog<String>(
      context: context,
      builder: (_) => const ZimoSoundDialog(),
      barrierDismissible: true,
    ).then(
      (value) {
        if (value == null) return;
        showDialog<Uint8List>(
          context: context,
          builder: (_) => DownloadDialog(value),
          barrierDismissible: false,
        ).then(
          (value) {
            if (value == null) return;
            final zpp = Zpp(value);
            showDialog(
              context: context,
              builder: (_) => switch (_selected.elementAtOrNull(1)) {
                2 => MduDialog.zpp(zpp),
                3 => DecupDialog.zpp(zpp),
                4 => ZusiDialog.zpp(zpp),
                _ => ErrorWidget(Exception('Invalid selection')),
              },
              barrierDismissible: false,
            );
          },
        );
      },
    );
  }

  /// \todo document
  Future<void> _zimoFromFile() async {
    return FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: _selected.elementAt(1) >= 2 ? ['zpp'] : ['zsu'],
      withData: true,
    )
        .then((FilePickerResult? result) {
      if (result?.files[0].extension == 'zpp') {
        final zpp = Zpp(result!.files.first.bytes!);
        showDialog(
          context: context,
          builder: (_) => switch (_selected.elementAtOrNull(1)) {
            2 => MduDialog.zpp(zpp),
            3 => DecupDialog.zpp(zpp),
            4 => ZusiDialog.zpp(zpp),
            _ => ErrorWidget(Exception('Invalid selection')),
          },
          barrierDismissible: false,
        );
      } else if (result?.files[0].extension == 'zsu') {
        final zsu = Zsu(result!.files.first.bytes!);

        /// \todo add check if MX or MS
        /// zsu.firmwares.values.first.type == 3 -> MS
        showDialog(
          context: context,
          builder: (_) => switch (_selected.elementAtOrNull(1)) {
            0 => MduDialog.zsu(zsu),
            1 => DecupDialog.zsu(zsu),
            _ => ErrorWidget(Exception('Invalid selection')),
          },
          barrierDismissible: false,
        );
      } else {
        return null;
      }
    });
  }
}
