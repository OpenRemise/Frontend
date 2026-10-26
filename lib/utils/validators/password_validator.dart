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

import 'dart:convert';

/// \todo document
String? passwordValidator(String? value) {
  if (value == null) {
    return 'Please enter a password';
  }
  final length = utf8.encode(value).length;
  if (length != 0 && length < 8) {
    return 'Password too short';
  } else if (length > 63) {
    return 'Password too long';
  } else {
    return null;
  }
}
