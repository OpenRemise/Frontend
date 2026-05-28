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
/// \file   ui/home/widgets/home_view.dart
/// \author Vincent Hamp
/// \date   01/11/2024

import 'package:Frontend/data/models/connection_status.dart';
import 'package:Frontend/data/repositories/connection_status.dart';
import 'package:Frontend/data/repositories/locos.dart';
import 'package:Frontend/data/repositories/roco/z21_short_circuit.dart';
import 'package:Frontend/data/repositories/turnouts.dart';
import 'package:Frontend/data/services/roco/z21.dart';
import 'package:Frontend/domain/models/loco.dart';
import 'package:Frontend/domain/models/register.dart';
import 'package:Frontend/domain/models/throttle_registry.dart';
import 'package:Frontend/domain/models/turnout.dart';
import 'package:Frontend/ui/core/themes/dark_mode.dart';
import 'package:Frontend/ui/core/themes/small_screen_width.dart';
import 'package:Frontend/ui/core/themes/text_scaler.dart';
import 'package:Frontend/ui/core/themes/throttle_size.dart';
import 'package:Frontend/ui/core/widgets/short_circuit_dialog.dart';
import 'package:Frontend/ui/decoders/widgets/decoders_screen.dart';
import 'package:Frontend/ui/home/widgets/positioned_draggable.dart';
import 'package:Frontend/ui/info/widgets/info_screen.dart';
import 'package:Frontend/ui/program/widgets/program_screen.dart';
import 'package:Frontend/ui/settings/widgets/settings_screen.dart';
import 'package:Frontend/ui/throttle/widgets/throttle.dart';
import 'package:Frontend/ui/update/widgets/update_screen.dart';
import 'package:Frontend/utils/color_mappers/dark_mode_color_mapper.dart';
import 'package:Frontend/utils/reload.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// \todo document
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

/// \todo document
class _HomeViewState extends ConsumerState<HomeView> {
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

    // Recover after socket was closed server side
    ref.listenManual(
      z21ServiceProvider,
      (previous, next) {
        next.stream.listen(
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
      },
      fireImmediately: true,
    );

    // Add listener for short circuit events
    ref.listenManual(
      z21ShortCircuitProvider,
      (previous, next) {
        final connectionStatus = ref.read(connectionStatusProvider);
        final connected =
            connectionStatus.asData?.value == ConnectionStatus.connected;

        if (ModalRoute.of(context)?.isCurrent == true && connected) {
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
  Widget build(BuildContext context) {
    final smallWidth = MediaQuery.of(context).size.width < smallScreenWidth;
    final controllerRegistry = ref.watch(throttleRegistryProvider);
    final connectionStatus = ref.watch(connectionStatusProvider);
    final connected =
        connectionStatus.asData?.value == ConnectionStatus.connected;

    if (smallWidth != _smallWidth) {
      _smallWidth = smallWidth;
      _layoutKey = UniqueKey();
    }

    return Scaffold(
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < smallScreenWidth
            ? _reloadOnClickSvgPicture('data/images/icon.svg')
            : null,
        title: MediaQuery.of(context).size.width < smallScreenWidth
            ? const Text('Open|Remise')
            : _reloadOnClickSvgPicture('data/images/logos/openremise.svg'),
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
              ref.watch(darkModeProvider) ? Icons.dark_mode : Icons.light_mode,
            ),
            tooltip: ref.watch(darkModeProvider)
                ? 'Toggle light mode'
                : 'Toggle dark mode',
            onPressed: () => ref
                .read(darkModeProvider.notifier)
                .update(!ref.read(darkModeProvider)),
          ),
          Tooltip(
            message: connected ? 'Connected' : 'Disconnected',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(connected ? Icons.wifi : Icons.wifi_off),
            ),
          ),
        ],
        scrolledUnderElevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _smallWidth
            ? _smallLayout(controllerRegistry)
            : _largeLayout(controllerRegistry),
      ),
    );
  }

  /// \todo document
  Widget _smallLayout(Set<Register> controllerRegistry) {
    final register = controllerRegistry.lastOrNull;

    return Column(
      key: _layoutKey,
      children: [
        Expanded(
          child: _index == 1 && register != null
              ? _buildController(register: register)
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
  Widget _largeLayout(Set<Register> controllerRegistry) {
    return Stack(
      key: _layoutKey,
      children: [
        Row(
          children: <Widget>[
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
            const VerticalDivider(thickness: 2),
            Expanded(
              child: Center(child: _pages[_index]),
            ),
          ],
        ),
        ...controllerRegistry.map(
          (register) => switch (register.decoder.type) {
            const (Loco) => () {
                return _buildDraggable<Loco>(register: register);
              }(),
            const (Turnout) => () {
                return _buildDraggable<Turnout>(register: register);
              }(),
            _ => ErrorWidget(Exception('Invalid type'))
          },
        ),
      ],
    );
  }

  /// \todo document
  Widget _buildDraggable<T>({required Register register}) {
    void moveToTop() {
      ref.read(throttleRegistryProvider.notifier).updateItem<T>(
            register.decoder.address!,
            register.decoder.address!,
          );
    }

    return PositionedDraggable(
      key: register.key,
      onTap: moveToTop,
      onPanUpdate: (_) => moveToTop(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        width: throttleSize.width,
        height: throttleSize.height,
        child: _buildController(register: register),
      ),
    );
  }

  /// \todo document
  ///
  /// Flutters rendering pipeline which relies on keys as unique identifiers to
  /// determine which widgets down the widget tree have changed and need to be
  /// rebuilt make MDI windows rather tedious.
  Widget _buildController({required Register register}) {
    return switch (register.decoder.type) {
      const (Loco) => () {
          final loco = ref.watch(locosProvider).firstWhere(
                (l) => l.address == register.decoder.address,
              );
          return Throttle<Loco>(
            key: ValueKey(
              Object.hash(Loco, loco.address, loco.speedSteps),
            ),
            item: loco,
          );
        }(),
      const (Turnout) => () {
          final turnout = ref
              .watch(turnoutsProvider)
              .firstWhere((t) => t.address == register.decoder.address);
          return Throttle<Turnout>(
            key: ValueKey(
              Object.hash(
                Turnout,
                turnout.address,
                turnout.type,
                turnout.group,
              ),
            ),
            item: turnout,
          );
        }(),
      _ => ErrorWidget(Exception('Invalid type'))
    };
  }

  /// \todo document
  Widget _reloadOnClickSvgPicture(String assetName) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: 'Reload',
        waitDuration: const Duration(seconds: 1),
        child: GestureDetector(
          onTap: kIsWeb ? reload : () => debugPrint('reload'),
          child: SvgPicture.asset(
            assetName,
            colorMapper: DarkModeColorMapper(ref.watch(darkModeProvider)),
          ),
        ),
      ),
    );
  }
}
