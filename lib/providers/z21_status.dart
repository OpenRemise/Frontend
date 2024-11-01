import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_status.g.dart';

@riverpod
Stream<LanXStatusChanged> z21Status(ref) async* {
  final z21 = ref.watch(z21ServiceProvider);
  await for (final status in z21.stream.where(
    (command) => switch (command) { LanXStatusChanged() => true, _ => false },
  )) {
    yield status;
  }
}
