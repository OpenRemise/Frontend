import 'dart:typed_data';

abstract interface class ZusiService {
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void readCv(int address);
  void writeCv(int address, int value);
  void eraseZpp();
  void writeZpp(int address, Uint8List chunk);
  void features();
  void exit(int flags);
  void encrypt();
}
