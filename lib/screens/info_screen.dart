import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({super.key});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    final sys = ref.watch(sysProvider);
    final domain = ref.watch(domainProvider);

    return sys.when(
      data: (data) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 10),
                children: [
                  const Text('Version'),
                  Text(sys.requireValue.version!),
                  const Text('IDF version'),
                  Text(sys.requireValue.idfVersion!),
                  const Text('Alpha version'),
                  const Text(
                    String.fromEnvironment('VERSION', defaultValue: 'debug'),
                  ),
                  const LocaleText('mode'),
                  Text(sys.requireValue.mode),
                  const LocaleText('heap'),
                  Text('${sys.requireValue.heap}'),
                  const LocaleText('internal_heap'),
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
                  Text(sys.requireValue.ip!),
                  const Text('MAC'),
                  Text(sys.requireValue.mac!),
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
                  const LocaleText('voltage'),
                  Text(
                    '${(sys.requireValue.voltage! / 1000).toStringAsFixed(2)}V',
                  ),
                  const LocaleText('current'),
                  Text(
                    '${(sys.requireValue.current! / 1000).toStringAsFixed(2)}A',
                  ),
                  const LocaleText('temperature'),
                  Text(
                    '${sys.requireValue.temperature!.toStringAsFixed(0)}°C',
                  ),
                ],
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const Text('Error...'),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/loading.gif'),
            const Text('loading...'),
          ],
        ),
      ),
    );
  }
}
