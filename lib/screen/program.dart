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

import 'package:Frontend/constant/open_remise_icons.dart';
import 'package:Frontend/constant/small_screen_width.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/provider/roco/z21_status.dart';
import 'package:Frontend/provider/text_scaler.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:Frontend/utility/cv_number_validator.dart';
import 'package:Frontend/utility/cv_value_validator.dart';
import 'package:Frontend/utility/loco_address_validator.dart';
import 'package:stream_summary_builder/stream_summary_builder.dart';
import 'package:Frontend/utility/turnout_address_validator.dart';
import 'package:Frontend/widget/power_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Program screen
///
/// The program screen allows programming of CVs in service- and PoM
/// (<b>P</b>rogramming <b>o</b>n <b>M</b>ain) mode. A [stepper](https://api.flutter.dev/flutter/material/Stepper-class.html)
/// widget guides users through the process. Before a CV can be entered for
/// reading or writing, the programming mode and decoder type must be selected.
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
    final bool smallWidth =
        MediaQuery.of(context).size.width < smallScreenWidth;

    return StreamSummaryBuilder(
      initialData: <Command>[],
      fold: (summary, value) => [...summary, value],
      stream: z21.stream.where(
        (command) => switch (command) {
          LanXCvNackSc() => true,
          LanXCvNack() => true,
          LanXCvResult() => true,
          _ => false
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) _syncFromCommands(snapshot.requireData);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormBuilder(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: PowerIconButton(),
                  title: smallWidth ? null : Text('Program'),
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
                  bottom: smallWidth
                      ? null
                      : PreferredSize(
                          preferredSize: Size(double.infinity, 0),
                          child: Divider(thickness: 2),
                        ),
                  scrolledUnderElevation: 0,
                  centerTitle: true,
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
                                title: const Text('PoM'),
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
                            Card.outlined(
                              child: ListTile(
                                leading: const Icon(OpenRemiseIcons.accessory),
                                title: const Text('Accessory'),
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
                                validator: _selected.elementAtOrNull(1) == 0
                                    ? locoAddressValidator
                                    : turnoutAddressValidator,
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
  void _syncFromCommands(List<Command> commands) {
    if (!_pending || commands.isEmpty) return;

    for (final command in commands) {
      switch (command) {
        case LanXCvNackSc():
        case LanXCvNack():
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _updateIconData(Icons.error));
          _pending = false;
          break;

        case LanXCvResult(cvAddress: final cvAddress, value: final value):
          if (int.parse(_formKey.currentState?.value['CV number']) ==
              (cvAddress + 1)) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _updateIconData(Icons.check_circle),
            );
            _formKey.currentState?.fields['CV value']
                ?.didChange(value.toString());
          } else {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _updateIconData(Icons.error));
            _formKey.currentState?.fields['CV value']?.didChange(null);
          }
          _pending = false;

        default:
          break;
      }
    }
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
    setState(() => _iconData = iconData);
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

      //
      if (serviceMode) {
        z21.lanXCvRead(number - 1);
        _pending = true;
      }
      //
      else {
        final type = _selected.elementAtOrNull(1) == 0 ? Loco : Turnout;
        final address = int.parse(_formKey.currentState?.value['address']);
        switch (type) {
          case const (Loco):
            z21.lanXCvPomReadByte(address, number - 1);
            _pending = true;
            break;

          case const (Turnout):
            z21.lanXCvPomAccessoryReadByte(address, number - 1);
            _pending = true;
            break;
        }
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
      }
      //
      else {
        final type = _selected.elementAtOrNull(1) == 0 ? Loco : Turnout;
        final address = int.parse(_formKey.currentState?.value['address']);
        switch (type) {
          case const (Loco):
            z21.lanXCvPomWriteByte(address, number - 1, value);
            // Don't set pending flag for POM
            break;

          case const (Turnout):
            z21.lanXCvPomAccessoryWriteByte(address, number - 1, value);
            // Don't set pending flag for POM
            break;
        }
      }
    }
  }
}
