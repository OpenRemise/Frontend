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

import 'dart:collection';

import 'package:Frontend/data/models/loco.dart';
import 'package:xml/xml.dart';

/// Parse a .Locxml file into a [SplayTreeSet] of [Loco] objects
SplayTreeSet<Loco> locosFromLocxml(String xmlString) {
  final document = XmlDocument.parse(xmlString);
  final entries = document.findAllElements('clsDatensatz');
  return SplayTreeSet<Loco>.of(
    entries.map((entry) {
      final address =
          int.parse(entry.findElements('Lokadresse').single.innerText);
      final name = entry.findElements('Name').single.innerText;
      final speedSteps =
          int.parse(entry.findElements('SpeedSteps').single.innerText);
      return Loco(
        address: address,
        name: name,
        speedSteps: switch (speedSteps) { 14 => 0, 28 => 2, _ => 4 },
        mode: 0,
      );
    }),
  );
}

/// Serialize [Loco] objects to a .Locxml formatted string
String locosToLocxml(Iterable<Loco> locos) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="utf-8"');
  builder.element(
    'ArrayOfClsDatensatz',
    attributes: {
      'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      'xmlns:xsd': 'http://www.w3.org/2001/XMLSchema',
    },
    nest: () {
      for (final loco in locos) {
        builder.element(
          'clsDatensatz',
          nest: () {
            builder.element('Lokadresse', nest: loco.address.toString());
            builder.element(
              'SpeedSteps',
              nest: switch (loco.speedSteps) {
                0 => '14',
                2 => '28',
                _ => '126'
              },
            );
            builder.element('Format', nest: 'DCC');
            builder.element('Name', nest: loco.name);
          },
        );
      }
    },
  );
  return builder.buildDocument().toXmlString(pretty: true, indent: '  ');
}
