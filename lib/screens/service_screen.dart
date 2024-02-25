import 'dart:async';

import 'package:Frontend/models/info.dart';
import 'package:Frontend/providers/dcc_service.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _FormBuilderFieldType = ({
  String number,
  String value,
});

class _Cv {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  IconData statusIcon = Icons.circle_outlined;
}

class ServiceScreen extends ConsumerStatefulWidget {
  const ServiceScreen({super.key});

  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends ConsumerState<ServiceScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<_Cv> _cvs = [];
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _timerCallack);
  }

  @override
  void dispose() {
    debugPrint('ServiceScreen dispose');
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sys = ref.watch(sysProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilder(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                onPressed: sys.value?.mode == 'Suspended' ||
                        sys.value?.mode == 'DCCService'
                    ? _powerAction
                    : null,
                tooltip: Locales.string(context, 'on_off'),
                isSelected: sys.value?.mode == 'DCCService',
                selectedIcon: const Icon(Icons.power_off_outlined),
                icon: const Icon(Icons.power_outlined),
              ),
              actions: [
                IconButton(
                  onPressed: _formAction,
                  tooltip: Locales.string(context, 'save'),
                  icon: const Icon(Icons.save_outlined),
                ),
                IconButton(
                  onPressed: _clearAction,
                  tooltip: Locales.string(context, 'clear'),
                  icon: const Icon(Icons.clear_outlined),
                ),
              ],
              floating: true,
              snap: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _cvs.length) {
                    _cvs.add(_Cv());
                  }
                  return _tile(index);
                },
                addAutomaticKeepAlives: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(int index) {
    return FormBuilderField<_FormBuilderFieldType>(
      name: '$index',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) {
        // If number is not empty
        if (_cvs[index].numberController.text.isNotEmpty) {
          // It must be a valid integer
          if (int.tryParse(_cvs[index].numberController.text) == null) {
            return 'Number invalid';
          }
          // And unique
          final equalCount = _cvs
              .where(
                (e) =>
                    e.numberController.text ==
                    _cvs[index].numberController.text,
              )
              .length;
          final lastIndex = _cvs.lastIndexWhere(
            (cv) =>
                cv.numberController.text == _cvs[index].numberController.text,
          );
          if (equalCount > 1 && index == lastIndex) return 'Number not unique';
        }

        // If value is not empty
        if (_cvs[index].valueController.text.isNotEmpty) {
          final value = int.tryParse(_cvs[index].valueController.text);
          // It must be a valid integer
          if (value == null) return 'Value invalid';
          // Between 0 and 255
          if (value < 0 || value > 255) return 'Value out of range';
          // And if value is set, number must be as well
          if (_cvs[index].numberController.text.isEmpty) {
            return 'Number required';
          }
        }

        return null;
      },
      builder: (FormFieldState field) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.tag),
            title: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: _cvs[index].numberController,
                    decoration: InputDecoration(
                      hintText: index == 0
                          ? Locales.string(context, 'cv_number')
                          : null,
                      border: const OutlineInputBorder(),
                      errorText: field.hasError
                          ? field.errorText!.toLowerCase().contains('number')
                              ? field.errorText
                              : ''
                          : null,
                    ),
                    onChanged: (number) {
                      field.didChange(
                        (
                          number: number,
                          value: _cvs[index].valueController.text
                        ),
                      );
                      // Put CV in pending or idle state
                      setState(
                        () => _cvs[index].statusIcon =
                            _cvs[index].numberController.text.isNotEmpty ||
                                    _cvs[index].valueController.text.isNotEmpty
                                ? Icons.pending_outlined
                                : Icons.circle_outlined,
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    right: 8.0,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: _cvs[index].valueController,
                    decoration: InputDecoration(
                      hintText: index == 0
                          ? Locales.string(context, 'cv_value')
                          : null,
                      border: const OutlineInputBorder(),
                      errorText: field.hasError
                          ? field.errorText!.toLowerCase().contains('value')
                              ? field.errorText
                              : ''
                          : null,
                    ),
                    onChanged: (value) {
                      field.didChange(
                        (
                          number: _cvs[index].numberController.text,
                          value: value
                        ),
                      );
                      // Put CV in pending or idle state
                      setState(
                        () => _cvs[index].statusIcon =
                            _cvs[index].numberController.text.isNotEmpty ||
                                    _cvs[index].valueController.text.isNotEmpty
                                ? Icons.pending_outlined
                                : Icons.circle_outlined,
                      );
                    },
                  ),
                ),
              ],
            ),
            trailing: Tooltip(
              message: _tooltipMessage(index),
              child: Icon(_cvs[index].statusIcon),
            ),
          ),
        );
      },
      onChanged: (_FormBuilderFieldType? r) {
        if (r == null) return;

        // Only update CV if it's not pending
        final bool updateCv = _cvs[index].statusIcon != Icons.pending_outlined;
        if (!updateCv) return;

        final String newNumber = r.number;
        final String newValue = r.value;

        setState(() {
          // Error
          if (newValue == 'null') {
            _cvs[index].statusIcon = Icons.error_outline;
          }
          // Success
          else {
            _cvs[index].statusIcon = Icons.check_circle_outline;
            _cvs[index].numberController.text = newNumber;
            _cvs[index].valueController.text = newValue;
          }
        });
      },
    );
  }

  void _powerAction() async {
    final sys = ref.watch(sysProvider);
    await ref.read(sysProvider.notifier).updateInfo(
          Info(
            mode: sys.requireValue.mode == 'Suspended'
                ? 'DCCService'
                : 'Suspended',
          ),
        );
  }

  void _formAction() {
    final bool? valid = _formKey.currentState?.saveAndValidate();
    if (valid == null || !valid) {
      debugPrint('validation failed');
      return;
    }

    // Put all CVs we're touching in 'scheduled' state
    setState(() {
      for (final cv in _cvs) {
        if (cv.numberController.text.isNotEmpty) {
          cv.statusIcon = Icons.schedule_outlined;
        }
      }
    });

    // Prepare data for request
    Map<String, int?> updateCvs = {};
    _formKey.currentState!.value.forEach((i, r) {
      if (r == null) return;
      final String number = r.number;
      final int? value = int.tryParse(r.value);
      if (number.isNotEmpty) updateCvs[number] = value;
    });
    debugPrint('Request $updateCvs');
    ref.read(dccServiceProvider).updateCVs(updateCvs);
  }

  void _clearAction() {
    setState(() {
      for (final cv in _cvs) {
        cv.numberController.clear();
        cv.valueController.clear();
        cv.statusIcon = Icons.circle_outlined;
        _formKey.currentState?.reset();
      }
    });
  }

  String _tooltipMessage(int index) {
    switch (_cvs[index].statusIcon) {
      case Icons.pending_outlined:
        return 'Pending';
      case Icons.schedule_outlined:
        return 'Scheduled';
      case Icons.error_outline:
        return 'Error';
      case Icons.check_circle_outline:
        return 'Success';
      default:
        return '';
    }
  }

  void _timerCallack(_) {
    // Fetch CVs
    ref
        .read(dccServiceProvider)
        .fetchCVs()
        .then((Map<String, int?> fetchedCvs) {
      if (_formKey.currentState == null) return;

      // Iterate over form fields
      _formKey.currentState!.fields.forEach((String key, state) {
        // State isn't initialized and might be empty
        if (state.value == null) return;

        // CV number of the current form field
        final String number = state.value.number;

        // Find index of that CV
        final int index =
            _cvs.indexWhere((cv) => cv.numberController.text == number);
        if (index == -1) return;

        // Only update CV if it's not pending
        final bool updateCv = _cvs[index].statusIcon != Icons.pending_outlined;
        if (!updateCv) return;

        // Finally, update CV
        if (fetchedCvs.containsKey(number)) {
          _formKey.currentState?.fields[key]?.didChange(
            (number: number, value: fetchedCvs[number].toString()),
          );
        }
      });
    });
  }
}
