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

/// UI documentation
///
/// \file   ui/doxygen.dart
/// \author Vincent Hamp
/// \date   11/06/2026

/// \page page_ui UI
/// \tableofcontents
/// The entire app is divided into 5 screens, created in a responsive layout.
/// Depending on the screen width, all screens can be accessed either via a
/// [NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html)
/// or -[rail](https://api.flutter.dev/flutter/material/NavigationRail-class.html).
/// The screen width at which switching between the two widgets takes place is
/// set in the variable \ref smallScreenWidth, which in turn is set by the
/// environment variable `OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH` during build.
///
/// \section section_info Info
/// \copydetails InfoScreen
///
/// \section section_decoders Decoders
/// \copydetails DecodersScreen
///
/// \section section_program Program
/// \copydetails ProgramScreen
///
/// \section section_update Update
/// \copydetails UpdateScreen
///
/// \section section_settings %Settings
/// \copydetails SettingsScreen
///
/// <div class="section_buttons">
/// | Previous                | Next             |
/// | :---------------------- | ---------------: |
/// | \ref page_api_reference | \ref page_domain |
/// </div>
