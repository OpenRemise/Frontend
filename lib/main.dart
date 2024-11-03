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

import 'dart:async';

import 'package:Frontend/constants/small_screen_width.dart';
import 'package:Frontend/prefs.dart';
import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/screens/decoders_screen.dart';
import 'package:Frontend/screens/info_screen.dart';
import 'package:Frontend/screens/service_screen.dart';
import 'package:Frontend/screens/settings_screen.dart';
import 'package:Frontend/screens/update_screen.dart';
import 'package:Frontend/widgets/domain_dialog.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await DesktopWindow.setMinWindowSize(const Size(480, 800));
  }
  prefs = await SharedPreferences.getInstance();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightThemeBW = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      fontFamily: 'GlacialIndifference',
    );

    final darkThemeBW = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.black,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      fontFamily: 'GlacialIndifference',
    );

    return MaterialApp(
      home: kIsWeb ? const WebHomeView() : const NativeHomeView(),
      title: 'OpenRemise',
      theme: lightThemeBW,
      darkTheme: darkThemeBW,
      themeMode: ref.watch(darkModeProvider) ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}

class NativeHomeView extends ConsumerWidget {
  const NativeHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String domain = ref.watch(domainProvider);
    if (domain.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => showDomainDialog(context: context));
      return const Placeholder();
    } else {
      return const WebHomeView();
    }
  }
}

class WebHomeView extends ConsumerStatefulWidget {
  const WebHomeView({super.key});

  @override
  ConsumerState<WebHomeView> createState() => _WebHomeViewState();
}

class _WebHomeViewState extends ConsumerState<WebHomeView> {
  late final Timer _timer;
  int _index = 0;

  final List<Widget> _children = [
    const InfoScreen(),
    const DecodersScreen(),
    const ServiceScreen(),
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
    return Scaffold(
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < smallScreenWidth
            ? SvgPicture.asset(
                'data/icons/icon.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              )
            : null,
        title: MediaQuery.of(context).size.width < smallScreenWidth
            ? const Text('Open|Remise')
            : SvgPicture.asset(
                'data/images/logo.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
        actions: [
          /*
          IconButton(
            icon: SvgPicture.asset(
              'data/gb.svg',
              width: 20,
              height: 20,
            ),
            onPressed: null,
          ),
          */
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
      body: MediaQuery.of(context).size.width < smallScreenWidth
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
                      icon: Icon(Icons.cloud_upload_outlined),
                      selectedIcon: Icon(Icons.cloud_upload),
                      label: Text('Update'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
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
      bottomNavigationBar: MediaQuery.of(context).size.width < smallScreenWidth
          ? NavigationBar(
              selectedIndex: _index,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: 'Info',
                ),
                NavigationDestination(
                  icon: Icon(Icons.subtitles_outlined),
                  selectedIcon: Icon(Icons.subtitles),
                  label: 'Decoders',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_circle_outlined),
                  selectedIcon: Icon(Icons.build_circle),
                  label: 'Service',
                ),
                NavigationDestination(
                  icon: Icon(Icons.cloud_upload_outlined),
                  selectedIcon: Icon(Icons.cloud_upload),
                  label: 'Update',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
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
    final z21 = ref.read(z21ServiceProvider);
    z21.lanXGetStatus();

    // Recover after socket was closed server side
    z21.stream.listen(
      null,
      onError: (e) => debugPrint(e),
      onDone: () => ref.invalidate(z21ServiceProvider),
    );
  }
}
