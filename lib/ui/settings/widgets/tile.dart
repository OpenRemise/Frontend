// Copyright (C) 2026 Vincent Hamp
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

/// Settings tile
///
/// \file   ui/settings/widgets/tile.dart
/// \author Vincent Hamp
/// \date   24/06/2026

import 'package:flutter/material.dart';

/// \todo document
class SettingsTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final List<Widget> children;
  final ExpansionTileController? controller;

  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.children = const <Widget>[],
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: leading,
      title: title,
      maintainState: true,
      shape: const Border(),
      collapsedShape: const Border(),
      controller: controller,
      expansionAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
      children: [
        const Divider(thickness: 1),
        ...children.map(
          (c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: c,
          ),
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}
