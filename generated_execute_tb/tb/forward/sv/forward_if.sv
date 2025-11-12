// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Signal interface for agent forward
//=============================================================================

`ifndef FORWARD_IF_SV
`define FORWARD_IF_SV

interface forward_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import forward_pkg::*;

  logic [31:0] wb_forward_data;
  logic [31:0] mem_forward_data;
  forward_type forward_rs1;
  forward_type forward_rs2;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file forward.tpl

endinterface : forward_if

`endif // FORWARD_IF_SV

