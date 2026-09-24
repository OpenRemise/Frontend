// Copyright (C) 2026 Vincent Hamp
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

/// Dialog to detect decoder using DecoderDB
///
/// \file   ui/program/widgets/decoder_detection_dialog.dart
/// \author Vincent Hamp
/// \date   27/03/2026

import 'package:Frontend/domain/models/decoder.dart';
import 'package:Frontend/ui/core/widgets/default_animated_size.dart';
import 'package:Frontend/ui/core/widgets/ignore_intrinsics.dart';
import 'package:Frontend/ui/program/view_models/decoder_detection_state.dart';
import 'package:Frontend/ui/program/view_models/decoder_detection_view_model.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final List<String> imgList = [
  'https://decoderdb.bidib.org/decoder/145/images/MS450P22_persp.webp',
  'https://decoderdb.bidib.org/decoder/145/images/MS450P22_top.webp',
  'https://decoderdb.bidib.org/decoder/145/images/MS450P22_bottom.webp',
];

///
class DecoderDetectionDialog extends ConsumerStatefulWidget {
  final Decoder decoder;

  const DecoderDetectionDialog({super.key, required this.decoder});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DecoderDetectionDialogState();
}

/// \todo document
class _DecoderDetectionDialogState
    extends ConsumerState<DecoderDetectionDialog> {
  /// \todo document
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(
            decoderDetectionViewModelProvider(widget.decoder).notifier,
          )
          .detect()
          .catchError((_) {}),
    );
  }

  /// \todo document
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decoderDetectionViewModelProvider(widget.decoder));

    return AlertDialog(
      title: const Text('DecoderDB'),
      content: DefaultAnimateSize(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.decoderDefinition == null
              ? progressStatusWidgets(state)
              : decoderDataWidgets(state),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            state.status == DecoderDetectionStatus.Completed ? 'OK' : 'Cancel',
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        side: Divider.createBorderSide(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// \todo document
  List<Widget> progressStatusWidgets(DecoderDetectionState state) {
    return [
      LinearProgressIndicator(value: state.progress),
      Text(state.message),
    ];
  }

  /// \todo document
  List<Widget> decoderDataWidgets(DecoderDetectionState state) {
    return [
      Table(
        children: [
          TableRow(
            children: [
              Text('Name'),
              Text(state.decoderDefinition!.decoder.name),
            ],
          ),
          TableRow(
            children: [
              Text('Type'),
              Text(state.decoderDefinition!.decoder.type),
            ],
          ),
        ],
      ),
      /*
      loco
      loco-sound
      function
      function-sound
      car
      car-sound
      susi
      susi-sound
      standardAccessory
      extendedAccessory
      */
      IgnoreIntrinsics(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Swiper(
            itemBuilder: (context, index) {
              return Image.network(
                'https://decoderdb.bidib.org/decoder/145/images/MS450P22_persp.webp',
              );
            },
            itemCount: 3,
            control: SwiperControl(
              color: Theme.of(context).colorScheme.onSurface,
              disableColor: Theme.of(context).disabledColor,
            ),
            loop: false,
          ),
        ),
      ),
    ];
  }

  /// \todo document
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
