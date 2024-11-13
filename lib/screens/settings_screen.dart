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
              actions: [
                IconButton(
                  onPressed: () =>
                      ref.read(settingsProvider.notifier).fetchSettings(),
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.sync_outlined),
                ),
              ],
              floating: true,
            ),
            settings.when(
              data: (data) => SliverList.list(
                children: [
                  FormBuilderTextField(
                    name: 'sta_mdns',
                    validator: (String? value) {
                      return null;
                    },
                    initialValue: data.mdns,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.wifi_outlined),
                      labelText: 'mDNS',
                    ),
                  ),
                  FormBuilderTextField(
                    name: 'sta_ssid',
                    validator: (String? value) {
                      return null;
                    },
                    initialValue: data.ssid,
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'SSID',
                    ),
                  ),
                  FormBuilderTextField(
                    name: 'sta_pass',
                    validator: (String? value) {
                      return null;
                    },
                    initialValue: data.password,
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'Password',
                    ),
                  ),
                  const Divider(),
                  FormBuilderSlider(
                    name: 'http_rx_timeout',
                    initialValue: data.httpReceiveTimeout!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.http_outlined),
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
                    initialValue: data.httpTransmitTimeout!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'HTTP transmit timeout [s]',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 5,
                    max: 60,
                    divisions: 60 - 5,
                    displayValues: DisplayValues.current,
                  ),
                  const Divider(),
                  FormBuilderSlider(
                    name: 'usb_rx_timeout',
                    initialValue: data.usbReceiveTimeout!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.usb_outlined),
                      labelText: 'USB receive timeout [s]',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 1,
                    max: 10,
                    divisions: 10 - 1,
                    displayValues: DisplayValues.current,
                  ),
                  const Divider(),
                  FormBuilderSlider(
                    name: 'current_limit',
                    initialValue: data.currentLimit!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.power_outlined),
                      labelText: 'Current limit [A]',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 0,
                    max: 3,
                    divisions: 3 - 0,
                    displayValues: DisplayValues.current,
                    valueWidget: (value) =>
                        Text(_currentLimitValues[int.parse(value)].toString()),
                  ),
                  FormBuilderSlider(
                    name: 'current_sc_time',
                    initialValue: data.currentShortCircuitTime!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'Current short circuit time [ms]',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 20,
                    max: 240,
                    divisions: (240 - 20) ~/ 20,
                    displayValues: DisplayValues.current,
                  ),
                  const Divider(),
                  FormBuilderSlider(
                    name: 'dcc_preamble',
                    initialValue: data.dccPreamble!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.train_outlined),
                      labelText: 'DCC preamble',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 17,
                    max: 30,
                    divisions: 30 - 17,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'dcc_bit1_dur',
                    initialValue: data.dccBit1Duration!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC 1 bit duration [µs]',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 56,
                    max: 60,
                    divisions: 60 - 56,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'dcc_bit0_dur',
                    initialValue: data.dccBit0Duration!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC 0 bit duration [µs]',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 97,
                    max: 114,
                    divisions: 114 - 97,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'dcc_bidibit_dur',
                    initialValue: _dccBiDiBitDurationValues
                        .indexOf(data.dccBiDiBitDuration!)
                        .toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC BiDi bit duration [µs]',
                    ),
                    valueTransformer: (value) =>
                        _dccBiDiBitDurationValues[value!.toInt()],
                    min: 0,
                    max: 61 - 57 + 1,
                    divisions: 61 - 57 + 1,
                    displayValues: DisplayValues.current,
                    valueWidget: (value) => Text(
                      _dccBiDiBitDurationValues[int.parse(value)].toString(),
                    ),
                  ),
                  FormBuilderSlider(
                    name: 'dcc_prog_type',
                    initialValue: data.dccProgrammingType!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC programming type',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 0,
                    max: 3,
                    divisions: 3 - 0,
                    displayValues: DisplayValues.current,
                    valueWidget: (value) =>
                        Text(_dccProgrammingTypeValues[int.parse(value)]),
                  ),
                  FormBuilderSlider(
                    name: 'dcc_strtp_rs_pc',
                    initialValue: data.dccStartupResetPacketCount!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC startup reset packets',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 25,
                    max: 255,
                    divisions: (255 - 25) ~/ 5,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'dcc_cntn_rs_pc',
                    initialValue: data.dccContinueResetPacketCount!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC continue reset packets',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 3,
                    max: 64,
                    divisions: 64 - 3,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'dcc_prog_pc',
                    initialValue: data.dccProgramPacketCount!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC program packets',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 2,
                    max: 64,
                    divisions: 64 - 2,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'dcc_verify_bit1',
                    initialValue: (data.dccBitVerifyTo1! ? 1 : 0).toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC verify to bit',
                    ),
                    valueTransformer: (value) => value! == 1,
                    min: 0,
                    max: 1,
                    divisions: 1 - 0,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'dcc_ack_cur',
                    initialValue: data.dccProgrammingAckCurrent!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'DCC programming ack current [mA]',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 5,
                    max: 255,
                    divisions: (255 - 5) ~/ 5,
                    displayValues: DisplayValues.current,
                  ),
                  const Divider(),
                  FormBuilderSlider(
                    name: 'mdu_preamble',
                    initialValue: data.mduPreamble!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.update_outlined),
                      labelText: 'MDU preamble',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 14,
                    max: 30,
                    divisions: 30 - 14,
                    displayValues: DisplayValues.current,
                  ),
                  FormBuilderSlider(
                    name: 'mdu_ackreq',
                    initialValue: data.mduAckreq!.toDouble(),
                    decoration: const InputDecoration(
                      icon: Icon(null),
                      labelText: 'MDU ackreq',
                    ),
                    valueTransformer: (value) => value!.toInt(),
                    min: 10,
                    max: 30,
                    divisions: 30 - 10,
                    displayValues: DisplayValues.current,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
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
                  ),
                ],
              ),
              error: (error, stackTrace) =>
                  const SliverToBoxAdapter(child: Icon(Icons.error_outline)),
              loading: () => const SliverFillRemaining(child: Text('loading')),
            ),
          ],
        ),
      ),
    );
  }
}
