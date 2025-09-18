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

import 'package:Frontend/constant/key_codes.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

/// \todo document
class CvEditingController extends RichTextController {
  static const String _read = 'R';
  static const String _write = 'W';
  static const String _error = 'E';
  static const String _equal = ':::';
  static const String _pending = '!';

  /// \todo document
  CvEditingController()
      : super(
          targetMatches: [
            MatchTargetItem(
              regex: RegExp('$_read.*'),
              style: TextStyle(color: Colors.blue),
            ),
            MatchTargetItem(
              regex: RegExp('$_write.*'),
              style: TextStyle(color: Colors.green),
            ),
            MatchTargetItem(
              regex: RegExp('$_error.*'),
              style: TextStyle(color: Colors.red),
            ),
          ],
          onMatch: (_) {},
        );

  /// \todo document
  void appendKeyCode(int keyCode) {
    //
    if (keyCode == KeyCodes.backspaceLong) {
      return _clear();
    }

    final lines = text.split('\n');

    //
    if (lines.last.endsWith(_pending)) {
      return;
    } else if (lines.last.isEmpty) {
      lines.last = '? ';
    }

    final cv = values();

    switch (keyCode) {
      // Add to CV number or value
      case >= KeyCodes.f0 && <= KeyCodes.f63:
        final add = keyCode % 10;

        // Value
        if (lines.last.contains(_equal)) {
          // Multiple leading zeros or range
          if (cv.value != null &&
              (cv.value == 0 || cv.value! * 10 + add > 255)) {
            return;
          }
        }
        // Number
        else {
          // Leading zero or range
          if ((cv.number == null && add == 0) ||
              (cv.number != null && cv.number! * 10 + add > 1024)) {
            return;
          }
        }

        lines.last += add.toString();
        break;

      // Remove from CV number or value
      case KeyCodes.backspace:
        // Don't remove prefix
        if (lines.last.length <= 2) {
          return;
        }
        // Remove equal
        else if (lines.last.endsWith(_equal)) {
          lines.last =
              lines.last.substring(0, lines.last.length - _equal.length);
        }
        // Remove one digit
        else {
          lines.last = lines.last.substring(0, lines.last.length - 1);
        }
        break;

      // Apply
      case KeyCodes.enter:
      case KeyCodes.enterLong:
        // Do nothing
        if (cv.number == null) {
          return;
        }
        // Got number, first enter adds equal
        else if (cv.value == null && !lines.last.contains(_equal)) {
          lines.last += _equal;
        }
        // Got value, second enter adds !
        else {
          lines.last += _pending;
        }
        break;
    }

    var newText = lines.join('\n');
    if (text != newText) text = newText;
  }

  /// \todo document
  void success(int cvValue) {
    final lines = text.split('\n');

    //
    if (!lines.last.endsWith(_pending)) return;

    //
    lines.last = lines.last.replaceFirst(_pending, '');

    //
    final cv = values();
    lines.last = lines.last.replaceFirst('?', cv.value == null ? 'R' : 'W');

    // Only append value if we haven't gotten one yet
    if (cv.value == null) lines.last += cvValue.toString();

    lines.last += '\n';
    text = lines.join('\n');
  }

  /// \todo document
  void error() {
    final lines = text.split('\n');

    //
    if (!lines.last.endsWith(_pending)) return;

    //
    lines.last = lines.last.replaceFirst(_pending, '');

    //
    lines.last = lines.last.replaceFirst('?', 'E');

    lines.last += '\n';
    text = lines.join('\n');
  }

  /// \todo document
  ({int? number, int? value}) values() {
    final lines = text.split('\n');
    RegExp exp = RegExp(r'[0-9]+');
    final matches = exp.allMatches(lines.last);
    final numberStr = matches.elementAtOrNull(0)?.group(0);
    final valueStr = matches.elementAtOrNull(1)?.group(0);
    return (
      number: numberStr == null ? null : int.parse(numberStr),
      value: valueStr == null ? null : int.parse(valueStr)
    );
  }

  /// \todo document
  void _clear() {
    final lines = text.split('\n');
    lines.last = '';
    var newText = lines.join('\n');
    if (text != newText) text = newText;
  }
}
