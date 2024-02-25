import 'dart:async';

import 'package:Frontend/prefs.dart';
import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:Frontend/screens/decoders_screen.dart';
import 'package:Frontend/screens/info_screen.dart';
import 'package:Frontend/screens/service_screen.dart';
import 'package:Frontend/screens/settings_screen.dart';
import 'package:Frontend/screens/sound_screen.dart';
import 'package:Frontend/screens/update_screen.dart';
import 'package:Frontend/widgets/domain_dialog.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await DesktopWindow.setMinWindowSize(const Size(480, 800));
  }
  prefs = await SharedPreferences.getInstance();
  await Locales.init(['de', 'en']);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightTheme = ThemeData(
      colorScheme: const ColorScheme.highContrastLight(
        primary: Colors.red,
        secondary: Colors.red,
      ),
      useMaterial3: true,
    );

    final darkTheme = ThemeData(
      colorScheme: const ColorScheme.highContrastDark(
        primary: Colors.red,
        secondary: Colors.red,
      ),
      useMaterial3: true,
    );

    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        home: const HomeView(),
        title: 'Alpha',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode:
            ref.watch(darkModeProvider) ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
      ),
    );
  }
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  static final int _minWidth = int.parse(const String.fromEnvironment('WIDTH'));
  late final Timer _timer;
  int _index = 0;

  final List<Widget> _children = [
    const InfoScreen(),
    const DecodersScreen(),
    const ServiceScreen(),
    const SoundScreen(),
    const UpdateScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    debugPrint('Home init');
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), _heartbeat);
  }

  @override
  void dispose() {
    debugPrint('Home dispose');
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String domain = ref.watch(domainProvider);
    if (domain.isEmpty) {
      Future.delayed(Duration.zero, () => showDomainDialog(context: context));
      return Placeholder(); // TODO return a nice looking thing while domain is picked
    }

    final Locale? locale = Locales.currentLocale(context);

    return Scaffold(
      appBar: AppBar(
        leading: const Image(
          image: Svg('assets/head.svg'),
        ),
        title: const Text('OpenRemise'),
        actions: [
          IconButton(
            icon: Image(
              width: 20,
              height: 20,
              image: Svg(
                locale == const Locale('en')
                    ? 'assets/gb.svg'
                    : 'assets/de.svg',
              ),
            ),
            onPressed: () => Locales.change(
              context,
              locale == const Locale('en') ? 'de' : 'en',
            ),
          ),
          IconButton(
            icon: Icon(
              ref.watch(darkModeProvider) ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => ref
                .read(darkModeProvider.notifier)
                .update(!ref.read(darkModeProvider)),
          ),
        ],
      ),
      body: MediaQuery.of(context).size.width < _minWidth
          ? _children[_index]
          : Row(
              children: <Widget>[
                // create a navigation rail
                NavigationRail(
                  destinations: const <NavigationRailDestination>[
                    // navigation destinations
                    NavigationRailDestination(
                      icon: Icon(Icons.info_outline),
                      selectedIcon: Icon(Icons.info),
                      label: Text('Info'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.subtitles_outlined),
                      selectedIcon: Icon(Icons.subtitles),
                      label: Text('Decoders'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.build_circle_outlined),
                      selectedIcon: Icon(Icons.build_circle),
                      label: Text('Service'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.music_note_outlined),
                      selectedIcon: Icon(Icons.music_note),
                      label: Text('Sound'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.cloud_upload_outlined),
                      selectedIcon: Icon(Icons.cloud_upload),
                      label: Text('Update'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: LocaleText('settings'),
                    ),
                  ],
                  selectedIndex: _index,
                  onDestinationSelected: (index) => setState(() {
                    _index = index;
                  }),
                  labelType: NavigationRailLabelType.all,
                ),
                const VerticalDivider(thickness: 1, width: 2),
                Expanded(
                  child: Center(
                    child: _children[_index],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: MediaQuery.of(context).size.width < _minWidth
          ? NavigationBar(
              selectedIndex: _index,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: 'Info',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.subtitles_outlined),
                  selectedIcon: Icon(Icons.subtitles),
                  label: 'Decoders',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.build_circle_outlined),
                  selectedIcon: Icon(Icons.build_circle),
                  label: 'Service',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.music_note_outlined),
                  selectedIcon: Icon(Icons.music_note),
                  label: 'Sound',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.cloud_upload_outlined),
                  selectedIcon: Icon(Icons.cloud_upload),
                  label: 'Update',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Locales.string(context, 'settings'),
                ),
              ],
              onDestinationSelected: (index) => setState(() {
                _index = index;
              }),
            )
          : null,
    );
  }

  void _heartbeat(_) {
    ref.read(sysProvider.notifier).fetchInfo();
  }
}
