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

import 'package:Frontend/data/models/decoderdb/decoder_definition.dart';

List<DecoderImage> filterDuplicateImages(List<DecoderImage> images) {
  final result = <String, DecoderImage>{};

  int priority(String? source) {
    final extension = source?.split('.').last.toLowerCase();

    return switch (extension) {
      'webp' => 3,
      'png' => 2,
      'jpg' || 'jpeg' => 1,
      _ => 0,
    };
  }

  String key(String source) {
    final lastDot = source.lastIndexOf('.');
    return lastDot == -1 ? source : source.substring(0, lastDot);
  }

  for (final image in images) {
    final source = image.source;

    // No source -> can't determine duplicates.
    if (source == null) {
      result[image.name] = image;
      continue;
    }

    final imageKey = key(source);
    final existing = result[imageKey];

    if (existing == null || priority(source) > priority(existing.source)) {
      result[imageKey] = image;
    }
  }

  return result.values.toList();
}

bool insideValueSpec(int cv, String valuesString) {
  return valuesString.split(';').any((part) {
    final bounds = part.trim().split('-');
    if (bounds.length == 1) {
      return cv == int.parse(bounds[0]);
    }
    final min = int.parse(bounds[0]);
    final max = int.parse(bounds[1]);
    return cv >= min && cv <= max;
  });
}

String parseDisplayFormat(String format, List<int> values) {
  final out = StringBuffer();

  int pos = 0;

  while (pos < format.length) {
    if (format[pos] != '{') {
      out.write(format[pos]);
      pos++;
      continue;
    }

    final end = format.indexOf('}', pos);

    if (end < 0) {
      throw const FormatException('Missing }');
    }

    final parts = format.substring(pos + 1, end).split(':');

    int value = values[int.parse(parts[0])];

    if (parts.length == 1) {
      out.write(value);
      pos = end + 1;
      continue;
    }

    String? text;

    for (int i = 1; i < parts.length; ++i) {
      var formatter = parts[i];

      if (formatter.startsWith('M0x')) {
        if (text != null) {
          value = int.parse(text, radix: 16);
          text = null;
        }

        final mask = int.parse(formatter.substring(3), radix: 16);

        value = _applyHexMask(value, mask);
      } else if (formatter.startsWith('M0d')) {
        if (text != null) {
          value = int.parse(text);
          text = null;
        }

        value = _applyDecimalMask(
          value,
          formatter.substring(3),
        );
      } else if (formatter == 'X') {
        text = value.toRadixString(16).toUpperCase();
      } else {
        if (formatter.startsWith('F')) {
          formatter = formatter.substring(1);
        }

        text ??= value.toString();

        text = _applyNumberPattern(text, formatter);
      }
    }

    out.write(text ?? value);
    pos = end + 1;
  }

  return out.toString();
}

String _applyNumberPattern(String input, String pattern) {
  final result = List<String>.filled(pattern.length, '');

  int digit = input.length - 1;

  for (int i = pattern.length - 1; i >= 0; i--) {
    switch (pattern[i]) {
      case '0':
        if (digit >= 0) {
          result[i] = input[digit--];
        } else {
          result[i] = '0';
        }
        break;

      case '#':
        if (digit >= 0) {
          result[i] = input[digit--];
        }
        break;

      default:
        result[i] = pattern[i];
    }
  }

  if (digit >= 0) {
    return input.substring(0, digit + 1) + result.join();
  }

  return result.join();
}

int _applyHexMask(int value, int mask) {
  value &= mask;

  int shift = 0;
  while (((mask >> shift) & 1) == 0 && shift < 32) {
    shift++;
  }

  return value >> shift;
}

int _applyDecimalMask(int value, String mask) {
  final digits = value.toString();

  final result = StringBuffer();

  final offset = mask.length - digits.length;

  for (int i = 0; i < mask.length; ++i) {
    final digitIndex = i - offset;

    if (digitIndex >= 0 && digitIndex < digits.length && mask[i] == '1') {
      result.write(digits[digitIndex]);
    }
  }

  return result.isEmpty ? 0 : int.parse(result.toString());
}
