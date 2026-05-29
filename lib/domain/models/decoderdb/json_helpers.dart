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

/// Normalizes a JSON value that may be a single object or a list into a list
///
/// XML-to-JSON conversions often collapse single-element arrays into plain
/// objects. This helper ensures the value is always a list for consistent
/// deserialization.
Object? readAsList(Map json, String key) {
  final value = json[key];
  if (value == null) return <dynamic>[];
  if (value is List) return value;
  return <dynamic>[value];
}

/// Returns the value only if it's a map, otherwise null
///
/// Some fields are either an object or an empty list in the JSON. This helper
/// treats an empty list (or any non-map value) as null.
Object? readAsSingle(Map json, String key) {
  final value = json[key];
  if (value is Map) return value;
  return null;
}

/// Flattens a single-key wrapper object into a list
///
/// For JSON structures like `"protocols": { "protocol": [...] }`, this
/// unwraps the single inner key and applies [readAsList] normalization.
Object? readNestedAsList(Map json, String key) {
  final outer = json[key];
  if (outer is Map && outer.length == 1) {
    return readAsList(outer, outer.keys.first);
  }
  return <dynamic>[];
}
