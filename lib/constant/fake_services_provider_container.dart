// Copyright (C) 2025 Vincent Hamp
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fake services provider container
///
/// This is a global container for providers. Please not that this is **bad
/// practice**, but we need a common provider container for all fake services.
/// This is the only way we can inject this container to fake services as well
/// as the entire widget tree.
///
/// When faking services this container gets injected into [runApp](https://api.flutter.dev/flutter/widgets/runApp.html).
/// ```dart
/// // Expose global `ProviderContainer` to widget tree for fake services
/// if (const String.fromEnvironment('OPENREMISE_FRONTEND_FAKE_SERVICES') ==
///     'true') {
///   runApp(
///     UncontrolledProviderScope(
///       container: fakeServicesProviderContainer,
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
///
/// See also [#295](https://github.com/rrousselGit/riverpod/issues/295) and
/// [#1387](https://github.com/rrousselGit/riverpod/discussions/1387).
final fakeServicesProviderContainer = ProviderContainer();
