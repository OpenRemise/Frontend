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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class PositionedDraggable extends ConsumerStatefulWidget {
  final Widget child;

  const PositionedDraggable({super.key, required this.child});

  @override
  ConsumerState<PositionedDraggable> createState() =>
      _PositionedDraggableState();
}

/// \todo document
class _PositionedDraggableState extends ConsumerState<PositionedDraggable> {
  Offset _offset = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(
          () => _offset = Offset(
            _offset.dx + details.delta.dx,
            _offset.dy + details.delta.dy,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
