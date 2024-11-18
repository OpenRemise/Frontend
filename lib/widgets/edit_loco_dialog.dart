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

import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/dcc.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditLocoDialog extends ConsumerStatefulWidget {
  final int? _index;

  const EditLocoDialog(int? index, {super.key}) : _index = index;

  @override
  ConsumerState<EditLocoDialog> createState() => _EditLocoDialogState();
}

class _EditLocoDialogState extends ConsumerState<EditLocoDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final locos = ref.watch(locosProvider);
    final loco = widget._index != null ? locos[widget._index!] : null;

    return AlertDialog(
      title: loco == null ? const Text('Add loco') : const Text('Edit loco'),
      content: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'name',
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              initialValue: loco?.name,
              decoration: const InputDecoration(
                icon: Icon(Icons.title_outlined),
                labelText: 'Name',
                helperText: ' ',
              ),
            ),
            FormBuilderTextField(
              name: 'address',
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                final address = int.tryParse(value);
                // Address can be 1-10239
                if (address == null || address < 1 || address > 10239) {
                  return 'Address invalid';
                }
                // Only allow new address if it's not already in use
                else if (loco?.address != address &&
                    locos.indexWhere((l) => l.address == address) >= 0) {
                  return 'Address already in use"';
                }
                return null;
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.alternate_email_outlined),
                labelText: 'Address',
                helperText: ' ',
              ),
              valueTransformer: (value) =>
                  value != null ? int.tryParse(value) : null,
              initialValue: loco?.address.toString(),
              keyboardType: TextInputType.number,
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
              ref.read(dccProvider.notifier).updateLoco(
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
          child: const Text('Cancel'),
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
