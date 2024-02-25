import 'package:Frontend/services/ota_service.dart';
import 'package:flutter/foundation.dart';

class FakeOtaService implements OtaService {
  @override
  Future<void> ready() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void close() {
    debugPrint('FakeOtaService close');
  }

  @override
  Future<Uint8List> write(Uint8List chunk) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return Uint8List.fromList([OtaService.ack]);
  }
}
