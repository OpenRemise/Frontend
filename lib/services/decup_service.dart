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

import 'dart:typed_data';

/// \todo document
abstract interface class DecupService {
  static const int ack = 0x1C;
  static const int nak = 0xFC;
  int? get closeCode;
  String? get closeReason;
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void zppPreamble();
  void zppDecoderId();
  void zppReadCv(int cvAddress);
  void zppWriteCv(int cvAddress, int byte);
  void zppErase();
  void zppBlocks(int count, Uint8List chunk);

  void zsuPreamble();
  void zsuDecoderId(int byte);
  void zsuBlockCount(int count);
  void zsuSecurityByte1();
  void zsuSecurityByte2();
  void zsuBlocks(int count, Uint8List chunk);
}
