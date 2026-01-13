// Package for joint decode+execute verification
`ifndef JOINT_TOP_PKG_SV
`define JOINT_TOP_PKG_SV

package joint_top_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import common::*;
  import decode_in_pkg::*;
  import decode_wb_pkg::*;
  import decode_out_pkg::*;
  import execute_out_pkg::*;

  `include "joint_ref_model.sv"
  `include "joint_scoreboard.sv"
  `include "joint_coverage.sv"
  `include "joint_top_env.sv"
  `include "joint_top_test.sv"
endpackage

`endif // JOINT_TOP_PKG_SV
