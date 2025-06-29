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

/// WebSocket batch size
///
/// This is the maximum number of WebSocket messages grouped and sent at once.
///
/// \warning
/// Extreme caution is advised when increasing this value. Many small messages
/// Many small packets quickly overload the input buffers of the ESP32.
///
/// See also [#45](https://github.com/OpenRemise/Firmware/issues/45).
const int wsBatchSize = 32;
