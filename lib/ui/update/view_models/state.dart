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

/// Update state
///
/// \file   ui/update/view_models/state.dart
/// \author Vincent Hamp
/// \date   16/06/2026

// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

enum UpdateStatus { Idle, Connecting, Updating, Completed, Failed }

@freezed
abstract class UpdateState with _$UpdateState {
  const factory UpdateState({
    @Default(UpdateStatus.Idle) UpdateStatus status,
    @Default('') String message,
    double? progress,
    @Default([]) List<UpdateDeviceState> devices,
  }) = _UpdateState;
}

@freezed
abstract class UpdateDeviceState with _$UpdateDeviceState {
  const factory UpdateDeviceState({
    @Default('') String name,
    @Default(UpdateStatus.Idle) UpdateStatus status,
  }) = _UpdateDeviceState;
}
