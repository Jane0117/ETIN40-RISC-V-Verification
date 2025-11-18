// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Signal interface for agent execute_in
//=============================================================================

`ifndef EXECUTE_IN_IF_SV
`define EXECUTE_IN_IF_SV

interface execute_in_if(input clock, input reset); 

  timeunit      1ns;
  timeprecision 1ps;

  import execute_in_pkg::*;
  import common::*;

  logic [31:0] data1;
  logic [31:0] data2;
  logic [31:0] immediate_data;
  logic [31:0] pc_in;
  control_type control_in;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file execute_in.tpl

endinterface : execute_in_if

`endif // EXECUTE_IN_IF_SV

