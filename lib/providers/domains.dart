import 'package:multicast_dns/multicast_dns.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domains.g.dart';

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

  final wulfDomainNames = [
    for (final record in records)
      if (record.domainName.contains('wulf'))
        record.domainName.replaceAll('_http._tcp.', ''),
  ];

  // Set -> List enforces uniqueness
  return wulfDomainNames.toSet().toList();
}
