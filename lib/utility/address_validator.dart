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

/// \todo document
String? addressValidator(String? value) {
  if (value == null || value.isEmpty) return 'Please enter an address';
  final number = int.tryParse(value);
  if (number == null) {
    return 'Address invalid';
  } else if (number > 9999) {
    return 'Address out of range';
  } else {
    return null;
  }
}
