// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Signal interface for agent alu
//=============================================================================

`ifndef ALU_IF_SV
`define ALU_IF_SV

interface alu_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import alu_pkg::*;

  logic [3:0]   control;
  logic [31:0]  left_operand;
  logic [31:0]  right_operand;
  logic         zero_flag;
  logic [31:0]  result;
  logic         overflow;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file .\\alu.tpl

endinterface : alu_if

`endif // ALU_IF_SV

