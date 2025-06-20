// Copyright (C) 2025 Vincent Hamp
// Copyright (C) 2025 Franziska Walter
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

import 'package:Frontend/constant/default_settings.dart';
import 'package:Frontend/constant/open_remise_icons.dart';
import 'package:Frontend/constant/small_screen_width.dart';
import 'package:Frontend/model/config.dart';
import 'package:Frontend/provider/settings.dart';
import 'package:Frontend/provider/z21_service.dart';
import 'package:Frontend/provider/z21_status.dart';
import 'package:Frontend/utility/ip_address_validator.dart';
import 'package:Frontend/widget/error_gif.dart';
import 'package:Frontend/widget/loading_gif.dart';
import 'package:Frontend/widget/persistent_expansion_tile.dart';
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
  final _formKey = GlobalKey<FormBuilderState>();
  final ValueNotifier<bool> _expandAllNotifier = ValueNotifier<bool>(false);

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final z21 = ref.watch(z21ServiceProvider);
    final z21Status = ref.watch(z21StatusProvider);
    final bool smallWidth =
        MediaQuery.of(context).size.width < smallScreenWidth;

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
              title: smallWidth ? null : Text('Settings'),
              actions: [
                ValueListenableBuilder<bool>(
                  valueListenable: _expandAllNotifier,
                  builder: (context, isExpanded, _) {
                    return IconButton(
                      tooltip: isExpanded ? 'Collapse all' : 'Expand all',
                      icon: Icon(
                        isExpanded ? Icons.unfold_less : Icons.unfold_more,
                      ),
                      onPressed: () => _expandAllNotifier.value = !isExpanded,
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    _formKey.currentState?.patchValue(DefaultSettings.values());
                  },
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
            settings.when(
              /// \warning
              /// All widgets must be visible to the FormBuilder all the time.Do **not** use lazy loading inside a FormBuilder.
              data: (data) => SliverToBoxAdapter(
                child: ListView(
                  primary: false,
                  shrinkWrap: true,
                  children: [
                    PersistentExpansionTile(
                      title: const Text('Network'),
                      externalController: _expandAllNotifier,
                      leading: const Icon(Icons.wifi),
                      showDividers: true,
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
                            decoration:
                                const InputDecoration(labelText: 'mDNS'),
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
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            autovalidateMode: AutovalidateMode.always,
                          ),
                        ),
                        Tooltip(
                          message:
                              'Name of the alternative network to connect to',
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
                            decoration: const InputDecoration(labelText: 'IP'),
                            autovalidateMode: AutovalidateMode.always,
                          ),
                        ),
                        Tooltip(
                          message:
                              'IP address of the access point to connect to',
                          waitDuration: const Duration(seconds: 1),
                          child: FormBuilderTextField(
                            name: 'sta_netmask',
                            validator: ipAddressValidator,
                            initialValue: data.stationNetmask,
                            decoration:
                                const InputDecoration(labelText: 'Netmask'),
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
                            decoration:
                                const InputDecoration(labelText: 'Gateway'),
                            autovalidateMode: AutovalidateMode.always,
                          ),
                        ),
                      ],
                    ),
                    PersistentExpansionTile(
                      title: const Text('Site'),
                      externalController: _expandAllNotifier,
                      leading: const Icon(Icons.http),
                      showDividers: true,
                      children: [
                        Tooltip(
                          message:
                              'Timeout for receiving HTTP requests (also used for USB)',
                          waitDuration: const Duration(seconds: 1),
                          child: FormBuilderSlider(
                            name: 'http_rx_timeout',
                            initialValue: data.httpReceiveTimeout!.toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'Receive timeout [s]',
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
                              labelText: 'Transmit timeout [s]',
                            ),
                            valueTransformer: (value) => value!.toInt(),
                            min: 5,
                            max: 60,
                            divisions: 60 - 5,
                            displayValues: DisplayValues.current,
                          ),
                        ),
                        FormBuilderCheckboxGroup(
                          name: 'http_exit_msg',
                          initialValue: [data.httpExitMessage!],
                          decoration: const InputDecoration(
                            labelText: 'Show Message on page leave',
                          ),
                          options: const [
                            FormBuilderFieldOption(
                              value: true,
                              child: Tooltip(
                                  message:
                                      'Display a query when leaving the page',
                                  waitDuration: Duration(seconds: 1),
                                  child: Text('Message on page leave')),
                            ),
                          ],
                          valueTransformer: (value) => value?.contains(true),
                        ),
                      ],
                    ),
                    PersistentExpansionTile(
                      title: const Text('Current'),
                      externalController: _expandAllNotifier,
                      leading: const Icon(Icons.power),
                      showDividers: true,
                      children: [
                        Tooltip(
                          message: 'Current limit in DCC operation mode',
                          waitDuration: const Duration(seconds: 1),
                          child: FormBuilderSlider(
                            name: 'cur_lim',
                            initialValue: data.currentLimit!.toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'Limit [A]',
                            ),
                            valueTransformer: (value) => value!.toInt(),
                            min: 0,
                            max: 3,
                            divisions: 3 - 0,
                            displayValues: DisplayValues.current,
                            valueWidget: (value) => Text(
                              DefaultSettings.currentLimit[int.parse(value)]
                                  .toString(),
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
                              labelText: 'Limit service mode [A]',
                              helperText: (_formKey.currentState
                                              ?.fields['cur_lim_serv']?.value ??
                                          0) >
                                      DefaultSettings.currentLimit.indexOf(1.3)
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
                              DefaultSettings.currentLimit[int.parse(value)]
                                  .toString(),
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Time after which an overcurrent is considered a short circuit',
                          waitDuration: const Duration(seconds: 1),
                          child: FormBuilderSlider(
                            name: 'cur_sc_time',
                            initialValue:
                                data.currentShortCircuitTime!.toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'Short circuit time [ms]',
                            ),
                            valueTransformer: (value) => value!.toInt(),
                            min: 20,
                            max: 240,
                            divisions: (240 - 20) ~/ 20,
                            displayValues: DisplayValues.current,
                          ),
                        ),
                      ],
                    ),
                    PersistentExpansionTile(
                      title: const Text('LED'),
                      externalController: _expandAllNotifier,
                      leading: const Icon(Icons.lightbulb),
                      showDividers: true,
                      children: [
                        Tooltip(
                          message: 'Duty cycle for bug LED (blue)',
                          waitDuration: const Duration(seconds: 1),
                          child: FormBuilderSlider(
                            name: 'led_dc_bug',
                            initialValue: data.ledDutyCycleBug!.toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'Duty cycle bug [%]',
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
                              labelText: 'Duty cycle WiFi [%]',
                            ),
                            valueTransformer: (value) => value!.toInt(),
                            min: 0,
                            max: 100,
                            divisions: 100 - 0,
                            displayValues: DisplayValues.current,
                          ),
                        ),
                      ],
                    ),
                    PersistentExpansionTile(
                      title: const Text('DCC'),
                      externalController: _expandAllNotifier,
                      leading: const Icon(OpenRemiseIcons.square_wave),
                      showDividers: true,
                      children: [
                        Tooltip(
                          message: 'Number of preamble bits',
                          waitDuration: const Duration(seconds: 1),
                          child: FormBuilderSlider(
                            name: 'dcc_preamble',
                            initialValue: data.dccPreamble!.toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'Preamble',
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
                              labelText: '1 bit duration [µs]',
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
                              labelText: '0 bit duration [µs]',
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
                            initialValue: DefaultSettings.dccBiDiDurations
                                .indexOf(data.dccBiDiBitDuration!)
                                .toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'BiDi bit duration [µs]',
                            ),
                            valueTransformer: (value) => DefaultSettings
                                .dccBiDiDurations[value!.toInt()],
                            min: 0,
                            max: 61 - 57 + 1,
                            divisions: 61 - 57 + 1,
                            displayValues: DisplayValues.current,
                            valueWidget: (value) => Text(
                              DefaultSettings.dccBiDiDurations[int.parse(value)]
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
                              labelText: 'Programming type',
                            ),
                            valueTransformer: (value) => value!.toInt(),
                            min: 0,
                            max: 3,
                            divisions: 3 - 0,
                            displayValues: DisplayValues.current,
                            valueWidget: (value) => Text(
                              DefaultSettings
                                  .dccProgrammingTypes[int.parse(value)],
                            ),
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
                              labelText: 'Startup reset packets',
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
                              labelText: 'Continue reset packets',
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
                            initialValue:
                                data.dccProgramPacketCount!.toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'Program packets',
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
                              labelText: 'Verify to bit',
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
                            initialValue:
                                data.dccProgrammingAckCurrent!.toDouble(),
                            decoration: const InputDecoration(
                              labelText: 'Programming ack current [mA]',
                            ),
                            valueTransformer: (value) => value!.toInt(),
                            min: 10,
                            max: 250,
                            divisions: (250 - 10) ~/ 5,
                            displayValues: DisplayValues.current,
                          ),
                        ),
                      ],
                    ),
                    PersistentExpansionTile(
                      title: const Text('Locos'),
                      externalController: _expandAllNotifier,
                      leading: const Icon(Icons.train),
                      showDividers: true,
                      children: [
                        FormBuilderCheckboxGroup(
                          name: 'dcc_loco_flags',
                          initialValue: [
                            data.dccLocoFlags! & 0x80,
                            data.dccLocoFlags! & 0x40,
                            data.dccLocoFlags! & 0x20,
                          ],
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
                                child: Text('Short addresses to 127'),
                              ),
                            ),
                            FormBuilderFieldOption(
                              value: 0x40,
                              child: Tooltip(
                                message:
                                    'Repeat high function of locos cyclically',
                                waitDuration: Duration(seconds: 1),
                                child: Text('Repeat high functions (≥F13)'),
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
                          orientation: smallWidth
                              ? OptionsOrientation.vertical
                              : OptionsOrientation.wrap,
                        ),
                      ],
                    ),
                    if (kDebugMode)
                      PersistentExpansionTile(
                        title: const Text('Accessories'),
                        externalController: _expandAllNotifier,
                        leading: const Icon(OpenRemiseIcons.accessory),
                        showDividers: true,
                        children: [
                          FormBuilderCheckboxGroup(
                            name: 'dcc_accy_flags',
                            initialValue: [
                              data.dccAccyFlags! & 0x40,
                              data.dccAccyFlags! & 0x04,
                              data.dccAccyFlags! & 0x02,
                              data.dccAccyFlags! & 0x01,
                            ],
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
                                  message:
                                      'Disable automatic timeout of outputs',
                                  waitDuration: Duration(seconds: 1),
                                  child: Text('Disable timeout'),
                                ),
                              ),
                            ],
                            orientation: smallWidth
                                ? OptionsOrientation.vertical
                                : OptionsOrientation.wrap,
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
}
