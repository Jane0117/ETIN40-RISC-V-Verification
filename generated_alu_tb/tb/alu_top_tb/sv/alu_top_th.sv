// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_top_th.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Test Harness
//=============================================================================

module alu_top_th;

  timeunit      1ns;
  timeprecision 1ps;


  // You can remove clock and reset below by setting th_generate_clock_and_reset = no in file .\\common.tpl

  // Example clock and reset declarations
  logic clock = 0;
  logic reset;

  // Example clock generator process
  always #10 clock = ~clock;

  // Example reset generator process
  initial
  begin
    reset = 0;         // Active low reset in this example
    #75 reset = 1;
  end

  // You can insert code here by setting th_inc_inside_module in file .\\common.tpl

  // Pin-level interfaces connected to DUT
  // You can remove interface instances by setting generate_interface_instance = no in the interface template file

  alu_if  alu_if_0 ();

  alu uut (
    .control      (alu_if_0.control),
    .left_operand (alu_if_0.left_operand),
    .right_operand(alu_if_0.right_operand),
    .zero_flag    (alu_if_0.zero_flag),
    .result       (alu_if_0.result),
    .overflow     (alu_if_0.overflow)
  );

endmodule

