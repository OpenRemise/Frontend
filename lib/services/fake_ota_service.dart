import 'dart:async';

import 'package:Frontend/constants/ack.dart';
import 'package:Frontend/services/ota_service.dart';
import 'package:flutter/foundation.dart';

class FakeOtaService implements OtaService {
  final _controller = StreamController<Uint8List>();

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _controller.sink.close();

  @override
  void write(Uint8List chunk) async {
    await Future.delayed(const Duration(milliseconds: 50), () {
      if (_controller.isClosed) return;
      _controller.sink.add(Uint8List.fromList([ack]));
    });
  }
}
