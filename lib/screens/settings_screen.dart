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

import 'package:Frontend/constants/small_screen_width.dart';
import 'package:Frontend/models/config.dart';
import 'package:Frontend/providers/settings.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  static const List<double> _currentLimitValues = [0.5, 1.6, 3, 4.1];
  static const List<int> _dccBiDiBitDurationValues = [0, 57, 58, 59, 60, 61];
  static const List<String> _dccProgrammingTypeValues = [
    'Nothing',
    'Bit only',
    'Byte only',
    'Bit and byte',
  ];
  final _formKey = GlobalKey<FormBuilderState>();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);

    final List<String> tabs = <String>['Tab 1', 'Tab 2', 'Tab 3'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilder(
        key: _formKey,
        child: DefaultTabController(
          length: tabs.length, // This is the number of tabs.
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              // These are the slivers that show up in the "outer" scroll view.
              return <Widget>[
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
                  actions: [
                    IconButton(
                      onPressed: () =>
                          ref.read(settingsProvider.notifier).fetchSettings(),
                      tooltip: 'Default',
                      icon: const Icon(Icons.manage_history_outlined),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(settingsProvider.notifier).fetchSettings(),
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.sync_outlined),
                    ),
                  ],
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        text: MediaQuery.of(context).size.width >=
                                smallScreenWidth
                            ? 'WiFi'
                            : null,
                        icon: const Icon(Icons.wifi_outlined),
                      ),
                      Tab(
                        text: MediaQuery.of(context).size.width >=
                                smallScreenWidth
                            ? 'USB'
                            : null,
                        icon: const Icon(Icons.usb_outlined),
                      ),
                      Tab(
                        text: MediaQuery.of(context).size.width >=
                                smallScreenWidth
                            ? 'Power'
                            : null,
                        icon: const Icon(Icons.power_outlined),
                      ),
                    ],
                  ),
                  floating: true,
                ),
              ];
            },
            body: settings.when(
                data: (data) => TabBarView(
                      children: [
                        Column(
                          children: [
                            FormBuilderTextField(
                              name: 'sta_mdns',
                              validator: (String? value) {
                                return null;
                              },
                              initialValue: data.mdns,
                              decoration:
                                  const InputDecoration(labelText: 'mDNS'),
                            ),
                            FormBuilderTextField(
                              name: 'sta_ssid',
                              validator: (String? value) {
                                return null;
                              },
                              initialValue: data.ssid,
                              decoration:
                                  const InputDecoration(labelText: 'SSID'),
                            ),
                            FormBuilderTextField(
                              name: 'sta_pass',
                              validator: (String? value) {
                                return null;
                              },
                              initialValue: data.password,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                            ),
                            FormBuilderSlider(
                              name: 'http_rx_timeout',
                              initialValue: data.httpReceiveTimeout!.toDouble(),
                              decoration: const InputDecoration(
                                labelText: 'HTTP receive timeout [s]',
                              ),
                              valueTransformer: (value) => value!.toInt(),
                              min: 5,
                              max: 60,
                              divisions: 60 - 5,
                              displayValues: DisplayValues.current,
                            ),
                            FormBuilderSlider(
                              name: 'http_tx_timeout',
                              initialValue:
                                  data.httpTransmitTimeout!.toDouble(),
                              decoration: const InputDecoration(
                                labelText: 'HTTP transmit timeout [s]',
                              ),
                              valueTransformer: (value) => value!.toInt(),
                              min: 5,
                              max: 60,
                              divisions: 60 - 5,
                              displayValues: DisplayValues.current,
                            ),
                            _buttons(ref),
                          ],
                        ),
                        Column(
                          children: [
                            FormBuilderSlider(
                              name: 'usb_rx_timeout',
                              initialValue: data.usbReceiveTimeout!.toDouble(),
                              decoration: const InputDecoration(
                                labelText: 'USB receive timeout [s]',
                              ),
                              valueTransformer: (value) => value!.toInt(),
                              min: 1,
                              max: 10,
                              divisions: 10 - 1,
                              displayValues: DisplayValues.current,
                            ),
                            _buttons(ref),
                          ],
                        ),
                        Column(
                          children: [
                            FormBuilderSlider(
                              name: 'current_limit',
                              initialValue: data.currentLimit!.toDouble(),
                              decoration: const InputDecoration(
                                labelText: 'Current limit [A]',
                              ),
                              valueTransformer: (value) => value!.toInt(),
                              min: 0,
                              max: 3,
                              divisions: 3 - 0,
                              displayValues: DisplayValues.current,
                              valueWidget: (value) => Text(
                                _currentLimitValues[int.parse(value)]
                                    .toString(),
                              ),
                            ),
                            FormBuilderSlider(
                              name: 'current_sc_time',
                              initialValue:
                                  data.currentShortCircuitTime!.toDouble(),
                              decoration: const InputDecoration(
                                labelText: 'Current short circuit time [ms]',
                              ),
                              valueTransformer: (value) => value!.toInt(),
                              min: 20,
                              max: 240,
                              divisions: (240 - 20) ~/ 20,
                              displayValues: DisplayValues.current,
                            ),
                            _buttons(ref),
                          ],
                        ),
                      ],
                    ),
                error: (error, stackTrace) => Placeholder(),
                loading: () => Placeholder()),
          ),
        ),
      ),
    );
  }

  Widget _buttons(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                // Remove sta_pass if it only contains *
                var map = Map.of(_formKey.currentState!.value);
                final String staPass = map['sta_pass']!;
                if (staPass == '*' * staPass.length) {
                  map.remove('sta_pass');
                }
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings(Config.fromJson(map));

                debugPrint(map.toString());
              }
            },
            child: const Text('OK'),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
          ),
          OutlinedButton(
            onPressed: () {
              if (_formKey.currentState == null) return;
              _formKey.currentState!.reset();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
