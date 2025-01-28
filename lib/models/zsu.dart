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

import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:fixnum/fixnum.dart';

/// \todo document
typedef ZsuFirmware = ({
  Uint8List bin,
  String name,
  String majorVersion,
  String minorVersion,
  int type,
  int? bootloader, // MS only
  Uint8List? iv, // MS only
});

/// \todo document
class Zsu {
  final Uint8List _bytes;
  late final int version;
  final Map<int, ZsuFirmware> firmwares = {};

  /// \todo document
  Zsu(this._bytes) {
    // .zsu files start with "DF\t"
    if (String.fromCharCodes(_bytes.sublist(0, 3)) != 'DF\t') {
      throw Exception('Not a .zsu file');
    }

    // Version must be 1
    version = int.parse(String.fromCharCode(_bytes[3]));
    if (version != 1) throw Exception('.zsu file version unknown');

    // Decoder info can be found between first ';' and ':'
    final decoderInfo = _bytes.sublist(
      _bytes.indexOf(';'.codeUnitAt(0)) + 1,
      _bytes.indexOf(':'.codeUnitAt(0)),
    );

    List<List<String>> csv = const CsvToListConverter(
      fieldDelimiter: '\t',
      eol: ';',
      shouldParseNumbers: false,
    ).convert(String.fromCharCodes(decoderInfo));

    // Be careful, there are subtle differences between MS and MX!
    for (final List<String> row in csv) {
      final id = int.parse(row[0]);
      final type = int.parse(row[6]);
      final binStart = int.parse(row[1]) + 1; // Legacy bug
      final binLength = type >= 3 ? int.parse(row[2]) : int.parse(row[2]) - 2;
      final binEnd = binStart + binLength;
      firmwares[id] = (
        bin: _bytes.sublist(binStart, binEnd),
        name: row[3],
        majorVersion: row[4],
        minorVersion: row[5],
        type: type,
        bootloader: type >= 3 ? int.parse(row[7]) : null,
        iv: type >= 3
            ? Uint8List.fromList(
                Int64.parseInt(row[8]).toBytes().reversed.toList(),
              )
            : null,
      );
    }
  }
}
