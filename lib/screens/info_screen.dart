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

import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({super.key});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

/// \todo document
class _InfoScreenState extends ConsumerState<InfoScreen> {
  late final Timer _timer;

  /// \todo document
  @override
  void initState() {
    debugPrint('InfoScreen init');
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), _heartbeat);
  }

  /// \todo document
  @override
  void dispose() {
    debugPrint('InfoScreen dispose');
    _timer.cancel();
    super.dispose();
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final domain = ref.watch(domainProvider);
    final sys = ref.watch(sysProvider);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    return sys.when(
      data: (data) {
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
                    onPressed: () => ref.read(sysProvider.notifier).fetchInfo(),
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.sync_outlined),
                  ),
                ],
                floating: true,
              ),
              SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 10),
                children: [
                  const Text('Version'),
                  Text(sys.requireValue.version),
                  const Text('IDF version'),
                  Text(sys.requireValue.idfVersion),
                  const Text('Frontend version'),
                  const Text(
                    String.fromEnvironment(
                      'OPENREMISE_FRONTEND_VERSION',
                      defaultValue: 'kDebugMode',
                    ),
                  ),
                  const Text('State'),
                  Text(sys.requireValue.state),
                  const Text('Heap memory'),
                  Text('${sys.requireValue.heap}'),
                  const Text('Internal heap memory'),
                  Text('${sys.requireValue.internalHeap}'),
                ],
              ),
              SliverList.list(
                children: const [
                  Divider(),
                ],
              ),
              SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 10),
                children: [
                  const Text('mDNS'),
                  Text(domain),
                  const Text('IP'),
                  Text(sys.requireValue.ip),
                  const Text('MAC'),
                  Text(sys.requireValue.mac),
                ],
              ),
              SliverList.list(
                children: const [
                  Divider(),
                ],
              ),
              SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 10),
                children: [
                  const Text('Voltage'),
                  Text(
                    '${(sys.requireValue.voltage / 1000).toStringAsFixed(2)}V',
                  ),
                  const Text('Current'),
                  Text(
                    '${(sys.requireValue.current / 1000).toStringAsFixed(2)}A',
                  ),
                  const Text('Temperature'),
                  Text(
                    '${sys.requireValue.temperature.toStringAsFixed(0)}°C',
                  ),
                ],
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) =>
          const Center(child: Icon(Icons.error_outline)),
      loading: () => const Center(child: Text('loading')),
    );
  }

  /// \todo document
  void _heartbeat(_) {
    ref.read(sysProvider.notifier).fetchInfo();
  }
}
