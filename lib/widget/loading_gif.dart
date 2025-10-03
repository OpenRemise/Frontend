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

import 'package:Frontend/provider/dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif/gif.dart';

/// Loading animation GIF
///
/// A looping GIF with a width of 200px showing the loading animation.
class LoadingGif extends ConsumerWidget {
  const LoadingGif({super.key});

  /// \todo document
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Gif(
      image: AssetImage(
        ref.watch(darkModeProvider)
            ? 'data/images/gifs/loading_dark.gif'
            : 'data/images/gifs/loading_light.gif',
      ),
      autostart: Autostart.loop,
      width: 200,
    );
  }
}
