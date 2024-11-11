// Copyright (C) 2024 Vincent Hamp
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

import 'package:Frontend/models/zsu.dart';
import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/widgets/decup_dialog.dart';
import 'package:Frontend/widgets/mdu_dialog.dart';
import 'package:Frontend/widgets/ota_dialog.dart';
import 'package:Frontend/widgets/zusi_dialog.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

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
            floating: true,
          ),
          SliverList.list(
            children: [
              Card.outlined(
                child: ListTile(
                  title: SvgPicture.asset(
                    ref.watch(darkModeProvider)
                        ? 'data/images/dark.svg'
                        : 'data/images/light.svg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.scaleDown,
                  ),
                  subtitle: const Center(
                    child: Text(
                      'Update firmware and frontend',
                    ),
                  ),
                  enabled: z21Status.hasValue &&
                      z21Status.requireValue.trackVoltageOff(),
                  onTap: _openRemiseLoadFromFile,
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
                  subtitle: const Center(
                    child: Text(
                      'Update decoder or sound project',
                    ),
                  ),
                  enabled: z21Status.hasValue &&
                      z21Status.requireValue.trackVoltageOff(),
                  onTap: _zimoLoadFromFile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openRemiseLoadFromFile() async {
    return FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin', 'zip'],
      withData: true,
    )
        .then((FilePickerResult? result) {
      if (result == null) {
        return;
      } else if (result.files[0].extension == 'bin') {
        showDialog(
          context: context,
          builder: (_) => OtaDialog.fromFile(result.files.first.bytes!),
          barrierDismissible: false,
        );
      } else if (result.files[0].extension == 'zip') {
        final archive = ZipDecoder().decodeBytes(result.files.first.bytes!);
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

  Future<void> _zimoLoadFromFile() async {
    return FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zpp', 'zsu'],
      withData: true,
    )
        .then((FilePickerResult? result) {
      if (result == null) {
        return;
      } else if (result.files[0].extension == 'zpp') {
        showDialog(
          context: context,
          builder: (_) => ZusiDialog.fromFile(result.files.first.bytes!),
          barrierDismissible: false,
        );
      } else if (result.files[0].extension == 'zsu') {
        final _zsu = Zsu(result.files.first.bytes!);
        showDialog(
          context: context,
          builder: (_) => _zsu.firmwares.values.first.type < 3
              ? DecupDialog.fromFile(result.files.first.bytes!)
              : MduDialog.fromFile(result.files.first.bytes!),
          barrierDismissible: false,
        );
      } else {
        return null;
      }
    });
  }

  /*
  Future<void> _loadFromUri(Uri uri) async {
    showDialog(
      context: context,
      builder: (_) => MduDialog.fromUri(uri),
      barrierDismissible: false,
    );
  }
  */
}
