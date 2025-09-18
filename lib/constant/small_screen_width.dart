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

/// Small screen width
///
/// \file   constant/small_screen_width.dart
/// \author Vincent Hamp
/// \date   01/11/2024

/// Small screen width
///
/// This is the width over which a large screen is assumed. The app changes its
/// layout depending on the screen size. This value is therefore often compared
/// to `MediaQuery.of(context).size.width`.
final int smallScreenWidth = int.parse(
  const String.fromEnvironment('OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH'),
);
