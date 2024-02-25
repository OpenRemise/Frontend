import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:fixnum/fixnum.dart';

typedef ZsuDecoder = ({
  Uint8List bin,
  String name,
  String majorVersion,
  String minorVersion,
  int type,
  int? bootloader, // MS only
  Uint8List? iv, // MS only
});

class Zsu {
  late final Uint8List _bytes;
  late final int _version;
  final Map<int, ZsuDecoder> _entries = {};

  Uint8List get bytes => _bytes;
  int get version => _version;
  Map<int, ZsuDecoder> get entries => _entries;

  Zsu(this._bytes) {
    // .zsu files start with "DF\t"
    if (String.fromCharCodes(_bytes.sublist(0, 3)) != 'DF\t') {
      throw Exception('Not a .zsu file');
    }

    // Version must be 1
    _version = int.parse(String.fromCharCode(_bytes[3]));
    if (_version != 1) throw Exception('.zsu file version unknown');

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
      _entries[id] = (
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
