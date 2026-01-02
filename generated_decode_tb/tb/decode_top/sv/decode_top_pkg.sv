// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Package for decode_top
//=============================================================================

package decode_top_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  import decode_in_pkg::*;
  import decode_wb_pkg::*;
  import decode_out_pkg::*;
  import common::*;

  `include "decode_scoreboard.sv"
  `include "decode_top_config.sv"
  `include "decode_top_seq_lib.sv"
  `include "decode_top_env.sv"

endpackage : decode_top_pkg

