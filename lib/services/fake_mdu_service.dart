import 'package:Frontend/services/mdu_service.dart';
import 'package:flutter/foundation.dart';

class FakeMduService implements MduService {
  @override
  Future<void> ready() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void close() {
    debugPrint('FakeMduService close');
  }

  @override
  Future<Uint8List> ping(int serialNumber, int decoderId) async {
    return Uint8List.fromList([MduService.nak, MduService.ack]);
  }

  @override
  Future<Uint8List> configTransferRate(int transferRate) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Uint8List.fromList(
      [MduService.nak, transferRate < 3 ? MduService.ack : MduService.nak],
    );
  }

  @override
  Future<Uint8List> binaryTreeSearch(int byte) async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> busy() async {
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  @override
  Future<Uint8List> firmwareSalsa20IV(Uint8List iv) async {
    assert(iv.length == 8);
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  @override
  Future<Uint8List> firmwareErase(int beginAddress, int endAddress) async {
    await Future.delayed(const Duration(seconds: 5));
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  @override
  Future<Uint8List> firmwareUpdate(int address, Uint8List chunk) async {
    assert(chunk.length == 64);
    await Future.delayed(const Duration(milliseconds: 5));
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  @override
  Future<Uint8List> firmwareCrc32Start(
    int beginAddress,
    int endAddress,
    int crc32,
  ) async {
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  @override
  Future<Uint8List> firmwareCrc32Result() async {
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }

  @override
  Future<Uint8List> firmwareCrc32ResultExit() async {
    return Uint8List.fromList([MduService.nak, MduService.nak]);
  }
}
