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

/// DCC BiDi durations
///
/// The five \ref dccBiDiDurations "DCC BiDi durations" are part of the firmware
/// settings. Using the first value (0) BiDi can be switched off. The current
/// value ​​can be read or written as `dcc_bidibit_dur` at the `/settings/`
/// endpoint.
const List<int> dccBiDiDurations = [0, 57, 58, 59, 60, 61];
