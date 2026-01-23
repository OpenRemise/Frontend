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

import 'dart:convert';

/// Returns a Uri object with the input URL string percent-encoded using Latin-1
Uri latin1Uri(String url) {
  final bytes = latin1.encode(url);
  final buffer = StringBuffer();

  for (final b in bytes) {
    // Unreserved + URL structural characters that should NOT be percent-encoded
    if ((b >= 0x41 && b <= 0x5A) || // A–Z
        (b >= 0x61 && b <= 0x7A) || // a–z
        (b >= 0x30 && b <= 0x39) || // 0–9
        b == 0x2D || // -
        b == 0x2E || // .
        b == 0x5F || // _
        b == 0x7E || // ~
        b == 0x3A || // :
        b == 0x2F || // /
        b == 0x3F || // ?
        b == 0x26 || // &
        b == 0x3D || // =
        b == 0x23) {
      // #
      buffer.writeCharCode(b);
    } else {
      buffer.write('%');
      buffer.write(b.toRadixString(16).padLeft(2, '0').toUpperCase());
    }
  }

  return Uri.parse(buffer.toString());
}
