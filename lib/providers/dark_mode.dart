import 'package:Frontend/prefs.dart';
import 'package:shared_preferences_riverpod/shared_preferences_riverpod.dart';

final darkModeProvider = createPrefProvider<bool>(
  prefs: (_) => prefs,
  prefKey: 'darkMode',
  defaultValue: false,
);
