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

import 'package:Frontend/constants/key_codes.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

/// \todo document
class CvEditingController extends RichTextController {
  static const String _equal = ':::';

  /// \todo document
  CvEditingController({required super.targetMatches}) : super(onMatch: (_) {});

  /// \todo document
  void appendKeyCode(int keyCode) {
    final lines = text.split('\n');

    //
    if (lines.last.endsWith('!')) return;

    if (lines.last.isEmpty) lines.last = '? ';

    final number = cvNumber();
    final value = cvValue();

    switch (keyCode) {
      // Add to CV number or value
      case >= KeyCodes.f0 && <= KeyCodes.f63:
        final add = keyCode % 10;

        // Value
        if (lines.last.contains(_equal)) {
          // Leading zero or range
          if ((value == null && add == 0) ||
              (value != null && value * 10 + add > 255)) {
            return;
          }
        }
        // Number
        else {
          // Leading zero or range
          if ((number == null && add == 0) ||
              (number != null && number * 10 + add > 1024)) {
            return;
          }
        }

        lines.last += add.toString();
        break;

      // Remove from CV number or value
      case KeyCodes.backspace:
        //
        if (lines.last.length <= 2) {
          return;
        }
        //
        else if (lines.last.endsWith(_equal)) {
          lines.last =
              lines.last.substring(0, lines.last.length - _equal.length);
        }
        //
        else {
          lines.last = lines.last.substring(0, lines.last.length - 1);
        }
        break;

      // Apply
      case KeyCodes.enter:
      case KeyCodes.enterLong:
        // Do nothing
        if (number == null) {
          return;
        }
        // Got number, add equal
        else if (value == null && !lines.last.contains(_equal)) {
          lines.last += _equal;
        }
        // Got value
        else {
          lines.last += '!';
        }
        break;
    }

    var newText = lines.join('\n');
    if (text != newText) text = newText;
  }

  /// \todo document
  void prepend(String str) {
    final lines = text.split('\n');
    lines.last = lines.last.replaceFirst('!', '');
    lines.last = lines.last.replaceFirst('?', str);
    text = lines.join('\n');
  }

  /// \todo document
  void append(String str) {
    final lines = text.split('\n');
    lines.last = lines.last.replaceFirst('!', '');
    lines.last += str;
    text = lines.join('\n');
  }

  int? cvNumber() {
    final str = _matches().elementAtOrNull(0)?.group(0);
    return str == null ? null : int.parse(str);
  }

  int? cvValue() {
    final str = _matches().elementAtOrNull(1)?.group(0);
    return str == null ? null : int.parse(str);
  }

  Iterable<RegExpMatch> _matches() {
    final lines = text.split('\n');
    RegExp exp = RegExp(r'[0-9]+');
    return exp.allMatches(lines.last);
  }
}
