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

/// Data documentation
///
/// \file   data/doxygen.dart
/// \author Vincent Hamp
/// \date   11/06/2026

/// \page page_data Data
/// \tableofcontents
/// \todo Data
///
/// \section section_data_models Models
/// \todo Models
///
/// \subsection subsection_data_connection_status ConnectionStatus
/// \copydetails ConnectionStatus
///
/// \section section_data_repositories Repositories
///
/// \section section_data_services Services
/// Services come in the two categories HTTP or WebSockets (well, and Fakes).
///
/// \subsection subsection_architecture_http HTTP
/// HTTP is used where classic requests make sense and no bidirectional
/// communication is necessary. This applies, for example, to the API for adding
/// or deleting locomotives, changing device settings or querying the current
/// system status. The following endpoints are defined for HTTP.
/// - /dcc/locos/
///   - GET
///   - PUT
///   - DELETE
/// - /dcc/turnouts/
///   - GET
///   - PUT
///   - DELETE
/// - /dcc/
///   - GET
///   - POST
/// - /settings/
///   - GET
///   - POST
/// - /sys/
///   - GET
/// - /*
///   - GET
///
/// \subsubsection subsubsection_architecture_http_dcc DCC
/// \subsubsection subsubsection_architecture_http_settings %Settings
/// \subsubsection subsubsection_architecture_http_sys %Sys
///
/// \subsection subsection_architecture_ws WebSockets
/// WebSockets are used where fast bidirectional data communication is
/// necessary. This primarily affects all the different APIs for firmware and
/// sound updates, e.g. [DECUP](https://github.com/ZIMO-Elektronik/DECUP) or
/// [ZUSI](https://github.com/ZIMO-Elektronik/ZUSI), but also the
/// [Z21](https://github.com/ZIMO-Elektronik/Z21) endpoint. The following
/// endpoints are defined for WebSockets.
/// - /ota/
/// - /roco/z21/
/// - /zimo/decup/zpp/
/// - /zimo/decup/zsu/
/// - /zimo/mdu/zpp/
/// - /zimo/mdu/zsu/
/// - /zimo/zusi/
///
/// \subsubsection subsubsection_architecture_ws_ota OTA
/// \copydetails OtaService
///
/// \subsubsection subsubsection_architecture_ws_roco_z21 ROCO Z21
/// \copydetails Z21Service
///
/// \subsubsection subsubsection_architecture_ws_zimo_decup ZIMO DECUP
/// \copydetails DecupService
///
/// \subsubsection subsubsection_architecture_ws_zimo_mdu ZIMO MDU
/// \copydetails MduService
///
/// \subsubsection subsubsection_architecture_ws_zimo_zusi ZIMO ZUSI
/// \copydetails ZusiService
///
///
/// <div class="section_buttons">
/// | Previous         | Next            |
/// | :--------------- | --------------: |
/// | \ref page_domain | \ref page_utils |
/// </div>
