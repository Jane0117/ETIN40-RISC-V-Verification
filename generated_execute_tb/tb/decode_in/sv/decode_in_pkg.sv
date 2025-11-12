// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: decode_in_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Package for agent decode_in
//=============================================================================

package decode_in_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;


  `include "decode_in_decode_tx.sv"
  `include "decode_in_config.sv"
  `include "decode_in_driver.sv"
  `include "decode_in_monitor.sv"
  `include "decode_in_sequencer.sv"
  `include "decode_in_coverage.sv"
  `include "decode_in_agent.sv"
  `include "decode_in_seq_lib.sv"

endpackage : decode_in_pkg
