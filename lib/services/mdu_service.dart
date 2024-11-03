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

import 'dart:typed_data';

abstract interface class MduService {
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void ping(int serialNumber, int decoderId);
  void configTransferRate(int transferRate);
  void binaryTreeSearch(int byte);
  void busy();
  void firmwareSalsa20IV(Uint8List iv);
  void firmwareErase(int beginAddress, int endAddress);
  void firmwareUpdate(int address, Uint8List chunk);
  void firmwareCrc32Start(
    int beginAddress,
    int endAddress,
    int crc32,
  );
  void firmwareCrc32Result();
  void firmwareCrc32ResultExit();
}
