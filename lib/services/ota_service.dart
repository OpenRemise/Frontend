import 'dart:typed_data';

abstract interface class OtaService {
  Future<void> get ready;
  Stream<Uint8List> get stream;
  Future close([int? closeCode, String? closeReason]);

  void write(Uint8List chunk);
}
