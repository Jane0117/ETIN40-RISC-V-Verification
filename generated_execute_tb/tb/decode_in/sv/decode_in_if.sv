// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: decode_in_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Signal interface for agent decode_in
//=============================================================================

`ifndef DECODE_IN_IF_SV
`define DECODE_IN_IF_SV

interface decode_in_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import decode_in_pkg::*;

  logic [31:0] data1;
  logic [31:0] data2;
  logic [31:0] immediate_data;
  logic [31:0] pc_in;
  control_type control_in;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file decode_in.tpl

endinterface : decode_in_if

`endif // DECODE_IN_IF_SV

