import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// There currently is no way to create a StateProvider with annotations?
final domainProvider = StateProvider<String>((_) {
  if (kIsWeb) {
    // Domain from running web build on localhost
    if (Uri.base.origin.contains('localhost')) {
      return 'remise.local';
    }
    // Domain from actual hardware
    else {
      return Uri.base.origin.replaceFirst('http://', '');
    }
  }
  // Domain from environment
  else {
    return const String.fromEnvironment('DOMAIN');
  }
});
