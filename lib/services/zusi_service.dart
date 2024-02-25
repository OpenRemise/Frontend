import 'dart:typed_data';

abstract class ZusiService {
  static const int ack = 0x06;
  static const int nak = 0x15;
  Future<void> ready();
  void close();
  Future<Uint8List> readCv(int address);
  Future<Uint8List> writeCv(int address, int value);
  Future<Uint8List> eraseZpp();
  Future<Uint8List> writeZpp(int address, Uint8List chunk);
  Future<Uint8List> features();
  Future<Uint8List> exit(int flags);
  Future<Uint8List> encrypt();
}
