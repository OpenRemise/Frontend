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

import 'package:Frontend/constant/open_remise_icons.dart';
import 'package:Frontend/constant/small_screen_width.dart';
import 'package:Frontend/model/zimo/zpp.dart';
import 'package:Frontend/model/zimo/zsu.dart';
import 'package:Frontend/provider/available_firmware_version.dart';
import 'package:Frontend/provider/dark_mode.dart';
import 'package:Frontend/provider/internet_status.dart';
import 'package:Frontend/provider/roco/z21_status.dart';
import 'package:Frontend/provider/sys.dart';
import 'package:Frontend/provider/text_scaler.dart';
import 'package:Frontend/utility/dark_mode_color_mapper.dart';
import 'package:Frontend/utility/grayscale_color_mapper.dart';
import 'package:Frontend/widget/dialog/confirmation.dart';
import 'package:Frontend/widget/dialog/download.dart';
import 'package:Frontend/widget/dialog/ota.dart';
import 'package:Frontend/widget/dialog/zimo/decup.dart';
import 'package:Frontend/widget/dialog/zimo/mdu.dart';
import 'package:Frontend/widget/dialog/zimo/sound.dart';
import 'package:Frontend/widget/dialog/zimo/zusi.dart';
import 'package:Frontend/widget/power_icon_button.dart';
import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pub_semver/pub_semver.dart';

/// Update screen
///
/// The update screen is used to perform updates or uploads (e.g. firmware,
/// sound, ...) for various devices from different manufacturers. A [stepper](https://api.flutter.dev/flutter/material/Stepper-class.html)
/// widget guides users through the process. Some update files can be selected
/// from different sources, for example from a local file or directly from the
/// internet.
///
/// The update processes themselves run in modal dialogs. The data exchange then
/// usually takes place via WebSockets to the respective endpoint (e.g. `/ota/`).
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
    final z21Status = ref.watch(z21StatusProvider);
    final bool smallWidth =
        MediaQuery.of(context).size.width < smallScreenWidth;

    final bool online =
        internetStatus.asData?.value == InternetStatus.connected;
    final bool firmwareUpdateAvailable = availableFirmwareVersion.hasValue &&
        sys.hasValue &&
        Version.parse(availableFirmwareVersion.requireValue) >
            Version.parse(sys.requireValue.version);
    final bool trackVoltageOff =
        z21Status.asData?.value.trackVoltageOff() == true;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: PowerIconButton(),
            title: smallWidth ? null : Text('Update'),
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
                            'data/images/logos/openremise.svg',
                            colorMapper: trackVoltageOff
                                ? DarkModeColorMapper(
                                    ref.watch(darkModeProvider),
                                  )
                                : GrayscaleColorMapper(),
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
                            'data/images/logos/zimo.svg',
                            colorMapper:
                                trackVoltageOff ? null : GrayscaleColorMapper(),
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
                      if (kDebugMode)
                        Card.outlined(
                          child: ListTile(
                            title: SvgPicture.asset(
                              'data/images/logos/dh.svg',
                              colorMapper: trackVoltageOff
                                  ? null
                                  : GrayscaleColorMapper(),
                              width: 100,
                              height: 100,
                              fit: BoxFit.scaleDown,
                            ),
                            enabled: trackVoltageOff,
                            onTap: () => setState(() {
                              ++_index;
                              _selected
                                ..removeRange(0, _selected.length)
                                ..add(2);
                            }),
                          ),
                        ),
                      if (kDebugMode)
                        Card.outlined(
                          child: ListTile(
                            title: SvgPicture.asset(
                              'data/images/logos/tams.svg',
                              colorMapper: trackVoltageOff
                                  ? null
                                  : GrayscaleColorMapper(),
                              width: 100,
                              height: 100,
                              fit: BoxFit.scaleDown,
                            ),
                            enabled: trackVoltageOff,
                            onTap: () => setState(() {
                              ++_index;
                              _selected
                                ..removeRange(0, _selected.length)
                                ..add(3);
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
                              title: const Text('Update MS/N decoder'),
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
                              title: const Text('Update MX decoder'),
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
                                  text: 'Upload to MS/N decoder via ',
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
                                  text: 'Upload to MX decoder via ',
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
                                  text: 'Upload to decoder via ',
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
                                  onTap: _openRemiseFromWeb,
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
                                    'Update ${_selected.elementAtOrNull(1) == 0 ? 'MS/N' : 'MX'} decoder from web',
                                  ),
                                  enabled: trackVoltageOff && online,
                                  onTap: _zimoFirmwareFromWeb,
                                ),
                              ),
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open),
                                  title: Text(
                                    'Update ${_selected.elementAtOrNull(1) == 0 ? 'MS/N' : 'MX'} decoder from file',
                                  ),
                                  enabled: trackVoltageOff,
                                  onTap: _zimoFromFile,
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
                                          'Upload to ${_selected.elementAtOrNull(1) == 2 ? 'MS/N' : 'MX'} decoder via ',
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
                                  onTap: _zimoSoundFromWeb,
                                ),
                              ),
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open),
                                  title: RichText(
                                    text: TextSpan(
                                      text:
                                          'Upload to ${_selected.elementAtOrNull(1) == 2 ? 'MS/N' : 'MX'} decoder via ',
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
                                  onTap: _zimoFromFile,
                                ),
                              ),
                            ],
                          4 => [
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.language),
                                  title: RichText(
                                    text: TextSpan(
                                      text: 'Upload to decoder via ',
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
                                  onTap: _zimoSoundFromWeb,
                                ),
                              ),
                              Card.outlined(
                                child: ListTile(
                                  leading: const Icon(Icons.file_open),
                                  title: RichText(
                                    text: TextSpan(
                                      text: 'Upload to decoder via ',
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
                                  onTap: _zimoFromFile,
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
        indexStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 14 / ref.watch(textScalerProvider),
        ),
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
      showDialog<bool>(
        context: context,
        builder: (_) => ConfirmationDialog(
          title: 'Update to ${availableFirmwareVersion.requireValue}',
        ),
      ).then((value) {
        if (value != true) return;
        showDialog(
          context: context,
          builder: (_) => OtaDialog.fromFile(bin.content),
          barrierDismissible: false,
        );
      });
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
    // No REST API, no fun :(
    http
        .get(
      Uri.parse(
        _selected.elementAtOrNull(1) == 0
            ? 'https://www.zimo.at/web2010/support/MS-MN-Decoder-SW-Update.htm'
            : 'https://www.zimo.at/web2010/support/MX-Decoder-SW-Update.htm',
      ),
    )
        .then(
      (response) {
        final exp = RegExp(
          _selected.elementAtOrNull(1) == 0
              ? r'href=".+?id=MS_[0-9].[0-9].*"'
              : r'href=".+?id=DS[0-9]+"',
        );
        final zips = exp.firstMatch(response.body);
        return zips!.group(0)?.replaceAll('href=', '').replaceAll('"', '');
      },
    ).then(
      (url) {
        if (url == null) return;
        showDialog<Uint8List>(
          context: context,
          builder: (_) => DownloadDialog(url),
          barrierDismissible: false,
        ).then(
          (value) {
            if (value == null) return;
            final archive = ZipDecoder().decodeBytes(value);
            final archiveFile =
                archive.files.firstWhereOrNull((f) => f.name.endsWith('.zsu'));
            if (archiveFile == null) return;
            final zsu = Zsu(archiveFile.content);
            showDialog<bool>(
              context: context,
              builder: (_) => ConfirmationDialog(
                title:
                    'Update to ${zsu.firmwares.values.first.majorVersion}.${zsu.firmwares.values.first.minorVersion}',
              ),
            ).then((value) {
              if (value != true) return;
              showDialog(
                context: context,
                builder: (_) => switch (_selected.elementAtOrNull(1)) {
                  0 => MduDialog.zsu(zsu),
                  1 => DecupDialog.zsu(zsu),
                  _ => throw UnimplementedError(),
                },
                barrierDismissible: false,
              );
            });
          },
        );
      },
    );
  }

  /// \todo document
  Future<void> _zimoSoundFromWeb() async {
    showDialog<String>(
      context: context,
      builder: (_) => const SoundDialog(),
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
                _ => throw UnimplementedError(),
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
            _ => throw UnimplementedError(),
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
            _ => throw UnimplementedError(),
          },
          barrierDismissible: false,
        );
      } else {
        return null;
      }
    });
  }
}
