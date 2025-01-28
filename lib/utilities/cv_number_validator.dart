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
String? cvNumberValidator(String? value) {
  if (value == null || value.isEmpty) return 'Please enter a CV number';
  final number = int.tryParse(value);
  if (number == null) return 'Number invalid';
  if (number < 1 || number > 1024) {
    return 'Number out of range';
  }
  return null;
}
