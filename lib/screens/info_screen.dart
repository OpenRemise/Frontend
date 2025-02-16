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

import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif/gif.dart';

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
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), _heartbeat);
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
    final domain = ref.watch(domainProvider);
    final sys = ref.watch(sysProvider);
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
              tooltip: z21Status.hasValue &&
                      !z21Status.requireValue.trackVoltageOff()
                  ? 'Power off'
                  : 'Power on',
              isSelected: z21Status.hasValue &&
                  !z21Status.requireValue.trackVoltageOff(),
              selectedIcon: const Icon(Icons.power_off_outlined),
              icon: const Icon(Icons.power_outlined),
            ),
            actions: [
              IconButton(
                onPressed: () => ref.read(sysProvider.notifier).fetchInfo(),
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
            floating: true,
          ),
          ...sys.when(
            data: (data) => [
              SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 10),
                children: [
                  const Text('Version'),
                  Text(data.version),
                  const Text('IDF version'),
                  Text(data.idfVersion),
                  const Text('Frontend version'),
                  const Text(
                    String.fromEnvironment(
                      'OPENREMISE_FRONTEND_VERSION',
                      defaultValue: 'kDebugMode',
                    ),
                  ),
                  const Text('State'),
                  Text(data.state),
                  const Text('Heap memory'),
                  Text('${data.heap}'),
                  const Text('Internal heap memory'),
                  Text('${data.internalHeap}'),
                ],
              ),
              const SliverToBoxAdapter(
                child: Divider(),
              ),
              SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 10),
                children: [
                  const Text('mDNS'),
                  Text(domain),
                  const Text('IP'),
                  Text(data.ip),
                  const Text('MAC'),
                  Text(data.mac),
                ],
              ),
              const SliverToBoxAdapter(
                child: Divider(),
              ),
              SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 10),
                children: [
                  const Text('Voltage'),
                  Text(
                    '${(data.voltage / 1000).toStringAsFixed(2)}V',
                  ),
                  const Text('Current'),
                  Text(
                    '${(data.current / 1000).toStringAsFixed(2)}A',
                  ),
                  const Text('Temperature'),
                  Text(
                    '${data.temperature.toStringAsFixed(0)}°C',
                  ),
                ],
              ),
            ],
            error: (error, stackTrace) => [
              SliverFillRemaining(
                child: Center(
                  child: Gif(
                    image: const AssetImage('data/images/error.gif'),
                    autostart: Autostart.loop,
                    width: 200,
                  ),
                ),
              ),
            ],
            loading: () => [
              SliverFillRemaining(
                child: Center(
                  child: Gif(
                    image: const AssetImage('data/images/loading.gif'),
                    autostart: Autostart.loop,
                    width: 200,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// \todo document
  void _heartbeat(_) {
    ref.read(sysProvider.notifier).fetchInfo();
  }
}
