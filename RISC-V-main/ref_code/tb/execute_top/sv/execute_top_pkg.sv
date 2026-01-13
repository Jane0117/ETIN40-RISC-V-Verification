// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Package for execute_top
//=============================================================================

package execute_top_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  import execute_in_pkg::*;
  import execute_out_pkg::*;

  `include "execute_top_config.sv"
  `include "execute_top_seq_lib.sv"
  `include "execute_stage_scoreboard.sv"
  `include "execute_stage_ref_model.sv"
  `include "execute_top_env.sv"

endpackage : execute_top_pkg

