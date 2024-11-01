import 'dart:async';

import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({super.key});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen> {
  late final Timer _timer;

  @override
  void initState() {
    debugPrint('InfoScreen init');
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), _heartbeat);
  }

  @override
  void dispose() {
    debugPrint('InfoScreen dispose');
    _timer.cancel();
    super.dispose();
  }

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
                    String.fromEnvironment('VERSION', defaultValue: 'debug'),
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

  void _heartbeat(_) {
    ref.read(sysProvider.notifier).fetchInfo();
  }
}
