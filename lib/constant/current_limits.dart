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

/// Current limits
///
/// The four \ref currentLimits "current limits" are part of the firmware
/// settings. The index of the current value ​​can be read or written as
/// `cur_lim` at the `/settings/` endpoint.
const List<double> currentLimits = [0.5, 1.3, 2.7, 4.1];
