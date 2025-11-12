// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_th.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Test Harness
//=============================================================================

module execute_top_th;

  timeunit      1ns;
  timeprecision 1ps;


  // You can remove clock and reset below by setting th_generate_clock_and_reset = no in file execute_common.tpl

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

  // You can insert code here by setting th_inc_inside_module in file execute_common.tpl

  // Pin-level interfaces connected to DUT
  // You can remove interface instances by setting generate_interface_instance = no in the interface template file

  decode_in_if    decode_in_if_0 ();  
  forward_if      forward_if_0 ();    
  execute_out_if  execute_out_if_0 ();

  execute_stage uut (
    .data1             (decode_if.data1),
    .data2             (decode_if.data2),
    .immediate_data    (decode_if.immediate_data),
    .pc_in             (decode_if.pc_in),
    .control_in        (decode_if.control_in),
    .wb_forward_data   (forward_if_0.wb_forward_data),
    .mem_forward_data  (forward_if_0.mem_forward_data),
    .forward_rs1       (forward_if_0.forward_rs1),
    .forward_rs2       (forward_if_0.forward_rs2),
    .control_out       (execute_out_if_0.control_out),
    .alu_data          (execute_out_if_0.alu_data),
    .memory_data       (execute_out_if_0.memory_data),
    .pc_src            (execute_out_if_0.pc_src),
    .jalr_target_offset(execute_out_if_0.jalr_target_offset),
    .jalr_flag         (execute_out_if_0.jalr_flag),
    .pc_out            (execute_out_if_0.pc_out),
    .overflow          (execute_out_if_0.overflow)
  );

endmodule

