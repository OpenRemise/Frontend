import 'dart:typed_data';

abstract class OtaService {
  static const int ack = 0x06;
  static const int nak = 0x15;
  Future<void> ready();
  void close();
  Future<Uint8List> write(Uint8List chunk);
}
