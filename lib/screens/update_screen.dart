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
    final z21Status = ref.watch(z21StatusProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: const IconButton(
              onPressed: null,
              tooltip: 'TODO',
              icon: Icon(Icons.question_mark_outlined),
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
            child: Center(
              child: Text(
                "ZIMO won't let me show shit here",
              ),
            ),
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
