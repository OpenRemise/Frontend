// Created by Franziska Walter
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

import 'package:flutter/material.dart';

class PersistentExpansionTile extends StatefulWidget {
  final ValueNotifier<bool>? externalController;
  final Widget title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? tilePadding;
  final bool showDividers;

  const PersistentExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.leading,
    this.trailing,
    this.tilePadding,
    this.showDividers = false,
    this.externalController,
  });

  @override
  State<PersistentExpansionTile> createState() =>
      _PersistentExpansionTileState();
}

class _PersistentExpansionTileState extends State<PersistentExpansionTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;

    widget.externalController?.addListener(() {
      setState(() {
        _expanded = widget.externalController!.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expandedColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    final contentOnly = Column(
      children: [
        ...widget.children,
      ],
    );

    final innerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showDividers) const Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: contentOnly,
        ),
        if (widget.showDividers) const Divider(thickness: 1),
      ],
    );

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _expanded ? expandedColor : Colors.transparent,
          child: ListTile(
            contentPadding: widget.tilePadding,
            leading: widget.leading,
            title: widget.title,
            trailing: widget.trailing ??
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: _toggle,
                ),
            onTap: _toggle,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Offstage(
            offstage: !_expanded,
            child: innerContent,
          ),
        ),
      ],
    );
  }

  void _toggle() => setState(() => _expanded = !_expanded);
}
