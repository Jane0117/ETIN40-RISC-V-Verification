// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_out_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Signal interface for agent decode_out
//=============================================================================

`ifndef DECODE_OUT_IF_SV
`define DECODE_OUT_IF_SV

interface decode_out_if(input clock, input reset_n); 

  timeunit      1ns;
  timeprecision 1ps;

  import decode_out_pkg::*;
  import common::*;

  // provide clock/reset to monitor (continuous assign)
  logic clk;
  logic rst_n;
  assign clk   = clock;
  assign rst_n = reset_n;

  logic [4:0]   reg_rd_id;
  logic [31:0]  read_data1;
  logic [31:0]  read_data2;
  logic [31:0]  immediate_data;
  logic [31:0]  pc_out;
  logic         instruction_illegal;
  control_type  control_signals;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file decode_out.tpl

endinterface : decode_out_if

`endif // DECODE_OUT_IF_SV

