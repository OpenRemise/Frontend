import 'package:Frontend/services/zusi_service.dart';
import 'package:flutter/foundation.dart';

class FakeZusiService implements ZusiService {
  @override
  Future<void> ready() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void close() {
    debugPrint('FakeZusiService close');
  }

  @override
  Future<Uint8List> readCv(int address) async {
    // TODO: implement readCv
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> writeCv(int address, int value) async {
    // TODO: implement writeCv
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> eraseZpp() async {
    await Future.delayed(const Duration(seconds: 10));
    return Uint8List.fromList([ZusiService.ack]);
  }

  @override
  Future<Uint8List> writeZpp(int address, Uint8List chunk) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Uint8List.fromList([ZusiService.ack]);
  }

  @override
  Future<Uint8List> features() async {
    await Future.delayed(const Duration(seconds: 2));
    return Uint8List.fromList([6, 251, 255, 255, 127, 147]);
  }

  @override
  Future<Uint8List> exit(int flags) async {
    await Future.delayed(const Duration(seconds: 2));
    return Uint8List.fromList([ZusiService.ack]);
  }

  @override
  Future<Uint8List> encrypt() async {
    // TODO: implement encrypt
    throw UnimplementedError();
  }
}
