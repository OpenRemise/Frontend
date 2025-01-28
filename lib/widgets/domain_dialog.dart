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

import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/providers/domains.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class DomainDialog extends ConsumerWidget {
  const DomainDialog({super.key});

  /// \todo document
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

/// \todo document
void showDomainDialog({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (_) => const DomainDialog(),
    barrierDismissible: false,
  );
}
