import 'package:Frontend/providers/ms_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetch msdb and take a look at it', () async {
    final container = ProviderContainer();
    final msDatabase =
        await container.read(msDatabaseProvider(const Locale('de')).future);
    msDatabase.forEach((key, value) {
      print(value);
    });
  });
}
