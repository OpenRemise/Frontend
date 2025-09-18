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

/// Turnout map
///
/// \file   constant/turnout_map.dart
/// \author Vincent Hamp
/// \date   09/11/2025

/// Turnout map
///
/// \ref turnoutMap maps the type enumeration of turnouts to their assets. This
/// allows the app to display the correct asset for the state based on the
/// turnout positions.
const turnoutMap =
    <int, ({String label, String previewAsset, List<String> assets})>{
  // Special
  0 + 0: (
    label: 'Unknown',
    previewAsset: 'data/images/unknown.svg',
    assets: [
      'data/images/unknown.svg',
      'data/images/unknown.svg',
    ]
  ),
  0 + 1: (
    label: 'Hidden',
    previewAsset: 'data/images/hidden.svg',
    assets: [
      'data/images/hidden.svg',
      'data/images/hidden.svg',
    ]
  ),

  // Track (move)
  256 + 0: (
    label: 'Turnout right',
    previewAsset: 'data/images/turnouts/right_0.svg',
    assets: [
      'data/images/turnouts/right_0.svg',
      'data/images/turnouts/right_1.svg',
    ]
  ),
  256 + 1: (
    label: 'Turnout left',
    previewAsset: 'data/images/turnouts/left_0.svg',
    assets: [
      'data/images/turnouts/left_0.svg',
      'data/images/turnouts/left_1.svg',
    ]
  ),
  256 + 2: (
    label: 'Turnout Y',
    previewAsset: 'data/images/turnouts/y_0.svg',
    assets: [
      'data/images/turnouts/y_0.svg',
      'data/images/turnouts/y_1.svg',
    ]
  ),
  256 + 3: (
    label: 'Turnout 3-way',
    previewAsset: 'data/images/turnouts/3way_0.svg',
    assets: [
      'data/images/turnouts/3way_0.svg',
      'data/images/turnouts/3way_1.svg',
      'data/images/turnouts/3way_2.svg',
    ]
  ),

  // Signal (guide)
  512 + 0: (
    label: 'Signal 2 aspects',
    previewAsset: 'data/images/signals/2_lights.svg',
    assets: [
      'data/images/signals/2_lights_0.svg',
      'data/images/signals/2_lights_1.svg',
    ]
  ),
  512 + 1: (
    label: 'Signal 3 aspects',
    previewAsset: 'data/images/signals/3_lights.svg',
    assets: [
      'data/images/signals/3_lights_0.svg',
      'data/images/signals/3_lights_1.svg',
      'data/images/signals/3_lights_2.svg',
    ]
  ),
  512 + 2: (
    label: 'Signal 4 aspects',
    previewAsset: 'data/images/signals/4_lights.svg',
    assets: [
      'data/images/signals/4_lights_0.svg',
      'data/images/signals/4_lights_1.svg',
      'data/images/signals/4_lights_2.svg',
      'data/images/signals/4_lights_3.svg',
    ]
  ),
  512 + 3: (
    label: 'Signal blocking',
    previewAsset: 'data/images/signals/blocking_0.svg',
    assets: [
      'data/images/signals/blocking_0.svg',
      'data/images/signals/blocking_1.svg',
    ]
  ),
  512 + 4: (
    label: 'Signal semaphore',
    previewAsset: 'data/images/signals/semaphore_0.svg',
    assets: [
      'data/images/signals/semaphore_0.svg',
      'data/images/signals/semaphore_1.svg',
      'data/images/signals/semaphore_2.svg',
    ]
  ),

  // Scenery (world)
  768 + 0: (
    label: 'Light',
    previewAsset: 'data/images/light_0.svg',
    assets: [
      'data/images/light_0.svg',
      'data/images/light_1.svg',
    ]
  ),
  768 + 1: (
    label: 'Crossing gate',
    previewAsset: 'data/images/crossing_gate_0.svg',
    assets: [
      'data/images/crossing_gate_0.svg',
      'data/images/crossing_gate_1.svg',
    ]
  ),
  768 + 2: (
    label: 'Relay',
    previewAsset: 'data/images/relay_0.svg',
    assets: [
      'data/images/relay_0.svg',
      'data/images/relay_1.svg',
    ]
  ),
};
