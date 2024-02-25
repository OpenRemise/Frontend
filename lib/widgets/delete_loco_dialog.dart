import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/providers/selected_loco_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteLocoDialog extends ConsumerStatefulWidget {
  final int? _index;

  const DeleteLocoDialog(int? index, {Key? key})
      : _index = index,
        super(key: key);

  @override
  ConsumerState<DeleteLocoDialog> createState() => _DeleteLocoDialogState();
}

class _DeleteLocoDialogState extends ConsumerState<DeleteLocoDialog> {
  @override
  Widget build(BuildContext context) {
    // Don't watch provider here, otherwise this widget might get rebuilt with an invalid index
    // Please be aware that this contradicts the documentation
    final locos = ref.read(locosProvider);
    final loco =
        widget._index != null ? locos.requireValue[widget._index!] : null;

    return AlertDialog(
      title: Text('Delete ${loco == null ? 'all' : '${loco.name}'}'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (loco != null) {
              ref.read(locosProvider.notifier).deleteLoco(loco.address);
            } else {
              ref.read(locosProvider.notifier).deleteLocos();
            }

            // Deselect
            if (loco == null ||
                widget._index == ref.read(selectedLocoIndexProvider)) {
              ref
                  .read(selectedLocoIndexProvider.notifier)
                  .update((state) => null);
            }

            Navigator.pop(context, true);
          },
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const LocaleText('cancel'),
        ),
      ],
    );
  }
}

void showDeleteLocoDialog({required BuildContext context, int? index}) {
  showDialog(
    context: context,
    builder: (_) => DeleteLocoDialog(index),
  );
}
