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

import 'package:Frontend/constant/icon_size.dart';
import 'package:Frontend/constant/open_remise_icons.dart';
import 'package:Frontend/constant/small_screen_width.dart';
import 'package:Frontend/model/decoder.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/roco/z21_status.dart';
import 'package:Frontend/provider/text_scaler.dart';
import 'package:Frontend/utility/loco_address_validator.dart';
import 'package:Frontend/utility/turnout_address_validator.dart';
import 'package:Frontend/widget/dialog/bidib/decoder_detection.dart';
import 'package:Frontend/widget/power_icon_button.dart';
import 'package:Frontend/widget/program/manual.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

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

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final z21Status = ref.watch(z21StatusProvider);
    final on = z21Status.hasValue && !z21Status.requireValue.trackVoltageOff();
    final type = _selected.elementAtOrNull(0) == 0 ? Loco : Turnout;
    final serviceMode = _selected.elementAtOrNull(1) == 1;
    final address = int.tryParse(_formKey.currentState?.value['address'] ?? '');
    final decoder = Decoder(type: type, address: address);
    final smallWidth = MediaQuery.of(context).size.width < smallScreenWidth;

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
                    title: const Text('Select decoder type'),
                    content: Column(
                      children: [
                        Card.outlined(
                          child: ListTile(
                            leading: const Icon(Icons.train),
                            title: const Text('Loco'),
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
                            leading: const Icon(OpenRemiseIcons.accessory),
                            title: const Text('Accessory'),
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
                    title: const Text('Select programming mode'),
                    content: Column(
                      children: [
                        Card.outlined(
                          child: ListTile(
                            leading: const Icon(OpenRemiseIcons.pom),
                            title: FormBuilderTextField(
                              name: 'address',
                              validator: (value) => serviceMode
                                  ? null
                                  : type == Loco
                                      ? locoAddressValidator(value)
                                      : turnoutAddressValidator(value),
                              decoration: const InputDecoration(
                                labelText: 'PoM',
                                helperText: ' ',
                              ),
                              enabled: on,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontFamily: 'DSEG14'),
                              onSubmitted: (_) {
                                if (_formKey.currentState?.saveAndValidate() ??
                                    false) {
                                  ++_index;
                                  _selected
                                    ..removeRange(1, _selected.length)
                                    ..add(0);
                                }
                              },
                            ),
                            enabled: on,
                            onTap: () {
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                setState(() {
                                  ++_index;
                                  _selected
                                    ..removeRange(1, _selected.length)
                                    ..add(0);
                                });
                              }
                            },
                          ),
                        ),
                        Card.outlined(
                          child: ListTile(
                            leading: const Icon(Icons.build_circle),
                            title: const Text('Service'),
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
                    title: const Text('Select method'),
                    content: Column(
                      children: [
                        Card.outlined(
                          child: ListTile(
                            leading: const Icon(Icons.code),
                            title: const Text('Manual'),
                            onTap: () => setState(() {
                              ++_index;
                              _selected
                                ..removeRange(2, _selected.length)
                                ..add(0);
                            }),
                          ),
                        ),
                        if (kDebugMode)
                          Card.outlined(
                            child: ListTile(
                              leading: SizedBox(
                                width: iconSize.width,
                                height: iconSize.height,
                                child: SvgPicture.asset(
                                  'data/images/logos/decoder_db.svg',
                                ),
                              ),
                              title: const Text('Decoder DB'),
                              onTap: () => showDialog<List<Widget>>(
                                context: context,
                                builder: (_) => DecoderDetectionDialog(),
                                barrierDismissible: false,
                              ).then((value) {
                                if (value == null) return;
                                debugPrint('DecoderDB done!');
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _step(
                    title: const Text('Select CV'),
                    content: Manual(key: ValueKey(decoder), decoder: decoder),
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
                controlsBuilder: (context, details) => const SizedBox.shrink(),
                connectorColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
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
}
