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

import 'package:Frontend/constants/open_remise_icons.dart';
import 'package:Frontend/providers/text_scaler.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:Frontend/utilities/address_validator.dart';
import 'package:Frontend/utilities/cv_number_validator.dart';
import 'package:Frontend/utilities/cv_value_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class ProgramScreen extends ConsumerStatefulWidget {
  const ProgramScreen({super.key});

  @override
  ConsumerState<ProgramScreen> createState() => _ProgramScreenState();
}

/// \todo document
class _ProgramScreenState extends ConsumerState<ProgramScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<int> _selected = [];
  int _index = 0;
  IconData _iconData = Icons.circle;
  bool _pending = false;

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);
    final serviceMode = _selected.elementAtOrNull(0) == 1;

    // https://github.com/flutter/flutter/issues/112197
    return StreamBuilder(
      stream: z21.stream.where(
        (command) => switch (command) {
          LanXCvNackSc() => true,
          LanXCvNack() => true,
          LanXStatusChanged() => true,
          LanXCvResult() => true,
          _ => false
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && _pending) {
          switch (snapshot.requireData) {
            case LanXCvNackSc():
            case LanXCvNack():
              _updateIconData(Icons.error);
              _pending = false;
            case LanXCvResult(cvAddress: final cvAddress, value: final value):
              if (int.parse(_formKey.currentState?.value['CV number']) ==
                  (cvAddress + 1)) {
                _updateIconData(Icons.check_circle);
                _formKey.currentState?.fields['CV value']
                    ?.didChange(value.toString());
              } else {
                _updateIconData(Icons.error);
                _formKey.currentState?.fields['CV value']?.didChange(null);
              }
              _pending = false;
            default:
          }
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormBuilder(
            key: _formKey,
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
                    selectedIcon: const Icon(Icons.power_off),
                    icon: const Icon(Icons.power),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => setState(() {
                        _index = 0;
                        _selected.clear();
                      }),
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                  scrolledUnderElevation: 0,
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: Stepper(
                    steps: <Step>[
                      _step(
                        title: const Text('Select programming mode'),
                        content: Column(
                          children: [
                            Card.outlined(
                              child: ListTile(
                                leading: const Icon(OpenRemiseIcons.pom),
                                title: const Text('POM'),
                                enabled: z21Status.hasValue &&
                                    !z21Status.requireValue.trackVoltageOff(),
                                onTap: () => setState(() {
                                  ++_index;
                                  _selected
                                    ..removeRange(0, _selected.length)
                                    ..add(0);
                                }),
                              ),
                            ),
                            Card.outlined(
                              child: ListTile(
                                leading: const Icon(Icons.build_circle),
                                title: const Text('Service'),
                                onTap: () => setState(() {
                                  ++_index;
                                  _selected
                                    ..removeRange(0, _selected.length)
                                    ..add(1);
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _step(
                        title: const Text('Select decoder type'),
                        content: Column(
                          children: [
                            Card.outlined(
                              child: ListTile(
                                leading: const Icon(Icons.train),
                                title: const Text('Loco'),
                                enabled: serviceMode ||
                                    z21Status.hasValue &&
                                        !z21Status.requireValue
                                            .trackVoltageOff(),
                                onTap: () => setState(() {
                                  ++_index;
                                  _selected
                                    ..removeRange(1, _selected.length)
                                    ..add(0);
                                }),
                              ),
                            ),
                            if (kDebugMode)
                              Card.outlined(
                                child: ListTile(
                                  leading:
                                      const Icon(OpenRemiseIcons.accessory),
                                  title: const Text('Accessory'),
                                  enabled: false,
                                  onTap: () => setState(() {
                                    ++_index;
                                    _selected
                                      ..removeRange(1, _selected.length)
                                      ..add(1);
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                      _step(
                        title: const Text('Select CV'),
                        content: ListView(
                          primary: false,
                          shrinkWrap: true,
                          children: [
                            if (!serviceMode)
                              FormBuilderTextField(
                                name: 'address',
                                validator: addressValidator,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.alternate_email),
                                  labelText: 'Address',
                                ),
                                enabled: serviceMode ||
                                    z21Status.hasValue &&
                                        !z21Status.requireValue
                                            .trackVoltageOff(),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontFamily: 'DSEG14'),
                              ),
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
                                    enabled: serviceMode ||
                                        z21Status.hasValue &&
                                            !z21Status.requireValue
                                                .trackVoltageOff(),
                                    keyboardType: TextInputType.number,
                                    style:
                                        const TextStyle(fontFamily: 'DSEG14'),
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
                                    enabled: serviceMode ||
                                        z21Status.hasValue &&
                                            !z21Status.requireValue
                                                .trackVoltageOff(),
                                    keyboardType: TextInputType.number,
                                    style:
                                        const TextStyle(fontFamily: 'DSEG14'),
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
                                  OutlinedButton(
                                    onPressed: _cvRead,
                                    child: const Text('Read'),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                  ),
                                  OutlinedButton(
                                    onPressed: _cvWrite,
                                    child: const Text('Write'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    physics: const NeverScrollableScrollPhysics(),
                    currentStep: _index,
                    onStepTapped: (int index) {
                      // Only allow going backwards
                      if (index <= _index) {
                        setState(() {
                          _index = index;
                        });
                      }
                    },
                    controlsBuilder: (context, details) =>
                        const SizedBox.shrink(),
                    connectorColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// \todo document
  Step _step({
    required Widget title,
    Widget? subtitle,
    required Widget content,
  }) {
    return Step(
      title: title,
      subtitle: subtitle,
      content: content,
      stepStyle: StepStyle(
        color: Theme.of(context).colorScheme.primary,
        indexStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 14 / ref.watch(textScalerProvider),
        ),
      ),
    );
  }

  /// \todo document
  void _updateIconData(IconData iconData) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() => _iconData = iconData));
  }

  /// \todo document
  void _cvRead() {
    final z21 = ref.watch(z21ServiceProvider);
    final serviceMode = _selected.elementAtOrNull(0) == 1;

    // Address validator or service mode
    if ((_formKey.currentState?.fields['address']?.validate() ?? serviceMode) &&
        (_formKey.currentState?.fields['CV number']?.validate() ?? false)) {
      _formKey.currentState?.save();
      final number = int.parse(_formKey.currentState?.value['CV number']);
      _updateIconData(Icons.pending);

      if (serviceMode) {
        z21.lanXCvRead(number - 1);
        _pending = true;
      } else {
        final address = int.parse(_formKey.currentState?.value['address']);
        z21.lanXCvPomReadByte(address, number - 1);
        _pending = true;
      }
    }
  }

  /// \todo document
  void _cvWrite() {
    final z21 = ref.watch(z21ServiceProvider);
    final serviceMode = _selected.elementAtOrNull(0) == 1;

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final number = int.parse(_formKey.currentState?.value['CV number']);
      final value = int.parse(_formKey.currentState?.value['CV value']);
      _updateIconData(serviceMode ? Icons.pending : Icons.check_circle);

      if (serviceMode) {
        z21.lanXCvWrite(number - 1, value);
        _pending = true;
      } else {
        final address = int.parse(_formKey.currentState?.value['address']);
        z21.lanXCvPomWriteByte(address, number - 1, value);
        // Don't set pending flag for POM
      }
    }
  }
}
