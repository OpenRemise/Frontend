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

import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/widgets/mdu_dialog.dart';
import 'package:Frontend/widgets/ota_dialog.dart';
import 'package:Frontend/widgets/zusi_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            actions: [
              IconButton(
                onPressed: z21Status.hasValue
                    ? (z21Status.requireValue.trackVoltageOff()
                        ? _loadFromFile
                        : null)
                    : null,
                tooltip: 'Load local .bin/.zpp/.zsu',
                icon: const Icon(Icons.file_open_outlined),
              ),
            ],
            floating: true,
          ),
          const SliverToBoxAdapter(
            child: Placeholder(),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFromFile() async {
    return FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin', 'zpp', 'zsu'],
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
      } else if (result.files[0].extension == 'zpp') {
        showDialog(
          context: context,
          builder: (_) => ZusiDialog.fromFile(result.files.first.bytes!),
          barrierDismissible: false,
        );
      } else if (result.files[0].extension == 'zsu') {
        showDialog(
          context: context,
          builder: (_) => MduDialog.fromFile(result.files.first.bytes!),
          barrierDismissible: false,
        );
      }
      return null;
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
