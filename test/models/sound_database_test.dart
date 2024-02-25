import 'package:Frontend/providers/sound_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetch soundb and take a look at it', () async {
    final container = ProviderContainer();
    final soundDatabase =
        await container.read(soundDatabaseProvider(const Locale('de')).future);
    soundDatabase.forEach((key, value) {
      debugPrint('alpha-2 code $key, image src ${value.first.flag}');
    });
  });
}
