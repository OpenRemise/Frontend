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

import 'package:multicast_dns/multicast_dns.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domains.g.dart';

/// \todo document
@riverpod
Future<List<String>> domains(_) async {
  final MDnsClient client = MDnsClient();
  await client.start();
  final records = await client
      .lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_http._tcp'),
      )
      .toList();
  client.stop();

  final remiseDomainNames = [
    for (final record in records)
      if (record.domainName.contains('remise'))
        record.domainName.replaceAll('_http._tcp.', ''),
  ];

  // Set -> List enforces uniqueness
  return remiseDomainNames.toSet().toList();
}
