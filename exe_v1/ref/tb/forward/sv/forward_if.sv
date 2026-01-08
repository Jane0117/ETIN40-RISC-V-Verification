// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_if.sv
//
//
// Version:   1.0
//forward UVC 的验证目标是：
//① forward_rs1/rs2 selector 是否正确被驱动到 DUT
//② wb_forward_data / mem_forward_data 是否正确传播到 execute core
//③ 覆盖 forwarding path 全覆盖（9 条）
//④ hazard case：EX → ID、MEM → EX 等
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Signal interface for agent forward
//=============================================================================

`ifndef FORWARD_IF_SV
`define FORWARD_IF_SV

interface forward_if(input clock, input reset); 

  timeunit      1ns;
  timeprecision 1ps;

  import forward_pkg::*;
  import common::*;

  logic [31:0] wb_forward_data;
  logic [31:0] mem_forward_data;
  forward_type forward_rs1;
  forward_type forward_rs2;

  // You can insert properties and assertions here

  // You can insert code here by setting if_inc_inside_interface in file forward.tpl

endinterface : forward_if

`endif // FORWARD_IF_SV

