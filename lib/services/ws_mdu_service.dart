import 'package:Frontend/services/mdu_service.dart';
import 'package:Frontend/utilities/crc32.dart';
import 'package:Frontend/utilities/crc8.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsMduService implements MduService {
  late final WebSocketChannel _channel;
  late final StreamQueue<Uint8List> _queue;

  WsMduService(String domain) {
    debugPrint('WsMduService ctor');
    _channel =
        WebSocketChannel.connect(Uri.parse('ws://$domain/mdu/firmware/'));
    _queue = StreamQueue(_channel.stream.cast<Uint8List>());
  }

  @override
  Future<void> ready() async {
    return _channel.ready;
  }

  @override
  void close() {
    debugPrint('WsMduService close');
    _channel.sink.close();
  }

  @override
  Future<Uint8List> ping(int serialNumber, int decoderId) async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFF,
      (serialNumber >> 24) & 0xFF,
      (serialNumber >> 16) & 0xFF,
      (serialNumber >> 8) & 0xFF,
      (serialNumber >> 0) & 0xFF,
      (decoderId >> 24) & 0xFF,
      (decoderId >> 16) & 0xFF,
      (decoderId >> 8) & 0xFF,
      (decoderId >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> configTransferRate(int transferRate) async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFE,
      transferRate & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> binaryTreeSearch(int byte) async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFA,
      byte & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> busy() async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF2,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> firmwareSalsa20IV(Uint8List iv) async {
    assert(iv.length == 8);
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF7,
    ];
    data.addAll(iv);
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> firmwareErase(int beginAddress, int endAddress) async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF5,
      (beginAddress >> 24) & 0xFF,
      (beginAddress >> 16) & 0xFF,
      (beginAddress >> 8) & 0xFF,
      (beginAddress >> 0) & 0xFF,
      (endAddress >> 24) & 0xFF,
      (endAddress >> 16) & 0xFF,
      (endAddress >> 8) & 0xFF,
      (endAddress >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> firmwareUpdate(int address, Uint8List chunk) async {
    assert(chunk.length == 64);
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xF8,
      (address >> 24) & 0xFF,
      (address >> 16) & 0xFF,
      (address >> 8) & 0xFF,
      (address >> 0) & 0xFF,
    ];
    data.addAll(chunk);
    final int crc = crc32(data);
    data.addAll([
      (crc >> 24) & 0xFF,
      (crc >> 16) & 0xFF,
      (crc >> 8) & 0xFF,
      (crc >> 0) & 0xFF,
    ]);
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> firmwareCrc32Start(
    int beginAddress,
    int endAddress,
    int crc32,
  ) async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFB,
      (beginAddress >> 24) & 0xFF,
      (beginAddress >> 16) & 0xFF,
      (beginAddress >> 8) & 0xFF,
      (beginAddress >> 0) & 0xFF,
      (endAddress >> 24) & 0xFF,
      (endAddress >> 16) & 0xFF,
      (endAddress >> 8) & 0xFF,
      (endAddress >> 0) & 0xFF,
      (crc32 >> 24) & 0xFF,
      (crc32 >> 16) & 0xFF,
      (crc32 >> 8) & 0xFF,
      (crc32 >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> firmwareCrc32Result() async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFC,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> firmwareCrc32ResultExit() async {
    List<int> data = [
      0xFF, // Command
      0xFF,
      0xFF,
      0xFD,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }
}
