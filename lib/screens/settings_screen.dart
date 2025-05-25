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
import 'package:Frontend/models/config.dart';
import 'package:Frontend/providers/settings.dart';
import 'package:Frontend/providers/sys.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/utilities/ip_address_validator.dart';
import 'package:Frontend/widgets/dialog/restart.dart';
import 'package:Frontend/widgets/error_gif.dart';
import 'package:Frontend/widgets/loading_gif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

/// \todo document
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const List<double> _currentLimitValues = [0.5, 1.3, 2.7, 4.1];
  static const List<int> _dccBiDiBitDurationValues = [0, 57, 58, 59, 60, 61];
  static const List<String> _dccProgrammingTypeValues = [
    'Nothing',
    'Bit only',
    'Byte only',
    'Bit and byte',
  ];
  final _formKey = GlobalKey<FormBuilderState>();

  /// \todo document
  @override
  Widget build(BuildContext context) {
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
                tooltip: z21Status.hasValue &&
                        !z21Status.requireValue.trackVoltageOff()
                    ? 'Power off'
                    : 'Power on',
                isSelected: z21Status.hasValue &&
                    !z21Status.requireValue.trackVoltageOff(),
                selectedIcon: const Icon(Icons.power_off),
                icon: const Icon(Icons.power),
              ),
              title: IconButton(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (_) => const RestartDialog(),
                  barrierDismissible: false,
                ).then(
                  (value) => value == true
                      ? ref.read(sysProvider.notifier).restart()
                      : null,
                ),
                tooltip: 'Restart',
                icon: const Icon(Icons.restart_alt),
              ),
              actions: [
                IconButton(
                  onPressed: _defaults,
                  tooltip: 'Defaults',
                  icon: const Icon(Icons.settings_suggest),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).refresh();
                    _formKey.currentState?.reset();
                  },
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                ),
              ],
              scrolledUnderElevation: 0,
              floating: true,
            ),
            settings.when(
              /// \warning
              /// All widgets must be visible to the FormBuilder all the time.Do **not** use lazy loading inside a FormBuilder.
              data: (data) => SliverToBoxAdapter(
                child: ListView(
                  primary: false,
                  shrinkWrap: true,
                  children: [
                    Tooltip(
                      message:
                          'mDNS hostname under which the device appears (e.g. my-remise.local)',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_mdns',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mDNS';
                          } else if (!value.endsWith('remise')) {
                            return "mDNS must end with 'remise'";
                          } else {
                            return null;
                          }
                        },
                        initialValue: data.stationMdns,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.wifi),
                          labelText: 'mDNS',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    Tooltip(
                      message: 'Name of the network to connect to',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_ssid',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a SSID';
                          } else if (value.length > 32) {
                            return 'SSID too long';
                          } else {
                            return null;
                          }
                        },
                        initialValue: data.stationSsid,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'SSID',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    Tooltip(
                      message: 'Password of the network to connect to',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_pass',
                        validator: (String? value) {
                          if (value == null) {
                            return 'Please enter a password';
                          } else if (value.length > 64) {
                            return 'Password too long';
                          } else {
                            return null;
                          }
                        },
                        initialValue: data.stationPassword,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'Password',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    Tooltip(
                      message: 'Name of the alternative network to connect to',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_alt_ssid',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          } else if (value.length > 32) {
                            return 'SSID too long';
                          } else {
                            return null;
                          }
                        },
                        initialValue: data.stationAlternativeSsid,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'Alternative SSID',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    Tooltip(
                      message:
                          'Password of the alternative network to connect to',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_alt_pass',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          } else if (value.length > 64) {
                            return 'Password too long';
                          } else {
                            return null;
                          }
                        },
                        initialValue: data.stationAlternativePassword,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'Alternative password',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    Tooltip(
                      message: 'IP address',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_ip',
                        validator: ipAddressValidator,
                        initialValue: data.stationIp,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'IP',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    Tooltip(
                      message: 'IP address of the access point to connect to',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_netmask',
                        validator: ipAddressValidator,
                        initialValue: data.stationNetmask,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'Netmask',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    Tooltip(
                      message: 'Range of IP addresses in the network',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderTextField(
                        name: 'sta_gateway',
                        validator: ipAddressValidator,
                        initialValue: data.stationGateway,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'Gateway',
                        ),
                        autovalidateMode: AutovalidateMode.always,
                      ),
                    ),
                    const Divider(),
                    Tooltip(
                      message:
                          'Timeout for receiving HTTP requests (also used for USB)',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'http_rx_timeout',
                        initialValue: data.httpReceiveTimeout!.toDouble(),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.http),
                          labelText: 'HTTP receive timeout [s]',
                        ),
                        valueTransformer: (value) => value!.toInt(),
                        min: 5,
                        max: 60,
                        divisions: 60 - 5,
                        displayValues: DisplayValues.current,
                      ),
                    ),
                    Tooltip(
                      message: 'Timeout for transmitting HTTP response',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
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
                    ),
                    const Divider(),
                    Tooltip(
                      message: 'Current limit in DCC operation mode',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'cur_lim',
                        initialValue: data.currentLimit!.toDouble(),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.power),
                          labelText: 'Current limit [A]',
                        ),
                        valueTransformer: (value) => value!.toInt(),
                        min: 0,
                        max: 3,
                        divisions: 3 - 0,
                        displayValues: DisplayValues.current,
                        valueWidget: (value) => Text(
                          _currentLimitValues[int.parse(value)].toString(),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Current limit in DCC service mode',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'cur_lim_serv',
                        validator: (_) => null,
                        initialValue: data.currentLimitService!.toDouble(),
                        decoration: InputDecoration(
                          icon: const Icon(null),
                          labelText: 'Current limit service mode [A]',
                          helperText: (_formKey.currentState
                                          ?.fields['cur_lim_serv']?.value ??
                                      0) >
                                  _currentLimitValues.indexOf(1.3)
                              ? '\u26A0 exceeds recommended limit'
                              : null,
                          helperStyle: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        valueTransformer: (value) => value!.toInt(),
                        min: 0,
                        max: 3,
                        divisions: 3 - 0,
                        displayValues: DisplayValues.current,
                        valueWidget: (value) => Text(
                          _currentLimitValues[int.parse(value)].toString(),
                        ),
                      ),
                    ),
                    Tooltip(
                      message:
                          'Time after which an overcurrent is considered a short circuit',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'cur_sc_time',
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
                    ),
                    const Divider(),
                    Tooltip(
                      message: 'Duty cycle for bug LED (blue)',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'led_dc_bug',
                        initialValue: data.ledDutyCycleBug!.toDouble(),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lightbulb),
                          labelText: 'LED duty cycle bug [%]',
                        ),
                        valueTransformer: (value) => value!.toInt(),
                        min: 0,
                        max: 100,
                        divisions: 100 - 0,
                        displayValues: DisplayValues.current,
                      ),
                    ),
                    Tooltip(
                      message: 'Duty cycle for WiFi LED (green)',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'led_dc_wifi',
                        initialValue: data.ledDutyCycleWiFi!.toDouble(),
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'LED duty cycle WiFi [%]',
                        ),
                        valueTransformer: (value) => value!.toInt(),
                        min: 0,
                        max: 100,
                        divisions: 100 - 0,
                        displayValues: DisplayValues.current,
                      ),
                    ),
                    const Divider(),
                    Tooltip(
                      message: 'Number of preamble bits',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'dcc_preamble',
                        initialValue: data.dccPreamble!.toDouble(),
                        decoration: const InputDecoration(
                          icon: Icon(OpenRemiseIcons.square_wave),
                          labelText: 'DCC preamble',
                        ),
                        valueTransformer: (value) => value!.toInt(),
                        min: 17,
                        max: 30,
                        divisions: 30 - 17,
                        displayValues: DisplayValues.current,
                      ),
                    ),
                    Tooltip(
                      message: 'Duration of a 1 bit',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
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
                    ),
                    Tooltip(
                      message: 'Duration of a 0 bit',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
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
                    ),
                    Tooltip(
                      message:
                          'Duration of a BiDi bit during cutout (0=BiDi off)',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
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
                          _dccBiDiBitDurationValues[int.parse(value)]
                              .toString(),
                        ),
                      ),
                    ),
                    Tooltip(
                      message:
                          'How a service mode verify is performed (bitwise, bytewise, or both)',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
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
                    ),
                    Tooltip(
                      message:
                          'Number of reset packets at the start of the service mode programming sequence',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'dcc_strtp_rs_pc',
                        initialValue:
                            data.dccStartupResetPacketCount!.toDouble(),
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
                    ),
                    Tooltip(
                      message:
                          'Number of reset packets when continuing the service mode programming sequence',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'dcc_cntn_rs_pc',
                        initialValue:
                            data.dccContinueResetPacketCount!.toDouble(),
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
                    ),
                    Tooltip(
                      message:
                          'Number of programming packets in the service mode programming sequence',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
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
                    ),
                    Tooltip(
                      message:
                          'Comparing bits to either 0 or 1 during a service mode verify',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'dcc_verify_bit1',
                        initialValue:
                            (data.dccBitVerifyTo1! ? 1 : 0).toDouble(),
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
                    ),
                    Tooltip(
                      message:
                          'Acknowledge pulse current (60mA according to S-9.2.3)',
                      waitDuration: const Duration(seconds: 1),
                      child: FormBuilderSlider(
                        name: 'dcc_ack_cur',
                        initialValue: data.dccProgrammingAckCurrent!.toDouble(),
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          labelText: 'DCC programming ack current [mA]',
                        ),
                        valueTransformer: (value) => value!.toInt(),
                        min: 10,
                        max: 250,
                        divisions: (250 - 10) ~/ 5,
                        displayValues: DisplayValues.current,
                      ),
                    ),
                    FormBuilderCheckboxGroup(
                      name: 'dcc_loco_flags',
                      initialValue: [
                        data.dccLocoFlags! & 0x80,
                        data.dccLocoFlags! & 0x40,
                        data.dccLocoFlags! & 0x20,
                      ],
                      decoration: const InputDecoration(
                        icon: Icon(null),
                        label: Row(
                          children: [Text('DCC locos '), Icon(Icons.train)],
                        ),
                      ),
                      valueTransformer: (value) => value?.fold(
                        0x02,
                        (prev, cur) => prev | cur,
                      ),
                      options: const [
                        FormBuilderFieldOption(
                          value: 0x80,
                          child: Tooltip(
                            message:
                                'Short loco addresses range from 1 to 127 (instead of 99)',
                            waitDuration: Duration(seconds: 1),
                            child: Text('Short loco addresses to 127'),
                          ),
                        ),
                        FormBuilderFieldOption(
                          value: 0x40,
                          child: Tooltip(
                            message: 'Repeat high function of locos cyclically',
                            waitDuration: Duration(seconds: 1),
                            child: Text('Repeat high loco functions (≥F13)'),
                          ),
                        ),
                        FormBuilderFieldOption(
                          value: 0x20,
                          child: Tooltip(
                            message:
                                'Set CV29 automatically if loco address changes',
                            waitDuration: Duration(seconds: 1),
                            child: Text('CV29 automatic address'),
                          ),
                        ),
                      ],
                    ),
                    if (kDebugMode)
                      FormBuilderCheckboxGroup(
                        name: 'dcc_accy_flags',
                        initialValue: [
                          data.dccAccyFlags! & 0x40,
                          data.dccAccyFlags! & 0x04,
                          data.dccAccyFlags! & 0x02,
                          data.dccAccyFlags! & 0x01,
                        ],
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          label: Row(
                            children: [
                              Text('DCC accessories '),
                              Icon(OpenRemiseIcons.accessory),
                            ],
                          ),
                        ),
                        valueTransformer: (value) => value?.fold(
                          0,
                          (prev, cur) => prev | cur,
                        ),
                        options: const [
                          FormBuilderFieldOption(
                            value: 0x40,
                            child: Tooltip(
                              message:
                                  'Invert meaning of straight/branch or green/red',
                              waitDuration: Duration(seconds: 1),
                              child: Text('Invert green/red'),
                            ),
                          ),
                          FormBuilderFieldOption(
                            value: 0x04,
                            child: Tooltip(
                              message: 'Addressing compliant with RCN-213',
                              waitDuration: Duration(seconds: 1),
                              child: Text('RCN-213 addressing'),
                            ),
                          ),
                          FormBuilderFieldOption(
                            value: 0x02,
                            child: Tooltip(
                              message:
                                  'Workaround for incompatible clients that only activate outputs',
                              waitDuration: Duration(seconds: 1),
                              child: Text(
                                'Automatically deactivate complementary output',
                              ),
                            ),
                          ),
                          FormBuilderFieldOption(
                            value: 0x01,
                            child: Tooltip(
                              message: 'Disable automatic timeout of outputs',
                              waitDuration: Duration(seconds: 1),
                              child: Text('Disable timeout'),
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              if (_formKey.currentState == null) return;
                              _formKey.currentState!.reset();
                            },
                            child: const Text('Cancel'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                // Remove sta_pass if it only contains *
                                var map = Map.of(_formKey.currentState!.value);
                                final String staPass = map['sta_pass']!;
                                if (staPass.isNotEmpty &&
                                    staPass == '*' * staPass.length) {
                                  map.remove('sta_pass');
                                }
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSettings(Config.fromJson(map));
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stackTrace) => const SliverFillRemaining(
                child: Center(child: ErrorGif()),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: LoadingGif()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// \todo document
  void _defaults() {
    _formKey.currentState?.patchValue({
      'http_rx_timeout': 5.0,
      'http_tx_timeout': 5.0,
      'cur_lim': _currentLimitValues.indexOf(4.1).toDouble(),
      'cur_lim_serv': _currentLimitValues.indexOf(1.3).toDouble(),
      'cur_sc_time': 100.0,
      'led_dc_bug': 5.0,
      'led_dc_wifi': 50.0,
      'dcc_preamble': 17.0,
      'dcc_bit1_dur': 58.0,
      'dcc_bit0_dur': 100.0,
      'dcc_bidibit_dur': _dccBiDiBitDurationValues.indexOf(60).toDouble(),
      'dcc_prog_type':
          _dccProgrammingTypeValues.indexOf('Bit and byte').toDouble(),
      'dcc_strtp_rs_pc': 25.0,
      'dcc_cntn_rs_pc': 6.0,
      'dcc_verify_bit1': 1.0,
      'dcc_prog_pc': 7.0,
      'dcc_ack_cur': 50.0,
      'dcc_loco_flags': [0x80, 0x40, 0x20],
      'dcc_accy_flags': [0x04],
    });
  }
}
