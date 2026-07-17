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

/// Reads [key] from [json] and normalizes it to a list
///
/// Applies [_asList] to handle both single objects and arrays.
Object? readAsList(Map json, String key) {
  return _asList(json[key]);
}

/// Reads [key] from [json] only if the value is a map, otherwise returns null
Object? readAsSingle(Map json, String key) {
  final value = json[key];
  if (value is Map) return value;
  return null;
}

/// Reads [key] from [json], applies [_unwrapMap], and normalizes to a list
///
/// Flattens `{"key": [...]}` down to the inner list.
Object? readNestedAsList(Map json, String key) {
  final outer = json[key];
  if (outer is Map && outer.length == 1) {
    return _asList(outer[outer.keys.first]);
  }
  return <dynamic>[];
}

/// Unwraps a single-element array containing a single-key map into a list
///
/// Applies [_unwrapList], [_unwrapMap], and [_asList] in sequence to flatten
/// structures like `[{"key": [...]}]` down to the inner list.
Object? readWrappedAsList(Map json, String key) {
  return _asList(_unwrapMap(_unwrapList(json[key])));
}

/// `null` → `[]`, `[...]` → `[...]`, `x` → `[x]`
List<dynamic> _asList(Object? value) {
  if (value == null) return <dynamic>[];
  if (value is List) return value;
  return <dynamic>[value];
}

/// `[x]` → `x`, otherwise identity
Object? _unwrapList(Object? value) {
  if (value is List && value.length == 1) return value.first;
  return value;
}

/// `{"k": v}` → `v`, otherwise identity
Object? _unwrapMap(Object? value) {
  if (value is Map && value.length == 1) return value[value.keys.first];
  return value;
}
