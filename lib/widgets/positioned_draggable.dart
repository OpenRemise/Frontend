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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class PositionedDraggable extends ConsumerStatefulWidget {
  final Widget? child;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final void Function()? onTap;
  final void Function()? onTapCancel;
  final void Function()? onSecondaryTap;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final void Function(TapUpDetails)? onSecondaryTapUp;
  final void Function()? onSecondaryTapCancel;
  final void Function(TapDownDetails)? onTertiaryTapDown;
  final void Function(TapUpDetails)? onTertiaryTapUp;
  final void Function()? onTertiaryTapCancel;
  final void Function(TapDownDetails)? onDoubleTapDown;
  final void Function()? onDoubleTap;
  final void Function()? onDoubleTapCancel;
  final void Function(LongPressDownDetails)? onLongPressDown;
  final void Function()? onLongPressCancel;
  final void Function()? onLongPress;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressMoveUpdateDetails)? onLongPressMoveUpdate;
  final void Function()? onLongPressUp;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final void Function(LongPressDownDetails)? onSecondaryLongPressDown;
  final void Function()? onSecondaryLongPressCancel;
  final void Function()? onSecondaryLongPress;
  final void Function(LongPressStartDetails)? onSecondaryLongPressStart;
  final void Function(LongPressMoveUpdateDetails)?
      onSecondaryLongPressMoveUpdate;
  final void Function()? onSecondaryLongPressUp;
  final void Function(LongPressEndDetails)? onSecondaryLongPressEnd;
  final void Function(LongPressDownDetails)? onTertiaryLongPressDown;
  final void Function()? onTertiaryLongPressCancel;
  final void Function()? onTertiaryLongPress;
  final void Function(LongPressStartDetails)? onTertiaryLongPressStart;
  final void Function(LongPressMoveUpdateDetails)?
      onTertiaryLongPressMoveUpdate;
  final void Function()? onTertiaryLongPressUp;
  final void Function(LongPressEndDetails)? onTertiaryLongPressEnd;
  final void Function(DragDownDetails)? onVerticalDragDown;
  final void Function(DragStartDetails)? onVerticalDragStart;
  final void Function(DragUpdateDetails)? onVerticalDragUpdate;
  final void Function(DragEndDetails)? onVerticalDragEnd;
  final void Function()? onVerticalDragCancel;
  final void Function(DragDownDetails)? onHorizontalDragDown;
  final void Function(DragStartDetails)? onHorizontalDragStart;
  final void Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final void Function(DragEndDetails)? onHorizontalDragEnd;
  final void Function()? onHorizontalDragCancel;
  final void Function(ForcePressDetails)? onForcePressStart;
  final void Function(ForcePressDetails)? onForcePressPeak;
  final void Function(ForcePressDetails)? onForcePressUpdate;
  final void Function(ForcePressDetails)? onForcePressEnd;
  final void Function(DragDownDetails)? onPanDown;
  final void Function(DragStartDetails)? onPanStart;
  final void Function(DragUpdateDetails)? onPanUpdate;
  final void Function(DragEndDetails)? onPanEnd;
  final void Function()? onPanCancel;
  final void Function(ScaleStartDetails)? onScaleStart;
  final void Function(ScaleUpdateDetails)? onScaleUpdate;
  final void Function(ScaleEndDetails)? onScaleEnd;

  const PositionedDraggable({
    super.key,
    this.child,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onDoubleTapCancel,
    this.onLongPressDown,
    this.onLongPressCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.onSecondaryLongPressDown,
    this.onSecondaryLongPressCancel,
    this.onSecondaryLongPress,
    this.onSecondaryLongPressStart,
    this.onSecondaryLongPressMoveUpdate,
    this.onSecondaryLongPressUp,
    this.onSecondaryLongPressEnd,
    this.onTertiaryLongPressDown,
    this.onTertiaryLongPressCancel,
    this.onTertiaryLongPress,
    this.onTertiaryLongPressStart,
    this.onTertiaryLongPressMoveUpdate,
    this.onTertiaryLongPressUp,
    this.onTertiaryLongPressEnd,
    this.onVerticalDragDown,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
  });

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
        onTapDown: widget.onTapDown,
        onTapUp: widget.onTapUp,
        onTap: widget.onTap,
        onTapCancel: widget.onTapCancel,
        onSecondaryTap: widget.onSecondaryTap,
        onSecondaryTapDown: widget.onSecondaryTapDown,
        onSecondaryTapUp: widget.onSecondaryTapUp,
        onSecondaryTapCancel: widget.onSecondaryTapCancel,
        onTertiaryTapDown: widget.onTertiaryTapDown,
        onTertiaryTapUp: widget.onTertiaryTapUp,
        onTertiaryTapCancel: widget.onTertiaryTapCancel,
        onDoubleTapDown: widget.onDoubleTapDown,
        onDoubleTap: widget.onDoubleTap,
        onDoubleTapCancel: widget.onDoubleTapCancel,
        onLongPressDown: widget.onLongPressDown,
        onLongPressCancel: widget.onLongPressCancel,
        onLongPress: widget.onLongPress,
        onLongPressStart: widget.onLongPressStart,
        onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
        onLongPressUp: widget.onLongPressUp,
        onLongPressEnd: widget.onLongPressEnd,
        onSecondaryLongPressDown: widget.onSecondaryLongPressDown,
        onSecondaryLongPressCancel: widget.onSecondaryLongPressCancel,
        onSecondaryLongPress: widget.onSecondaryLongPress,
        onSecondaryLongPressStart: widget.onSecondaryLongPressStart,
        onSecondaryLongPressMoveUpdate: widget.onSecondaryLongPressMoveUpdate,
        onSecondaryLongPressUp: widget.onSecondaryLongPressUp,
        onSecondaryLongPressEnd: widget.onSecondaryLongPressEnd,
        onTertiaryLongPressDown: widget.onTertiaryLongPressDown,
        onTertiaryLongPressCancel: widget.onTertiaryLongPressCancel,
        onTertiaryLongPress: widget.onTertiaryLongPress,
        onTertiaryLongPressStart: widget.onTertiaryLongPressStart,
        onTertiaryLongPressMoveUpdate: widget.onTertiaryLongPressMoveUpdate,
        onTertiaryLongPressUp: widget.onTertiaryLongPressUp,
        onTertiaryLongPressEnd: widget.onTertiaryLongPressEnd,
        onVerticalDragDown: widget.onVerticalDragDown,
        onVerticalDragStart: widget.onVerticalDragStart,
        onVerticalDragUpdate: widget.onVerticalDragUpdate,
        onVerticalDragEnd: widget.onVerticalDragEnd,
        onVerticalDragCancel: widget.onVerticalDragCancel,
        onHorizontalDragDown: widget.onHorizontalDragDown,
        onHorizontalDragStart: widget.onHorizontalDragStart,
        onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
        onHorizontalDragEnd: widget.onHorizontalDragEnd,
        onHorizontalDragCancel: widget.onHorizontalDragCancel,
        onForcePressStart: widget.onForcePressStart,
        onForcePressPeak: widget.onForcePressPeak,
        onForcePressUpdate: widget.onForcePressUpdate,
        onForcePressEnd: widget.onForcePressEnd,
        onPanDown: widget.onPanDown,
        onPanStart: widget.onPanStart,
        onPanUpdate: (details) {
          setState(
            () => _offset = Offset(
              _offset.dx + details.delta.dx,
              _offset.dy + details.delta.dy,
            ),
          );
          if (widget.onPanUpdate != null) {
            widget.onPanUpdate!(details);
          }
        },
        onPanEnd: widget.onPanEnd,
        onPanCancel: widget.onPanCancel,
        onScaleStart: widget.onScaleStart,
        onScaleUpdate: widget.onScaleUpdate,
        onScaleEnd: widget.onScaleEnd,
        child: widget.child,
      ),
    );
  }
}
