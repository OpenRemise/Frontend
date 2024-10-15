import 'dart:async';

import 'package:Frontend/models/loco.dart';
import 'package:Frontend/providers/locos.dart';
import 'package:Frontend/services/fake_sys_service.dart';
import 'package:Frontend/services/z21_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeZ21Service implements Z21Service {
  final _controller = StreamController<Uint8List>();
  late final Stream<Command> _stream;
  final ProviderContainer ref;

  FakeZ21Service(this.ref) {
    _stream = _controller.stream.asBroadcastStream().map(Z21Service.convert);
  }

  @override
  Future<void> get ready => Future.delayed(const Duration(seconds: 1));

  @override
  Stream<Command> get stream => _stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _controller.sink.close();

  @override
  void lanXGetStatus() {
    // TODO: implement lanXGetStatus
  }

  @override
  void lanXSetTrackPowerOff() {
    state = State.Suspend;
    Future.delayed(const Duration(seconds: 1), () => state = State.Suspended);
  }

  @override
  void lanXSetTrackPowerOn() {
    state = State.DCCOperations;
  }

  @override
  void lanXCvRead(int cvAddress) {
    // TODO: implement lanXCvRead
  }

  @override
  void lanXCvWrite(int cvAddress, int value) {
    // TODO: implement lanXCvWrite
  }

  @override
  void lanXGetLocoInfo(int address) {
    final locos = ref.read(locosProvider);
    final loco = locos.firstWhere(
      (loco) => loco.address == address,
      orElse: () => Loco(address: address, name: address.toString()),
    );
    debugPrint('lanXGetLocoInfo $loco');
  }

  @override
  void lanXSetLocoDrive(int address, int speedSteps, int rvvvvvvv) {
    // TODO: implement lanXSetLocoDrive
  }

  @override
  void lanXSetLocoFunction(int address, int state, int index) {
    // TODO: implement lanXSetLocoFunction
  }

  @override
  void lanXCvPomWriteByte(int address, int cvAddress, int value) {
    // TODO: implement lanXCvPomWriteByte
  }

  @override
  void lanXCvPomReadByte(int address, int cvAddress) {
    // TODO: implement lanXCvPomReadByte
  }

  @override
  void lanSystemStateGetData() {
    // TODO: implement lanSystemStateGetData
  }
}
