import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// There currently is no way to create a StateProvider with annotations?
final domainProvider = StateProvider<String>((_) {
  if (kIsWeb) {
    if (Uri.base.origin.contains('localhost')) {
      return 'wulf.local';
    } else {
      return Uri.base.origin.replaceFirst('http://', '');
    }
  } else {
    return const String.fromEnvironment('DOMAIN');
  }
});
