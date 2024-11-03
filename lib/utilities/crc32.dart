// Copyright (C) 2024 Vincent Hamp
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

int _crc32Byte(int crc, int byte) {
  for (var i = 0; i < 8; ++i) {
    final tmp = crc;
    crc <<= 1;
    if ((byte & 0x80) == 0x80) crc |= 1;
    if ((tmp & 0x80000000) == 0x80000000) crc ^= 0x4C11DB7;
    byte <<= 1;
  }
  return crc & 0xFFFFFFFF;
}

int crc32<T extends List>(T bytes) {
  int crc = bytes.fold(0xFFFFFFFF, (previousValue, element) {
    return _crc32Byte(previousValue, element);
  });
  final List<int> zeros = [0, 0, 0, 0];
  return zeros.fold(crc, (previousValue, element) {
    return _crc32Byte(previousValue, element);
  });
}
