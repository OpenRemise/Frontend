import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bad practice, but we need a common provider container for all fake services
// https://github.com/rrousselGit/riverpod/issues/295
final fakeProviderContainer = ProviderContainer();
