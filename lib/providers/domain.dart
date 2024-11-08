// Copyright (C) 2024 Vincent Hamp
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// There currently is no way to create a StateProvider with annotations?
final domainProvider = StateProvider<String>((_) {
  if (kIsWeb) {
    // Domain from running web build on localhost
    if (Uri.base.origin.contains('localhost')) {
      return const String.fromEnvironment('OPENREMISE_FRONTEND_DOMAIN');
    }
    // Domain from actual hardware
    else {
      return Uri.base.origin.replaceFirst('http://', '');
    }
  }
  // Domain from environment
  else {
    return const String.fromEnvironment('OPENREMISE_FRONTEND_DOMAIN');
  }
});
