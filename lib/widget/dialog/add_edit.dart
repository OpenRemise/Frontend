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
import 'package:Frontend/constant/turnout_map.dart';
import 'package:Frontend/model/loco.dart';
import 'package:Frontend/model/turnout.dart';
import 'package:Frontend/provider/dark_mode.dart';
import 'package:Frontend/provider/dcc.dart';
import 'package:Frontend/provider/locos.dart';
import 'package:Frontend/utility/dark_mode_color_mapper.dart';
import 'package:Frontend/utility/loco_address_validator.dart';
import 'package:Frontend/utility/name_validator.dart';
import 'package:Frontend/utility/turnout_address_validator.dart';
import 'package:Frontend/widget/default_animated_size.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Dialog to add or edit loco or turnout
///
/// AddEditDialog is used to add or edit locomotives or accessories. The class
/// is generic so the type to be edited must be passed when creating the dialog
/// (e.g. `%AddEditDialog<Loco>`). If no type is passed, a query will be made at
/// runtime. Internally, the class uses a [FormBuilder](https://pub.dev/documentation/flutter_form_builder/latest/flutter_form_builder/FormBuilder-class.html)
/// that sends a POST request via DccService upon completion and successful
/// validation.
class AddEditDialog<T> extends ConsumerStatefulWidget {
  final dynamic item;
  Loco? get loco => item as Loco?;
  Turnout? get turnout => item as Turnout?;

  const AddEditDialog({super.key, this.item});

  /// \todo document
  String tooltip() {
    return switch (T) {
      const (Loco) => item == null ? 'Add loco' : 'Edit loco',
      const (Turnout) => item == null ? 'Add accessory' : 'Edit accessory',
      _ => 'Add',
    };
  }

  @override
  ConsumerState<AddEditDialog<T>> createState() => _AddEditDialogState<T>();
}

/// \todo document
class _AddEditDialogState<T> extends ConsumerState<AddEditDialog<T>> {
  final _formKey = GlobalKey<FormBuilderState>();

  /// Which dialog should be shown: null = choice, or a type
  Type? _type = T;

  /// \todo document
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
      child: AlertDialog(
        title: _title(),
        content: _content(),
        actions: _actions(context),
        shape: RoundedRectangleBorder(
          side: Divider.createBorderSide(context),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// \todo document
  Widget _title() {
    return Text(
      switch (_type) {
        const (Loco) => widget.item == null ? 'Add loco' : 'Edit loco',
        const (Turnout) =>
          widget.item == null ? 'Add accessory' : 'Edit accessory',
        _ => 'Add loco or accessory',
      },
    );
  }

  /// \todo document
  Widget _content() {
    return DefaultAnimateSize(
      child: switch (_type) {
        const (Loco) => _locoContent(),
        const (Turnout) => _turnoutContent(),
        _ => _choseContent(),
      },
    );
  }

  /// \todo document
  Widget _locoContent() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormBuilderTextField(
            name: 'name',
            validator: nameValidator,
            initialValue: widget.loco?.name,
            decoration: const InputDecoration(
              icon: Icon(Icons.title),
              labelText: 'Name',
              helperText: ' ',
            ),
          ),
          FormBuilderTextField(
            name: 'address',
            validator: (String? value) {
              // Range check
              final str = locoAddressValidator(value);
              if (str != null) return str;

              // ...only allow new address if it's not already in use
              final address = int.parse(value!);
              if (widget.loco?.address != address &&
                  ref
                          .watch(locosProvider)
                          .firstWhereOrNull((l) => l.address == address) !=
                      null) {
                return 'Address already in use';
              }

              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.alternate_email),
              labelText: 'Address',
              helperText: ' ',
            ),
            valueTransformer: (value) =>
                value != null ? int.tryParse(value) : null,
            initialValue: widget.loco?.address.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          FormBuilderDropdown(
            name: 'speed_steps',
            validator: (value) {
              if (value == null) {
                return 'Please choose a speed step';
              }
              return null;
            },
            initialValue: widget.loco?.speedSteps,
            decoration: const InputDecoration(
              icon: Icon(Icons.speed),
              labelText: 'Speed steps',
              helperText: ' ',
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('14')),
              DropdownMenuItem(value: 2, child: Text('28')),
              DropdownMenuItem(value: 4, child: Text('128')),
            ],
            isDense: false,
          ),
        ],
      ),
    );
  }

  /// \todo document
  Widget _turnoutContent() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormBuilderTextField(
            name: 'name',
            validator: nameValidator,
            initialValue: widget.turnout?.name,
            decoration: const InputDecoration(
              icon: Icon(Icons.title),
              labelText: 'Name',
              helperText: ' ',
            ),
          ),
          FormBuilderTextField(
            name: 'address',
            validator: turnoutAddressValidator,
            decoration: const InputDecoration(
              icon: Icon(Icons.alternate_email),
              labelText: 'Address',
              helperText: ' ',
            ),
            onChanged: (value) => setState(
              () => _formKey.currentState?.fields['address']?.setValue(value),
            ),
            valueTransformer: (value) =>
                value != null ? int.tryParse(value) : null,
            initialValue: widget.turnout?.address.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          FormBuilderDropdown<int>(
            name: 'type',
            validator: (value) {
              if (value == null) {
                return 'Please choose a type';
              }
              return null;
            },
            initialValue: widget.turnout?.type,
            decoration: const InputDecoration(
              icon: Icon(Icons.format_list_numbered),
              labelText: 'Type',
              helperText: ' ',
            ),
            onChanged: (value) => setState(
              () => _formKey.currentState?.fields['type']?.setValue(value),
            ),
            items: _turnoutDropdownItems(),
            isDense: false,
          ),
          FormBuilderField<Map<String, dynamic>>(
            initialValue: widget.turnout?.group.toJson(),
            builder: (field) {
              // Type determines UI, can't show anything without it
              final type = _formKey.currentState?.fields['type']?.value ??
                  widget.turnout?.type;
              if (type == null) return SizedBox.shrink();

              // Number of positions
              final int rows = turnoutMap[type]!.assets.length;

              // Number of addresses
              final int cols = (rows - 1).bitLength;

              // Rebuild entire group here
              final group = () {
                final value = field.value != null
                    ? Group.fromJson(field.value!)
                    : Group();

                // Addresses, set to -1 if its not set yet
                final int? ownAddress = int.tryParse(
                  _formKey.currentState?.fields['address']?.value ?? '-1',
                );
                List<int> addresses = [ownAddress ?? -1];
                for (int j = 1; j < cols; ++j) {
                  addresses.add(value.addresses.elementAtOrNull(j) ?? -1);
                }

                // States
                List<List<int>> positions = [];
                for (int i = 0; i < rows; ++i) {
                  positions.add([]);
                  for (int j = 0; j < cols; ++j) {
                    // Default to binary pattern if it doesn't exist yet, e.g. [0, 0], [0, 1], [1, 0], ...
                    positions.last.add(
                      value.positions.elementAtOrNull(i)?.elementAtOrNull(j) ??
                          ((i >> (cols - 1 - j)) & 1) + 1,
                    );
                  }
                }

                return Group(addresses: addresses, positions: positions);
              }();

              // Immediately set value of built group
              _formKey.currentState?.fields['group']?.setValue(group.toJson());

              return InputDecorator(
                decoration: InputDecoration(
                  icon: Icon(Icons.table_view),
                  labelText: 'Group',
                  border: InputBorder.none,
                ),
                child: Table(
                  children: [
                    //
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      children: [
                        SizedBox.shrink(),
                        Text(
                          _formKey.currentState?.fields['address']?.value ??
                              widget.turnout?.address.toString() ??
                              '',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        for (int j = 1; j < cols; ++j)
                          TextFormField(
                            textAlign: TextAlign.center,
                            initialValue: group.addresses.elementAt(j) >= 0
                                ? group.addresses.elementAt(j).toString()
                                : '',
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final parsed = int.tryParse(value) ?? 0;
                              final addresses = [...group.addresses]..[j] =
                                  parsed;
                              field.didChange({
                                'addresses': addresses,
                                'positions': group.positions,
                              });
                            },
                            validator: (String? value) {
                              // Range check
                              final str = turnoutAddressValidator(value);
                              if (str != null) return str;

                              // ...only allow new address if it's not already in use
                              if (value ==
                                  _formKey
                                      .currentState?.fields['address']?.value) {
                                return 'Address already in use';
                              }

                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                      ],
                    ),

                    //
                    for (int i = 0; i < rows; ++i)
                      TableRow(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: SvgPicture.asset(
                              turnoutMap[type]!.assets[i],
                              colorMapper: DarkModeColorMapper(
                                ref.watch(darkModeProvider),
                              ),
                            ),
                          ),
                          for (int j = 0; j < cols; ++j)
                            Material(
                              type: MaterialType.circle,
                              color: Colors.transparent,
                              clipBehavior: Clip.antiAlias,
                              child: IconButton(
                                onPressed: () {
                                  final positions = [...group.positions]..[i]
                                      [j] = group.positions[i][j] ^ 3;
                                  field.didChange({
                                    'addresses': group.addresses,
                                    'positions': positions,
                                  });
                                },
                                isSelected: group.positions[i][j] == 2,
                                selectedIcon: Icon(Icons.looks_one),
                                icon: Icon(OpenRemiseIcons.looks_zero),
                              ),
                            ),
                        ],
                      ),
                  ],
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                ),
              );
            },
            name: 'group',
          ),
        ],
      ),
    );
  }

  /// \todo document
  List<DropdownMenuItem<int>> _turnoutDropdownItems() {
    return [
      for (final entry in turnoutMap.entries) ...[
        if (entry.key > 0 && entry.key % 256 == 0)
          const DropdownMenuItem<int>(enabled: false, child: Divider()),
        DropdownMenuItem<int>(
          value: entry.key,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  entry.value.previewAsset,
                  colorMapper: DarkModeColorMapper(ref.watch(darkModeProvider)),
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.value.label),
            ],
          ),
        ),
      ],
    ];
  }

  /// \todo document
  Widget _choseContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          iconSize: 48,
          onPressed: () => setState(() => _type = Loco),
          icon: Icon(Icons.train),
        ),
        IconButton(
          iconSize: 48,
          onPressed: () => setState(() => _type = Turnout),
          icon: Icon(OpenRemiseIcons.accessory),
        ),
      ],
    );
  }

  /// \todo document
  List<Widget> _actions(BuildContext context) {
    return switch (_type) {
      const (Loco) => _locoActions(context),
      const (Turnout) => _turnoutActions(context),
      _ => [],
    };
  }

  /// \todo document
  List<Widget> _locoActions(BuildContext context) {
    return <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          if (_formKey.currentState?.saveAndValidate() ?? false) {
            debugPrint(_formKey.currentState?.value.toString());
            final map = _formKey.currentState!.value;
            if (widget.loco == null) {
              ref
                  .read(dccProvider.notifier)
                  .updateLoco(map['address'], Loco.fromJson(map));
            } else {
              ref.read(dccProvider.notifier).updateLoco(
                    widget.loco!.address,
                    widget.loco!.copyWith(
                      address: map['address'],
                      name: map['name'],
                      speedSteps: map['speed_steps'],
                    ),
                  );
            }
            Navigator.pop(context);
          } else {
            debugPrint(_formKey.currentState?.value.toString());
            debugPrint('validation failed');
          }
        },
        child: const Text('OK'),
      ),
    ];
  }

  /// \todo document
  List<Widget> _turnoutActions(BuildContext context) {
    return <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          if (_formKey.currentState?.saveAndValidate() ?? false) {
            debugPrint(_formKey.currentState?.value.toString());
            final map = _formKey.currentState!.value;
            if (widget.turnout == null) {
              ref
                  .read(dccProvider.notifier)
                  .updateTurnout(map['address'], Turnout.fromJson(map));
            } else {
              ref.read(dccProvider.notifier).updateTurnout(
                    widget.turnout!.address,
                    widget.turnout!.copyWith(
                      address: map['address'],
                      name: map['name'],
                      type: map['type'],
                      group: Group.fromJson(map['group']),
                    ),
                  );
            }
            Navigator.pop(context);
          } else {
            debugPrint(_formKey.currentState?.value.toString());
            debugPrint('validation failed');
          }
        },
        child: const Text('OK'),
      ),
    ];
  }
}
