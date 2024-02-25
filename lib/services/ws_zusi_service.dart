import 'package:Frontend/services/zusi_service.dart';
import 'package:Frontend/utilities/crc8.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsZusiService implements ZusiService {
  late final WebSocketChannel _channel;
  late final StreamQueue<Uint8List> _queue;

  WsZusiService(String domain) {
    debugPrint('WsZusiService ctor');
    _channel = WebSocketChannel.connect(Uri.parse('ws://$domain/zusi/'));
    _queue = StreamQueue(_channel.stream.cast<Uint8List>());
  }

  @override
  Future<void> ready() async {
    return _channel.ready;
  }

  @override
  void close() {
    debugPrint('WsZusiService close');
    _channel.sink.close();
  }

  @override
  Future<Uint8List> readCv(int address) async {
    List<int> data = [
      0x01, // Command
      0x00, // Count
      (address >> 24) & 0xFF, // Address
      (address >> 16) & 0xFF,
      (address >> 8) & 0xFF,
      (address >> 0) & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> writeCv(int address, int value) async {
    List<int> data = [
      0x02, // Command
      0x00, // Count
      (address >> 24) & 0xFF, // Address
      (address >> 16) & 0xFF,
      (address >> 8) & 0xFF,
      (address >> 0) & 0xFF,
      value & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> eraseZpp() async {
    List<int> data = [
      0x04, // Command
      0x55,
      0xAA,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> writeZpp(int address, Uint8List chunk) async {
    assert(chunk.length <= 256);
    List<int> data = [
      0x05, // Command
      chunk.length - 1, // Count
      (address >> 24) & 0xFF, // Address
      (address >> 16) & 0xFF,
      (address >> 8) & 0xFF,
      (address >> 0) & 0xFF,
    ];
    data.addAll(chunk);

    // this should normally be zero?
    debugPrint('${268 - 1 - data.length}'); // TODO remove

    data.addAll(List<int>.filled(268 - 1 - data.length, 0xFF));
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> features() async {
    List<int> data = [
      0x06, // Command
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> exit(int flags) async {
    List<int> data = [
      0x07, // Command
      0x55,
      0xAA,
      flags & 0xFF,
    ];
    data.add(crc8(data));
    _channel.sink.add(Uint8List.fromList(data));
    return await _queue.next;
  }

  @override
  Future<Uint8List> encrypt() async {
    // TODO: implement encrypt
    throw UnimplementedError();
  }
}
