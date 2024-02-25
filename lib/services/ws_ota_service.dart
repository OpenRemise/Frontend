import 'package:Frontend/services/ota_service.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsOtaService implements OtaService {
  late final WebSocketChannel _channel;
  late final StreamQueue<Uint8List> _queue;

  WsOtaService(String domain) {
    debugPrint('WsOtaService ctor');
    _channel = WebSocketChannel.connect(Uri.parse('ws://$domain/ota/'));
    _queue = StreamQueue(_channel.stream.cast<Uint8List>());
  }

  @override
  Future<void> ready() async {
    return _channel.ready;
  }

  @override
  void close() {
    debugPrint('WsOtaService close');
    _channel.sink.close();
  }

  @override
  Future<Uint8List> write(Uint8List chunk) async {
    try {
      _channel.sink.add(chunk);
      return await _queue.next;
    } catch (e) {
      return Uint8List.fromList([OtaService.nak]);
    }
  }
}
