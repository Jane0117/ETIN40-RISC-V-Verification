// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Signal interface for agent execute_out
//=============================================================================

`ifndef EXECUTE_OUT_IF_SV
`define EXECUTE_OUT_IF_SV

interface execute_out_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import execute_out_pkg::*;

  control_type control_out;
  logic [31:0] alu_data;
  logic [31:0] memory_data;
  logic        pc_src;
  logic [31:0] jalr_target_offset;
  logic        jalr_flag;
  logic [31:0] pc_out;
  logic        overflow;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file execute_out.tpl

endinterface : execute_out_if

`endif // EXECUTE_OUT_IF_SV

