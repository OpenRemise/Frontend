import 'package:Frontend/models/ms_database.dart';
import 'package:Frontend/providers/ms_database.dart';
import 'package:Frontend/widgets/mdu_dialog.dart';
import 'package:Frontend/widgets/ota_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    debugPrint('UpdateScreen dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Locales.currentLocale(context)!;
    final msDatabase = ref.watch(msDatabaseProvider(locale));

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
                onPressed: () async => ref.refresh(msDatabaseProvider(locale)),
                tooltip: 'Refresh',
                icon: const Icon(Icons.sync_outlined),
              ),
              IconButton(
                onPressed: _loadFromFile,
                tooltip: Locales.string(context, 'load_local_bin_zsu'),
                icon: const Icon(Icons.file_open_outlined),
              ),
            ],
            floating: true,
          ),
          msDatabase.when(
            skipLoadingOnRefresh: false,
            data: (data) => SliverList.list(
              children: [
                for (final MapEntry<String, MsDatabaseInfo> entry
                    in msDatabase.value!.entries)
                  Card(
                    child: ExpansionTile(
                      leading: IconButton(
                        onPressed: () => _loadFromUri(
                          Uri.http(
                            'www.zimo.at',
                            '/web2010/clicks/click.php',
                            {'id': 'MS_${entry.key}'},
                          ),
                        ),
                        tooltip: 'Download',
                        icon: const Icon(Icons.download_outlined),
                      ),
                      title: Text('MS/N decoder ${entry.key}.0'),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      expandedAlignment: Alignment.centerLeft,
                      children: [
                        for (final bulletPoint in entry.value.changelog)
                          Text('- $bulletPoint'),
                      ],
                    ),
                  ),
              ],
            ),
            error: (error, stackTrace) => const SliverToBoxAdapter(
              child: Text('error'),
            ),
            loading: () => SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/loading.gif'),
                  const Text('loading...'),
                ],
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
      allowedExtensions: ['bin', 'zsu'],
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

  Future<void> _loadFromUri(Uri uri) async {
    showDialog(
      context: context,
      builder: (_) => MduDialog.fromUri(uri),
      barrierDismissible: false,
    );
  }
}
