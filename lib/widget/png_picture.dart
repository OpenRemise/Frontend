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

/// PNG picture
///
/// \file   widget/png_picture.dart
/// \author Vincent Hamp
/// \date   27/04/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PNG picture
///
/// PngPicture does what [Image.asset](https://api.flutter.dev/flutter/widgets/Image/Image.asset.html)
/// should do on Web. For some reason, this doesn't work on embedded systems. As
/// a workaround, this class uses [rootBundle.load](https://api.flutter.dev/flutter/services/rootBundle.html)
/// and feeds the raw data into [Image.memory](https://api.flutter.dev/flutter/widgets/Image/Image.memory.html).
class PngPicture extends StatelessWidget {
  final String name;
  final double scale;
  final ImageFrameBuilder? frameBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final double? width;
  final double? height;
  final Color? color;
  final Animation<double>? opacity;
  final FilterQuality filterQuality;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool isAntiAlias;
  final int? cacheWidth;
  final int? cacheHeight;

  const PngPicture.asset(
    this.name, {
    super.key,
    this.scale = 1.0,
    this.frameBuilder,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.medium,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.load(name),
      builder: (context, snapshot) => snapshot.hasData
          ? Image.memory(
              snapshot.requireData.buffer.asUint8List(),
              scale: scale,
            )
          : const SizedBox.shrink(),
    );
  }
}
