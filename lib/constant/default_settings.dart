// Copyright (C) 2025 Vincent Hamp
// Copyright (C) 2025 Franziska Walter
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

/// Default config Settings
class DefaultSettings {
  static const List<double> currentLimit = [0.5, 1.3, 2.7, 4.1];
  static const List<int> dccBiDiDurations = [0, 57, 58, 59, 60, 61];
  static const List<String> dccProgrammingTypes = [
    'Nothing',
    'Bit only',
    'Byte only',
    'Bit and byte',
  ];

  static Map<String, dynamic> values() => {
        'http_rx_timeout': 5.0,
        'http_tx_timeout': 5.0,
        'http_exit_msg': [true],
        'cur_lim': currentLimit.indexOf(4.1).toDouble(),
        'cur_lim_serv': currentLimit.indexOf(1.3).toDouble(),
        'cur_sc_time': 100.0,
        'led_dc_bug': 5.0,
        'led_dc_wifi': 50.0,
        'dcc_preamble': 17.0,
        'dcc_bit1_dur': 58.0,
        'dcc_bit0_dur': 100.0,
        'dcc_bidibit_dur': dccBiDiDurations.indexOf(60).toDouble(),
        'dcc_prog_type': dccProgrammingTypes.indexOf('Bit and byte').toDouble(),
        'dcc_strtp_rs_pc': 25.0,
        'dcc_cntn_rs_pc': 6.0,
        'dcc_verify_bit1': 1.0,
        'dcc_prog_pc': 7.0,
        'dcc_ack_cur': 50.0,
        'dcc_loco_flags': [0x80, 0x40, 0x20],
        'dcc_accy_flags': [0x04],
      };
}
