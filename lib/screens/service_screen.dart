import 'package:Frontend/providers/service_mode.dart';
import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/providers/z21_status.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _Cv = ({
  String? number,
  String? value,
});

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
          debugPrint('${snapshot.data!}');
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
                        ? (z21Status.requireValue.centralState & 0x02 == 0x02
                            ? z21.lanXSetTrackPowerOn
                            : z21.lanXSetTrackPowerOff)
                        : null,
                    tooltip: 'On/off',
                    isSelected: z21Status.hasValue &&
                        z21Status.requireValue.centralState & 0x02 == 0x00,
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
                    validator: (String? value) {
                      if (serviceMode) return null;
                      if (value == null) return 'Address invalid';
                      final number = int.tryParse(value);
                      if (number == null) {
                        return 'Address invalid';
                      } else if (number > 9999) {
                        return 'Address out of range';
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.alternate_email_outlined),
                      labelText: 'Address',
                    ),
                    enabled: !serviceMode,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FormBuilderField<_Cv>(
                    name: 'cv',
                    initialValue: (number: null, value: null),
                    validator: (_Cv? cv) {
                      if (cv!.number == null) return 'Number invalid';
                      final number = int.tryParse(cv.number!);
                      if (number == null) return 'Number invalid';
                      if (number < 1 || number > 1024) {
                        return 'Number out of range';
                      }
                      if (cv.value == null || cv.value!.isEmpty) return null;
                      final value = int.tryParse(cv.value!);
                      if (value == null) return 'Value invalid';
                      if (value > 255) return 'Value out of range';
                      return null;
                    },
                    builder: (FormFieldState<_Cv> cv) {
                      return Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextField(
                              decoration: InputDecoration(
                                icon: const Icon(Icons.numbers_outlined),
                                labelText: 'CV number',
                                errorText: cv.hasError
                                    ? cv.errorText!
                                            .toLowerCase()
                                            .contains('number')
                                        ? cv.errorText
                                        : ''
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (number) => cv.didChange(
                                (number: number, value: cv.value?.value),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: TextField(
                              decoration: InputDecoration(
                                icon: const Icon(Icons.onetwothree_outlined),
                                labelText: 'CV value',
                                errorText: cv.hasError
                                    ? cv.errorText!
                                            .toLowerCase()
                                            .contains('value')
                                        ? cv.errorText
                                        : ''
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => cv.didChange(
                                (number: cv.value?.number, value: value),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final number = int.parse(
                                _formKey.currentState?.value['cv'].number,
                              );
                              z21.lanXCvRead(number - 1);
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
                                _formKey.currentState?.value['cv'].number,
                              );
                              final value = int.parse(
                                _formKey.currentState?.value['cv'].value,
                              );
                              z21.lanXCvWrite(number - 1, value);
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
