import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditLocoDialog extends ConsumerStatefulWidget {
  final int? _index;

  const EditLocoDialog(int? index, {Key? key})
      : _index = index,
        super(key: key);

  @override
  ConsumerState<EditLocoDialog> createState() => _EditLocoDialogState();
}

class _EditLocoDialogState extends ConsumerState<EditLocoDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final locos = ref.watch(locosProvider);
    final loco =
        widget._index != null ? locos.requireValue[widget._index!] : null;

    return AlertDialog(
      title: loco == null
          ? const LocaleText('add_loco')
          : const LocaleText('edit_loco'),
      content: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'name',
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return Locales.string(context, 'name_missing');
                }
                return null;
              },
              initialValue: loco?.name,
              decoration: const InputDecoration(
                icon: Icon(Icons.title_outlined),
                labelText: 'Name',
              ),
            ),
            FormBuilderTextField(
              name: 'address',
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return Locales.string(context, 'address_missing');
                }
                final address = int.tryParse(value);
                // Address can be 1-10239
                if (address == null || address < 1 || address > 10239) {
                  return Locales.string(context, 'address_invalid');
                }
                // Only allow new address if it's not already in use
                else if (loco?.address != address &&
                    locos.requireValue
                            .indexWhere((l) => l.address == address) >=
                        0) {
                  return Locales.string(context, 'address_already_in_use');
                }
                return null;
              },
              initialValue: loco?.address.toString(),
              decoration: InputDecoration(
                icon: const Icon(Icons.alternate_email_outlined),
                labelText: Locales.string(context, 'address'),
              ),
              valueTransformer: (value) =>
                  value != null ? int.tryParse(value) : null,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              debugPrint(_formKey.currentState?.value.toString());
              final map = _formKey.currentState!.value;
              ref.read(locosProvider.notifier).updateLoco(
                    loco?.address ?? map['address'],
                    Loco(address: map['address'], name: map['name']),
                  );
              Navigator.pop(context);
            } else {
              debugPrint(_formKey.currentState?.value.toString());
              debugPrint('validation failed');
            }
          },
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const LocaleText('cancel'),
        ),
      ],
    );
  }
}

void showEditLocoDialog({required BuildContext context, int? index}) {
  showDialog(
    context: context,
    builder: (_) => EditLocoDialog(index),
  );
}
