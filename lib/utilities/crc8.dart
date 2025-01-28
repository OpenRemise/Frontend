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
int _crc8Byte(int byte) {
  int crc = 0;
  if (byte & 0x01 == 0x01) crc ^= 0x5E;
  if (byte & 0x02 == 0x02) crc ^= 0xBC;
  if (byte & 0x04 == 0x04) crc ^= 0x61;
  if (byte & 0x08 == 0x08) crc ^= 0xC2;
  if (byte & 0x10 == 0x10) crc ^= 0x9D;
  if (byte & 0x20 == 0x20) crc ^= 0x23;
  if (byte & 0x40 == 0x40) crc ^= 0x46;
  if (byte & 0x80 == 0x80) crc ^= 0x8C;
  return crc & 0xFF;
}

/// \todo document
int crc8<T extends List>(T bytes, [int init = 0]) {
  return bytes.fold(init, (previousValue, element) {
    return _crc8Byte(previousValue ^ element);
  });
}
