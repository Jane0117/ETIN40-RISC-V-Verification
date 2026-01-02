// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Package for agent decode_wb
//=============================================================================

package decode_wb_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import common::*;


  `include "decode_wb_decode_wb_tx.sv"
  `include "decode_wb_config.sv"
  `include "decode_wb_driver.sv"
  `include "decode_wb_monitor.sv"
  `include "decode_wb_sequencer.sv"
  `include "decode_wb_coverage.sv"
  `include "decode_wb_agent.sv"
  `include "decode_wb_seq_lib.sv"

endpackage : decode_wb_pkg
