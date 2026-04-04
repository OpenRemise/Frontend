// Copyright (C) 2025 Vincent Hamp
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:Frontend/service/roco/z21_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsZ21Service implements Z21Service {
  late final WebSocketChannel _channel;
  late final Stream<Z21Command> _stream;

  WsZ21Service(String domain) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$domain/roco/z21/'));
    _channel.ready.then(
      (_) => this(
        LanSetBroadcastFlags(
          broadcastFlags: BroadcastFlags.fromList([
            BroadcastFlag.DrivingSwitching,
            BroadcastFlag.RBus,
            BroadcastFlag.LocoNet,
            BroadcastFlag.LocoNetDetector,
          ]),
        ),
      ),
      // May potentially throw, catch errors
      onError: (_) {},
    );
    _stream = _channel.stream
        .asBroadcastStream()
        .cast<Uint8List>()
        .map(Z21Service.convert);
  }

  @override
  int? get closeCode => _channel.closeCode;

  @override
  String? get closeReason => closeCode != null ? 'Timeout' : null;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Z21Command> get stream => _stream;

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  @override
  void call(Z21Command cmd) {
    _channel.sink.add(cmd.toUint8List());
  }
}
