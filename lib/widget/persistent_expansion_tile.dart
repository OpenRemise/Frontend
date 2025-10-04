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

/// Persistent expansion tile
///
/// \file   widget/persistent_expansion_tile.dart
/// \author Franziska Walter
/// \date   21/05/2025

import 'package:Frontend/widget/default_animated_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ExpansionTile with external expanded state
///
/// An [ExpansionTile](https://api.flutter.dev/flutter/material/ExpansionTile-class.html)-like
/// class whose expanded state comes from a [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html).
/// The widget is used in the \ref SettingsScreen "settings screen". An
/// expand/collapse all button allows all tiles to be expanded or collapsed at
/// once.
class PersistentExpansionTile extends ConsumerStatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final List<Widget> children;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? tilePadding;
  final ValueNotifier<bool>? controller;

  const PersistentExpansionTile({
    super.key,
    this.leading,
    required this.title,
    this.trailing,
    required this.children,
    this.initiallyExpanded = false,
    this.tilePadding,
    this.controller,
  });

  @override
  ConsumerState<PersistentExpansionTile> createState() =>
      _PersistentExpansionTileState();
}

class _PersistentExpansionTileState
    extends ConsumerState<PersistentExpansionTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    widget.controller?.addListener(() {
      setState(() {
        _expanded = widget.controller!.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          color:
              _expanded ? Theme.of(context).highlightColor : Colors.transparent,
          duration: const Duration(milliseconds: 200),
          child: ListTile(
            leading: widget.leading,
            title: widget.title,
            trailing: widget.trailing ??
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: _toggle,
                ),
            contentPadding: widget.tilePadding,
            onTap: _toggle,
          ),
        ),
        DefaultAnimateSize(
          child: Offstage(
            offstage: !_expanded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [...widget.children]),
                ),
                const Divider(thickness: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggle() => setState(() => _expanded = !_expanded);
}
