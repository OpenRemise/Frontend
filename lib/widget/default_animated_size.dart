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

/// A wrapper around [AnimatedSize]
///
/// \todo document
class DefaultAnimateSize extends StatelessWidget {
  final Widget? child;
  final Duration duration;
  final Alignment alignment;
  final Curve curve;
  final Duration? reverseDuration;
  final Clip clipBehavior;
  final VoidCallback? onEnd;

  const DefaultAnimateSize({
    super.key,
    this.duration = const Duration(milliseconds: 500),
    this.alignment = Alignment.topCenter,
    this.curve = Curves.easeInOut,
    this.child,
    this.reverseDuration,
    this.clipBehavior = Clip.hardEdge,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: alignment,
      curve: curve,
      duration: duration,
      reverseDuration: reverseDuration,
      clipBehavior: clipBehavior,
      onEnd: onEnd,
      child: child,
    );
  }
}
