import 'package:Frontend/models/setting.dart';
import 'package:Frontend/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      data: (data) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormBuilder(
            key: _formKey,
            child: ListView(
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
                  decoration: InputDecoration(
                    icon: const Icon(null),
                    labelText: Locales.string(context, 'password'),
                  ),
                ),
                const Divider(),
                FormBuilderSlider(
                  name: 'http_rx_timeout',
                  initialValue: data.httpReceiveTimeout!.toDouble(),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.http_outlined),
                    labelText: Locales.string(context, 'http_receive_timeout'),
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
                  decoration: InputDecoration(
                    icon: const Icon(null),
                    labelText: Locales.string(context, 'http_transmit_timeout'),
                  ),
                  valueTransformer: (value) => value!.toInt(),
                  min: 5,
                  max: 60,
                  divisions: 60 - 5,
                  displayValues: DisplayValues.current,
                ),
                const Divider(),
                FormBuilderSlider(
                  name: 'dcc_preamble',
                  initialValue: data.dccPreambleCount!.toDouble(),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.train_outlined),
                    labelText: Locales.string(context, 'dcc_preamble'),
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
                  decoration: InputDecoration(
                    icon: const Icon(null),
                    labelText:
                        '${Locales.string(context, 'dcc_bit1_dur')} [µs]',
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
                  decoration: InputDecoration(
                    icon: const Icon(null),
                    labelText:
                        '${Locales.string(context, 'dcc_bit0_dur')} [µs]',
                  ),
                  valueTransformer: (value) => value!.toInt(),
                  min: 97,
                  max: 114,
                  divisions: 114 - 97,
                  displayValues: DisplayValues.current,
                ),
                FormBuilderSlider(
                  name: 'dcc_bidibit_dur',
                  initialValue: data.dccBiDiBitDuration!.toDouble(),
                  decoration: InputDecoration(
                    icon: const Icon(null),
                    labelText:
                        '${Locales.string(context, 'dcc_bidibit_dur')} [µs]',
                  ),
                  valueTransformer: (value) => value!.toInt(),
                  min: 57,
                  max: 61,
                  divisions: 61 - 57,
                  displayValues: DisplayValues.current,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
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
                              .updateSettings(Setting.fromJson(map));
                        }
                      },
                      child: const Text('OK'),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState == null) return;
                        _formKey.currentState!.reset();
                      },
                      child: const LocaleText('cancel'),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return const Text('error');
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/loading.gif'),
            const Text('loading...'),
          ],
        ),
      ),
    );
  }
}
