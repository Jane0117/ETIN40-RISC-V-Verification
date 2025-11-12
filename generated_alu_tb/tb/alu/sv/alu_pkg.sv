// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 01:31:07 2025
//=============================================================================
// Description: Package for agent alu
//=============================================================================

package alu_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;


  `include "alu_transaction.sv"
  `include "alu_config.sv"
  `include "alu_driver.sv"
  `include "alu_monitor.sv"
  `include "alu_sequencer.sv"
  `include "alu_coverage.sv"
  `include "alu_agent.sv"
  `include "alu_seq_lib.sv"

endpackage : alu_pkg
