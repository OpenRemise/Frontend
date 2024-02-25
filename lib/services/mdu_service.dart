import 'dart:typed_data';

abstract class MduService {
  static const int ack = 0x06;
  static const int nak = 0x15;
  Future<void> ready();
  void close();
  Future<Uint8List> ping(int serialNumber, int decoderId);
  Future<Uint8List> configTransferRate(int transferRate);
  Future<Uint8List> binaryTreeSearch(int byte);
  Future<Uint8List> busy();
  Future<Uint8List> firmwareSalsa20IV(Uint8List iv);
  Future<Uint8List> firmwareErase(int beginAddress, int endAddress);
  Future<Uint8List> firmwareUpdate(int address, Uint8List chunk);
  Future<Uint8List> firmwareCrc32Start(
    int beginAddress,
    int endAddress,
    int crc32,
  );
  Future<Uint8List> firmwareCrc32Result();
  Future<Uint8List> firmwareCrc32ResultExit();
}
