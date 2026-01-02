// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_test_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Test package for decode_top
//=============================================================================

`ifndef DECODE_TOP_TEST_PKG_SV
`define DECODE_TOP_TEST_PKG_SV

package decode_top_test_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  import decode_in_pkg::*;
  import decode_wb_pkg::*;
  import decode_out_pkg::*;
  import decode_top_pkg::*;

  `include "decode_top_test.sv"

endpackage : decode_top_test_pkg

`endif // DECODE_TOP_TEST_PKG_SV

