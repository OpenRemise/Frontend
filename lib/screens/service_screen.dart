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

import 'package:Frontend/providers/service_mode.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:Frontend/utilities/address_validator.dart';
import 'package:Frontend/utilities/cv_number_validator.dart';
import 'package:Frontend/utilities/cv_value_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  const ServiceScreen({super.key});

  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends ConsumerState<ServiceScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final serviceMode = ref.watch(serviceModeProvider);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    return StreamBuilder(
      stream: z21.stream.where(
        (command) => switch (command) {
          LanXCvNackSc() || LanXCvNack() || LanXCvResult() => true,
          _ => false
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.requireData) {
            case LanXCvNackSc():
              // TODO some error here?
              debugPrint('LanXCvNackSc');
            case LanXCvNack():
              // TODO some error here?
              debugPrint('LanXCvNackSc');
            case LanXCvResult(cvAddress: final cvAddress, value: final value):
              if (int.parse(_formKey.currentState?.value['CV number']) ==
                  (cvAddress + 1)) {
                _formKey.currentState?.fields['CV value']
                    ?.didChange(value.toString());
              } else {
                _formKey.currentState?.fields['CV value']?.didChange(null);
              }
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
                    tooltip: 'On/off',
                    isSelected: z21Status.hasValue &&
                        !z21Status.requireValue.trackVoltageOff(),
                    selectedIcon: const Icon(Icons.power_off_outlined),
                    icon: const Icon(Icons.power_outlined),
                  ),
                  title: IconButton(
                    onPressed: () => ref
                        .read(serviceModeProvider.notifier)
                        .update(!serviceMode),
                    tooltip: 'Service mode',
                    isSelected: serviceMode,
                    selectedIcon: const Icon(Icons.build_circle),
                    icon: const Icon(Icons.build_circle_outlined),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      tooltip: 'Load local JMRI',
                      icon: const Icon(Icons.file_open_outlined),
                    ),
                  ],
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: FormBuilderTextField(
                    name: 'address',
                    validator: serviceMode ? null : addressValidator,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.alternate_email_outlined),
                      labelText: 'Address',
                    ),
                    enabled: !serviceMode,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: FormBuilderTextField(
                          name: 'CV number',
                          validator: cvNumberValidator,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.numbers_outlined),
                            labelText: 'CV number',
                            // https://github.com/flutter/flutter/issues/15400
                            helperText: ' ',
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: FormBuilderTextField(
                          name: 'CV value',
                          validator: cvValueValidator,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.onetwothree_outlined),
                            labelText: 'CV value',
                            helperText: ' ',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if ((_formKey.currentState?.fields['address']
                                        ?.validate() ??
                                    false) &&
                                (_formKey.currentState?.fields['CV number']
                                        ?.validate() ??
                                    false)) {
                              _formKey.currentState?.save();
                              final number = int.parse(
                                _formKey.currentState?.value['CV number'],
                              );
                              if (serviceMode) {
                                z21.lanXCvRead(number - 1);
                              } else {
                                final address = int.parse(
                                  _formKey.currentState?.value['address'],
                                );
                                z21.lanXCvPomReadByte(address, number - 1);
                              }
                            }
                          },
                          child: const Text('Read'),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final number = int.parse(
                                _formKey.currentState?.value['CV number'],
                              );
                              final value = int.parse(
                                _formKey.currentState?.value['CV value'],
                              );
                              if (serviceMode) {
                                z21.lanXCvWrite(number - 1, value);
                              } else {
                                final address = int.parse(
                                  _formKey.currentState?.value['address'],
                                );
                                z21.lanXCvPomWriteByte(
                                    address, number - 1, value);
                              }
                            }
                          },
                          child: const Text('Write'),
                        ),
                      ],
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
}
