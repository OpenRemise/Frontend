// Copyright (C) 2026 Vincent Hamp
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

import 'package:Frontend/model/decoder.dart';
import 'package:Frontend/provider/roco/z21_cv.dart';
import 'package:Frontend/provider/roco/z21_status.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/utility/cv_number_validator.dart';
import 'package:Frontend/utility/cv_value_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class Manual extends ConsumerStatefulWidget {
  final Decoder decoder;

  const Manual({super.key, required this.decoder});

  @override
  ConsumerState<Manual> createState() => _ManualState();
}

/// \todo document
class _ManualState extends ConsumerState<Manual> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final ProviderSubscription _sub;
  IconData _iconData = Icons.circle;

  @override
  void initState() {
    super.initState();
    _sub = ref.listenManual<CvMap>(
      z21CvProvider(widget.decoder),
      (_, next) {
        final number = int.tryParse(_formKey.currentState?.value['CV number']);
        if (number == null || !next.containsKey((number - 1, 0, 1))) return;
        switch (next[(number - 1, 0, 1)]) {
          case null:
            setState(() => _iconData = Icons.pending);
            break;

          case LanXCvNackSc():
          case LanXCvNack():
            setState(() => _iconData = Icons.error);
            break;

          case LanXCvResult(cvAddress: final cvAddress, value: final value):
            if (number - 1 == cvAddress) {
              _formKey.currentState?.patchValue({'CV value': value.toString()});
              setState(() => _iconData = Icons.check_circle);
            }
            break;

          default:
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z21Status = ref.watch(z21StatusProvider);
    final serviceMode = widget.decoder.address == null;
    final on = z21Status.hasValue && !z21Status.requireValue.trackVoltageOff();
    final enabled = serviceMode || on;

    return FormBuilder(
      key: _formKey,
      child: ListView(
        primary: false,
        shrinkWrap: true,
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                child: FormBuilderTextField(
                  name: 'CV number',
                  validator: cvNumberValidator,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                    labelText: 'CV number',
                    // https://github.com/flutter/flutter/issues/15400
                    helperText: ' ',
                  ),
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'DSEG14'),
                ),
              ),
              Flexible(
                flex: 1,
                child: FormBuilderTextField(
                  name: 'CV value',
                  validator: cvValueValidator,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.onetwothree),
                    labelText: 'CV value',
                    helperText: ' ',
                  ),
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'DSEG14'),
                ),
              ),
              Icon(_iconData),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: enabled ? _read : null,
                  icon: const Icon(Icons.upload),
                  label: const Text('Read'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                OutlinedButton.icon(
                  onPressed: enabled ? _write : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Write'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// \todo document
  void _read() {
    // Clear value and error
    setState(() => _iconData = Icons.circle);
    _formKey.currentState?.fields['CV value']?.reset();

    //
    if (_formKey.currentState?.fields['CV number']?.validate() ?? false) {
      _formKey.currentState?.save();
      final number = int.parse(_formKey.currentState?.value['CV number']);
      ref.read(z21CvProvider(widget.decoder).notifier).read(number - 1);
    }
  }

  /// \todo document
  void _write() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final number = int.parse(_formKey.currentState?.value['CV number']);
      final value = int.parse(_formKey.currentState?.value['CV value']);
      ref.read(z21CvProvider(widget.decoder).notifier).write(number - 1, value);
    }
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
