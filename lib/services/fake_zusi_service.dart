import 'dart:async';

import 'package:Frontend/constants/ack.dart';
import 'package:Frontend/services/zusi_service.dart';
import 'package:flutter/foundation.dart';

class FakeZusiService implements ZusiService {
  final _controller = StreamController<Uint8List>();

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      Future.delayed(Duration.zero);

  @override
  void readCv(int address) {
    // TODO: implement readCv
    throw UnimplementedError();
  }

  @override
  void writeCv(int address, int value) {
    // TODO: implement writeCv
    throw UnimplementedError();
  }

  @override
  void eraseZpp() async {
    await Future.delayed(const Duration(seconds: 10), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ack]));
    });
  }

  @override
  void writeZpp(int address, Uint8List chunk) async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ack]));
    });
  }

  @override
  void features() async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([6, 251, 255, 255, 127, 147]));
    });
  }

  @override
  void exit(int flags) async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ack]));
    });
  }

  @override
  void encrypt() {
    // TODO: implement encrypt
    throw UnimplementedError();
  }
}
