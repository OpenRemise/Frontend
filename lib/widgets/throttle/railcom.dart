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

import 'package:Frontend/models/loco.dart';
import 'package:Frontend/services/roco/z21_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// \todo document
class RailCom extends ConsumerStatefulWidget {
  final Loco loco;

  const RailCom({super.key, required this.loco});

  @override
  ConsumerState<RailCom> createState() => RailComState();
}

/// \todo document
class RailComState extends ConsumerState<RailCom> {
  double _kmhOpacity = 0.0;
  double _qosOpacity = 0.0;

  /// \todo document
  @override
  void initState() {
    super.initState();
    final railComData = _railComData();
    _kmhOpacity = railComData.kmh() != null ? 1.0 : 0.0;
    _qosOpacity = railComData.qoS() != null ? 1.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final railComData = _railComData();

    if (_kmhOpacity == 0.0 && railComData.kmh() != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _kmhOpacity = 1.0));
    }

    if (_qosOpacity == 0.0 && railComData.qoS() != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _qosOpacity = 1.0));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedOpacity(
          opacity: _kmhOpacity,
          duration: const Duration(milliseconds: 500),
          child: Row(
            children: [
              const Icon(Icons.speed),
              const SizedBox(width: 4),
              Text(
                (railComData.kmh() ?? 0).toString().padLeft(3, '0'),
                style: const TextStyle(fontFamily: 'DSEG14'),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: _qosOpacity,
          duration: const Duration(milliseconds: 500),
          child: Row(
            children: [
              const Icon(Icons.network_check),
              const SizedBox(width: 4),
              Text(
                (railComData.qoS() ?? 0).toString().padLeft(3, '0'),
                style: const TextStyle(fontFamily: 'DSEG14'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LanRailComDataChanged _railComData() {
    return LanRailComDataChanged(
      locoAddress: widget.loco.address,
      receiveCounter: widget.loco.bidi?.receiveCounter ?? 0,
      errorCounter: widget.loco.bidi?.errorCounter ?? 0,
      options: widget.loco.bidi?.options ?? 0,
      speed: widget.loco.bidi?.speed ?? 0,
      qos: widget.loco.bidi?.qos ?? 0,
    );
  }
}
