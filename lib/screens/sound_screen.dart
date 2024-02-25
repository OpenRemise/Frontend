import 'package:Frontend/models/sound_database.dart';
import 'package:Frontend/providers/sound_database.dart';
import 'package:Frontend/widgets/zusi_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundScreen extends ConsumerStatefulWidget {
  const SoundScreen({super.key});

  @override
  ConsumerState<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends ConsumerState<SoundScreen> {
  @override
  Widget build(BuildContext context) {
    final Locale locale = Locales.currentLocale(context)!;
    final soundDatabase = ref.watch(soundDatabaseProvider(locale));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: const IconButton(
              onPressed: null,
              tooltip: 'TODO switch MDU/ZUSI',
              icon: Icon(Icons.question_mark_outlined),
            ),
            title: IconButton(
              onPressed: null,
              tooltip: Locales.string(context, 'search'),
              icon: const Icon(Icons.search),
            ),
            actions: [
              IconButton(
                onPressed: () async =>
                    ref.refresh(soundDatabaseProvider(locale)),
                tooltip: 'Refresh',
                icon: const Icon(Icons.sync_outlined),
              ),
              IconButton(
                onPressed: _loadFromFile,
                tooltip: Locales.string(context, 'load_local_zpp'),
                icon: const Icon(Icons.file_open_outlined),
              ),
            ],
            floating: true,
          ),
          soundDatabase.when(
            skipLoadingOnRefresh: false,
            data: (data) => SliverList.list(
              children: _projects(),
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

  List<Widget> _projects() {
    final Locale locale = Locales.currentLocale(context)!;
    final soundDatabase = ref.watch(soundDatabaseProvider(locale));

    List<Widget> projects = [];

    for (final MapEntry<String, List<SoundDatabaseInfo>> entry
        in soundDatabase.value!.entries) {
      projects.add(
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const Divider(),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
              child: Image.network(
                entry.value.first.flag,
                width: 24,
                height: 14,
              ),
            ),
          ],
        ),
      );

      for (final SoundDatabaseInfo info in entry.value) {
        projects.add(
          Card(
            child: ExpansionTile(
              title: Text(info.heading),
              // controlAffinity: ListTileControlAffinity.leading,
              children: [
                Row(
                  children: [
                    if (info.image != null)
                      Flexible(
                        flex: 1,
                        child: Image.network(
                          info.image!,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    Flexible(flex: 4, child: Text(info.description)),
                  ],
                ),
                for (final project in info.projects)
                  for (final download in project.downloads)
                    TextButton.icon(
                      onPressed: () => _loadFromUri(
                        Uri.http(
                          'www.zimo.at',
                          '/web2010/scripts/download_zpp.php',
                          {
                            'b': download.b,
                            'f': download.f,
                          },
                        ),
                      ),
                      icon: const Icon(Icons.download_outlined),
                      label: Text(download.f),
                    ),
              ],
            ),
          ),
        );
      }
    }

    return projects;
  }

  Future<void> _loadFromFile() async {
    return FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zpp'],
      withData: true,
    )
        .then((FilePickerResult? result) {
      if (result != null) {
        showDialog(
          context: context,
          builder: (_) => ZusiDialog.fromFile(result.files.first.bytes!),
          barrierDismissible: false,
        );
      }
      return null;
    });
  }

  Future<void> _loadFromUri(Uri uri) async {
    showDialog(
      context: context,
      builder: (_) => ZusiDialog.fromUri(uri),
      barrierDismissible: false,
    );
  }
}
