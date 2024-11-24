// Copyright (C) 2024 Vincent Hamp
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

import 'dart:typed_data';
import 'dart:convert';

/// \todo document
class Zpp {
  final Uint8List _bytes;
  late final String id;
  late final int version;
  late final Uint8List flash;
  final Map<int, int> cvs = {};
  late final bool coded;

  /// \todo document
  Zpp(this._bytes) {
    // File identifier
    id = const AsciiDecoder().convert(_bytes.sublist(0, 2));
    if (id != 'SP') {
      throw Exception('Not a .pp file');
    }

    // Version
    version = _bytes[2] << 16 | _bytes[3] << 0;

    // Flash
    final int flashStart =
        _bytes[5] << 24 | _bytes[6] << 16 | _bytes[7] << 8 | _bytes[8] << 0;
    final int flashLength =
        _bytes[9] << 24 | _bytes[10] << 16 | _bytes[11] << 8 | _bytes[12] << 0;
    flash = _bytes.sublist(flashStart, flashStart + flashLength);

    // CVs
    final int cvsStart =
        _bytes[13] << 24 | _bytes[14] << 16 | _bytes[15] << 8 | _bytes[16] << 0;
    final int cvsLength = _bytes[17] << 8 | _bytes[18] << 0;
    for (var i = 0; i < cvsLength; i += 3) {
      final cvAddress =
          _bytes[cvsStart + i] << 8 | _bytes[cvsStart + i + 1] << 0;
      cvs[cvAddress] = _bytes[cvsStart + i + 2];
    }

    // Coded
    coded = _bytes[19] != 0;
  }
}
