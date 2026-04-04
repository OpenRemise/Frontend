// Copyright (C) 2026 Vincent Hamp
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

import 'dart:async';
import 'dart:collection';

import 'package:Frontend/provider/roco/z21_service.dart';
import 'package:Frontend/service/roco/z21_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'z21_cv.g.dart';

/*
CvRequest
indexHigh 0
indexLow 1
number
value? (null -> read)
address? (null -> service mode)
type

CvResult...?
Number.IndexHigh.IndexLow -> Value?
*/

/// \todo document
@riverpod
class Z21Cv extends _$Z21Cv {
  late final Z21Service _z21;
  late final StreamSubscription _sub;
  final Queue<Z21Command> _queue = Queue();
  Z21Command? _active;
  int? _cv31;
  int? _cv32;

  /// \todo document
  @override
  Map<(int, int, int), Z21Command> build() {
    _z21 = ref.read(z21ServiceProvider);
    _sub = _z21.stream
        .where(
          (command) => switch (command) {
            LanXCvNackSc() => true,
            LanXCvNack() => true,
            LanXCvResult() => true,
            _ => false
          },
        )
        .listen(response);
    ref.onDispose(() {
      _sub.cancel();
    });
    return {};
  }

  /// \todo document
  void request() {
    // _queue.add...
    _execute();
  }

  /// \todo document
  void response(Z21Command) {
    if (_active == null) return;

    // blabla update state

    _active = null;
    _execute();
  }

  /// \todo document
  void _execute() {
    if (_active != null || _queue.isEmpty) return;

    _active = _queue.removeFirst();
    _z21(_active!);
  }
}
