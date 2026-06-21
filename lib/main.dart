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

/// Main
///
/// \file   main.dart
/// \author Vincent Hamp
/// \date   01/11/2024

import 'package:Frontend/config/fake_services_provider_container.dart';
import 'package:Frontend/config/prefs.dart';
import 'package:Frontend/ui/core/themes/dark_mode.dart';
import 'package:Frontend/ui/core/themes/dark_theme.dart';
import 'package:Frontend/ui/core/themes/light_theme.dart';
import 'package:Frontend/ui/core/themes/text_scaler.dart';
import 'package:Frontend/ui/core/themes/throttle_size.dart';
import 'package:Frontend/ui/home/widgets/home_view.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// \todo document
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set minimum window size for Desktop
  if (!kIsWeb) {
    await DesktopWindow.setMinWindowSize(throttleSize * 1.2);
  }

  // Shared preferences
  prefs = await SharedPreferences.getInstance();

  if (kDebugMode) {
    // debugPaintSizeEnabled = true;
    // debugPrintGestureArenaDiagnostics = true;
  }

  // Expose global `ProviderContainer` to widget tree for fake services
  if (const bool.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES')) {
    runApp(
      UncontrolledProviderScope(
        container: fakeServicesProviderContainer,
        child: const App(),
      ),
    );
  }
  // Otherwise use `ProviderScope`
  else {
    runApp(const ProviderScope(child: App()));
  }
}

/// \todo document
class App extends ConsumerWidget {
  const App({super.key});

  /// \todo document
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: const HomeView(),
      builder: (_, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            MediaQuery.textScalerOf(context).scale(1.0) *
                ref.watch(textScalerProvider),
          ),
        ),
        child: child!,
      ),
      title: 'OpenRemise',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(darkModeProvider) ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
