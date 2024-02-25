import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/domains.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DomainDialog extends ConsumerWidget {
  const DomainDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogOptions = ref.watch(domainsProvider).when(
          skipLoadingOnRefresh: false,
          data: (domains) => [
            for (final domain in domains)
              SimpleDialogOption(
                onPressed: () {
                  debugPrint('Domain set to $domain');
                  ref.read(domainProvider.notifier).update((state) => domain);
                  Navigator.pop(context);
                },
                child: Text(domain),
              ),
          ],
          error: (err, stack) => [SimpleDialogOption(child: Text('err $err'))],
          loading: () =>
              [const SimpleDialogOption(child: LinearProgressIndicator())],
        );

    final refreshButton = TextButton.icon(
      onPressed: () => ref.refresh(domainsProvider),
      icon: const Icon(Icons.sync_outlined),
      label: const Text('Refresh'),
    );

    return SimpleDialog(
      title: const Text('DNS lookup'),
      children: [
        ...dialogOptions,
        refreshButton,
      ],
    );
  }
}

void showDomainDialog({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (_) => const DomainDialog(),
    barrierDismissible: false,
  );
}
