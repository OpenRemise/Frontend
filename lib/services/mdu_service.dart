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

abstract interface class MduService {
  static const int ack = 0x06;
  static const int nak = 0x15;
  int? get closeCode;
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void ping(int serialNumber, int decoderId);
  void configTransferRate(int transferRate);
  void binaryTreeSearch(int byte);
  void busy();

  void zppValidQuery(String id, int flashSize);
  void zppLcDcQuery(Uint8List developerCode);
  void zppErase(int beginAddress, int endAddress);
  void zppUpdate(int address, Uint8List chunk);
  void zppUpdateEnd(int beginAddress, int endAddress);
  void zppExit();
  void zppExitReset();

  void zsuSalsa20IV(Uint8List iv);
  void zsuErase(int beginAddress, int endAddress);
  void zsuUpdate(int address, Uint8List chunk);
  void zsuCrc32Start(
    int beginAddress,
    int endAddress,
    int crc32,
  );
  void zsuCrc32Result();
  void zsuCrc32ResultExit();
}
