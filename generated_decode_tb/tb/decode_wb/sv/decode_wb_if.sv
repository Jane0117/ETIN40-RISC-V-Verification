// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_if.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Signal interface for agent decode_wb
//=============================================================================

`ifndef DECODE_WB_IF_SV
`define DECODE_WB_IF_SV

interface decode_wb_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import decode_wb_pkg::*;

  logic clk;
  logic reset_n;
  logic        write_en;
  logic [4:0]  write_id;
  logic [31:0] write_data;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file decode_wb.tpl

endinterface : decode_wb_if

`endif // DECODE_WB_IF_SV

