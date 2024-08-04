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
