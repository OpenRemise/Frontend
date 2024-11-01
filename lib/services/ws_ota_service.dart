import 'package:Frontend/services/ota_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsOtaService implements OtaService {
  late final WebSocketChannel _channel;

  WsOtaService(String domain) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$domain/ota/'));
  }

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Uint8List> get stream => _channel.stream.cast<Uint8List>();

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  @override
  void write(Uint8List chunk) {
    _channel.sink.add(chunk);
  }
}
