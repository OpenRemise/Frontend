import 'package:Frontend/providers/z21_service.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_system_state.g.dart';

@riverpod
Stream<LanSystemStateDataChanged> z21SystemState(ref) async* {
  final z21 = ref.watch(z21ServiceProvider);
  await for (final systemState in z21.stream.where(
    (command) =>
        switch (command) { LanSystemStateDataChanged() => true, _ => false },
  )) {
    yield systemState;
  }
}
