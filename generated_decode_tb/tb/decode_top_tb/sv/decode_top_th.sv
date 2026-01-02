// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_th.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Test Harness
//=============================================================================

module decode_top_th;

  timeunit      1ns;
  timeprecision 1ps;


  // You can remove clock and reset below by setting th_generate_clock_and_reset = no in file decode_common.tpl

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

  assign decode_in_if_0.reset_n = reset;
  assign decode_wb_if_0.reset_n = reset;

  assign decode_in_if_0.clk     = clock;
  assign decode_wb_if_0.clk     = clock;

  // You can insert code here by setting th_inc_inside_module in file decode_common.tpl

  // Pin-level interfaces connected to DUT
  // You can remove interface instances by setting generate_interface_instance = no in the interface template file

  decode_in_if   decode_in_if_0 (); 
  decode_wb_if   decode_wb_if_0 (); 
  decode_out_if  decode_out_if_0 (clock, reset);

  decode_stage uut (
    .clk                (decode_in_if_0.clk),
    .reset_n            (decode_in_if_0.reset_n),
    .instruction        (decode_in_if_0.instruction),
    .pc_in              (decode_in_if_0.pc_in),
    .write_en           (decode_wb_if_0.write_en),
    .write_id           (decode_wb_if_0.write_id),
    .write_data         (decode_wb_if_0.write_data),
    .reg_rd_id          (decode_out_if_0.reg_rd_id),
    .read_data1         (decode_out_if_0.read_data1),
    .read_data2         (decode_out_if_0.read_data2),
    .immediate_data     (decode_out_if_0.immediate_data),
    .pc_out             (decode_out_if_0.pc_out),
    .instruction_illegal(decode_out_if_0.instruction_illegal),
    .control_signals    (decode_out_if_0.control_signals)
  );

endmodule

