`timescale 1ns/1ps
`include "uvm_macros.svh"

package cpu_tb_pkg;
  import uvm_pkg::*;
  import uart_pkg::*;
  import common::*;

  `include "pkg/cpu_typedefs.sv"
  `include "monitors/cpu_monitors.sv"
  `include "ref/cpu_ref_model.sv"
  `include "scoreboard/cpu_scoreboard.sv"
  `include "coverage/cpu_coverage.sv"
  `include "sequences/cpu_sequences.sv"
  `include "env/cpu_env.sv"
  `include "tests/cpu_tests.sv"
endpackage
