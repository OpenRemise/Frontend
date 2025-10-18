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
import 'package:flutter_svg/flutter_svg.dart';

class GrayscaleColorMapper extends ColorMapper {
  const GrayscaleColorMapper();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    // OpenRemise
    if (color == Colors.white || color == Colors.black) {
      return Color(0xFF626262);
    }
    // ZIMO
    else if (color == const Color(0xFFB2D2F0) ||
        color == const Color(0xFF41569F)) {
      return Color(color == const Color(0xFFB2D2F0) ? 0xFF626262 : 0xFF222222);
    }
    // D&H 0xFF005292
    else if (color == const Color(0xFF005292)) {
      return Color(0xFF626262);
    }
    // Tams
    else if (color == const Color(0xFF231F20) ||
        color == const Color(0xFFED1C24)) {
      return Color(0xFF626262);
    }
    // Unknown
    else {
      return color;
    }
  }
}
