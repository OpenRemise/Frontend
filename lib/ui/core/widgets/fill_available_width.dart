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

/// Fill available width
///
/// \file   ui/core/widgets/fill_available_width.dart
/// \author Vincent Hamp
/// \date   07/09/2026

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Stretches its child to the offered width while reporting no intrinsic width
///
/// Useful inside widgets which size themselves by intrinsic width, such as
/// [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html).
/// Children like images would otherwise widen their parent to their own pixel
/// width.
class FillAvailableWidth extends SingleChildRenderObjectWidget {
  const FillAvailableWidth({super.key, required Widget super.child});

  @override
  RenderFillAvailableWidth createRenderObject(BuildContext context) =>
      RenderFillAvailableWidth();
}

/// Render object of [FillAvailableWidth]
class RenderFillAvailableWidth extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      child?.getDryLayout(_childConstraints(constraints)) ??
      constraints.smallest;

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    size = constraints.constrain(child.size);
  }

  BoxConstraints _childConstraints(BoxConstraints constraints) =>
      constraints.maxWidth.isFinite
          ? constraints.copyWith(minWidth: constraints.maxWidth)
          : constraints;
}
