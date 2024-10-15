import 'package:Frontend/prefs.dart';
import 'package:shared_preferences_riverpod/shared_preferences_riverpod.dart';

final serviceModeProvider = createPrefProvider<bool>(
  prefs: (_) => prefs,
  prefKey: 'serviceMode',
  defaultValue: false,
);
