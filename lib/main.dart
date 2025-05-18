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

import 'dart:async';

import 'package:Frontend/constants/controller_size.dart';
import 'package:Frontend/constants/fake_services_provider_container.dart';
import 'package:Frontend/constants/small_screen_width.dart';
import 'package:Frontend/models/controller.dart';
import 'package:Frontend/models/loco.dart';
import 'package:Frontend/prefs.dart';
import 'package:Frontend/providers/dark_mode.dart';
import 'package:Frontend/providers/loco_controllers.dart';
import 'package:Frontend/providers/text_scaler.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_short_circuit.dart';
import 'package:Frontend/screens/decoders_screen.dart';
import 'package:Frontend/screens/info_screen.dart';
import 'package:Frontend/screens/program_screen.dart';
import 'package:Frontend/screens/settings_screen.dart';
import 'package:Frontend/screens/update_screen.dart';
import 'package:Frontend/widgets/loco_controller.dart';
import 'package:Frontend/widgets/positioned_draggable.dart';
import 'package:Frontend/widgets/short_circuit_dialog.dart';
import 'package:collection/collection.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// \todo document
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set minimum window size for Desktop
  if (!kIsWeb) {
    await DesktopWindow.setMinWindowSize(controllerSize * 1.2);
  }

  // Shared preferences
  prefs = await SharedPreferences.getInstance();

  if (kDebugMode) {
    // debugPaintSizeEnabled = true;
    // debugPrintGestureArenaDiagnostics = true;
  }

  // Expose global `ProviderContainer` to widget tree for fake services
  if (const String.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES') ==
      'true') {
    runApp(
      UncontrolledProviderScope(
        container: fakeServicesProviderContainer,
        child: const MyApp(),
      ),
    );
  }
  // Otherwise use `ProviderScope`
  else {
    runApp(const ProviderScope(child: MyApp()));
  }
}

/// \todo document
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  /// \todo document
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
      home: const HomeView(),
      builder: (_, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(ref.watch(textScalerProvider)),
        ),
        child: child!,
      ),
      title: 'OpenRemise',
      theme: lightThemeBW,
      darkTheme: darkThemeBW,
      themeMode: ref.watch(darkModeProvider) ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// \todo document
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

/// \todo document
class _HomeViewState extends ConsumerState<HomeView> {
  late final Timer _timer;
  bool _smallWidth = true;
  Key _layoutKey = UniqueKey();
  int _index = 0;

  final List<NavigationDestination> _destinations = <NavigationDestination>[
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
      icon: Icon(Icons.integration_instructions_outlined),
      selectedIcon: Icon(Icons.integration_instructions),
      label: 'Program',
    ),
    const NavigationDestination(
      icon: Icon(Icons.cloud_upload_outlined),
      selectedIcon: Icon(Icons.cloud_upload),
      label: 'Update',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  final List<Widget> _pages = [
    const InfoScreen(),
    const DecodersScreen(),
    const ProgramScreen(),
    const UpdateScreen(),
    const SettingsScreen(),
  ];

  /// \todo document
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), _heartbeat);

    // Add listener for short circuit events
    ref.listenManual(
      z21ShortCircuitProvider,
      (previous, next) {
        // Only open a new dialog if not already shown
        if (ModalRoute.of(context)?.isCurrent == true) {
          showDialog(
            context: context,
            builder: (_) => const ShortCircuitDialog(),
            barrierDismissible: false,
          );
        }
      },
    );
  }

  /// \todo document
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final bool smallWidth =
        MediaQuery.of(context).size.width < smallScreenWidth;
    final locoControllers = ref.watch(locoControllersProvider);

    if (smallWidth != _smallWidth) {
      _smallWidth = smallWidth;
      _layoutKey = UniqueKey();
    }

    return Scaffold(
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < smallScreenWidth
            ? SvgPicture.asset(
                ref.watch(darkModeProvider)
                    ? 'data/icons/icon_dark.svg'
                    : 'data/icons/icon_light.svg',
              )
            : null,
        title: MediaQuery.of(context).size.width < smallScreenWidth
            ? const Text('Open|Remise')
            : SvgPicture.asset(
                ref.watch(darkModeProvider)
                    ? 'data/images/logo_dark.svg'
                    : 'data/images/logo_light.svg',
              ),
        actions: [
          IconButton(
            onPressed: () {
              final scale = ref.read(textScalerProvider) + 0.2;
              ref
                  .read(textScalerProvider.notifier)
                  .update(scale > 1.6 ? 1.0 : scale);
            },
            tooltip: 'Toggle font size',
            icon: const Icon(Icons.text_fields_outlined),
          ),
          IconButton(
            icon: Icon(
              ref.watch(darkModeProvider) ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: ref.watch(darkModeProvider)
                ? 'Toggle light mode'
                : 'Toggle dark mode',
            onPressed: () => ref
                .read(darkModeProvider.notifier)
                .update(!ref.read(darkModeProvider)),
          ),
        ],
        scrolledUnderElevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _smallWidth
            ? _smallLayout(locoControllers)
            : _largeLayout(locoControllers),
      ),
    );
  }

  /// \todo document
  Widget _smallLayout(Set<Controller> locoControllers) {
    final locoController = locoControllers.firstOrNull;

    return Column(
      key: _layoutKey,
      children: [
        Expanded(
          child: _index == 1 && locoController != null
              ? LocoController(
                  key: ValueKey(locoController.address),
                  address: locoController.address,
                )
              : _pages[_index],
        ),
        NavigationBar(
          selectedIndex: _index,
          destinations: _destinations,
          onDestinationSelected: (index) => setState(() => _index = index),
        ),
      ],
    );
  }

  /// \todo document
  Widget _largeLayout(Set<Controller> locoControllers) {
    return Stack(
      key: _layoutKey,
      children: [
        Row(
          children: <Widget>[
            // create a navigation rail
            NavigationRail(
              destinations: _destinations
                  .map(
                    (e) => NavigationRailDestination(
                      icon: e.icon,
                      selectedIcon: e.selectedIcon,
                      label: Text(e.label),
                    ),
                  )
                  .toList(),
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              labelType: NavigationRailLabelType.all,
            ),
            const VerticalDivider(thickness: 1, width: 2),
            Expanded(
              child: Center(child: _pages[_index]),
            ),
          ],
        ),
        ...locoControllers.map(
          (locoController) {
            void moveToTop() =>
                ref.read(locoControllersProvider.notifier).updateLoco(
                      locoController.address,
                      Loco(address: locoController.address),
                    );
            return PositionedDraggable(
              key: locoController.key,
              onTap: moveToTop,
              onPanUpdate: (_) => moveToTop(),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: controllerSize.width,
                height: controllerSize.height,
                child: LocoController(
                  key: ValueKey(locoController.address),
                  address: locoController.address,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// \todo document
  void _heartbeat(_) {
    final z21 = ref.read(z21ServiceProvider);
    z21.lanXGetStatus();

    // Recover after socket was closed server side
    z21.stream.listen(
      null,
      onError: (e) {
        debugPrint('Z21 stream onError $e');
        ref.invalidate(z21ServiceProvider);
      },
      onDone: () {
        debugPrint('Z21 stream onDone');
        ref.invalidate(z21ServiceProvider);
      },
    );
  }
}
