// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_in_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Signal interface for agent decode_in
//=============================================================================

`ifndef DECODE_IN_IF_SV
`define DECODE_IN_IF_SV

interface decode_in_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import decode_in_pkg::*;
  import common::*;

  logic clk;
  logic reset_n;
  logic valid;
  instruction_type instruction;
  logic [31:0] pc_in;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file decode_in.tpl

endinterface : decode_in_if

`endif // DECODE_IN_IF_SV

