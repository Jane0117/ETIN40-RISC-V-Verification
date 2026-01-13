`timescale 1ns/1ps
import common::*;

module joint_top_th;
  // clock/reset
  logic clk;
  logic reset_n;

  // interface instances
  decode_in_if   decode_in_vif();
  decode_wb_if   decode_wb_vif();
  decode_out_if  decode_out_vif(.clock(clk), .reset_n(reset_n));
  execute_out_if execute_out_vif(.clock(clk), .reset(reset_n));

  // clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz
  end

  // reset sequence
  initial begin
    reset_n = 0;
    repeat (5) @(posedge clk);
    reset_n = 1;
  end

  // drive clocks into interfaces
  assign decode_in_vif.clk   = clk;
  assign decode_in_vif.reset_n = reset_n;
  assign decode_wb_vif.clk   = clk;
  assign decode_wb_vif.reset_n = reset_n;
  assign decode_out_vif.valid = decode_in_vif.valid;
  assign execute_out_vif.valid = decode_out_vif.valid;

  // DUT instances
  decode_stage u_decode (
    .clk               (clk),
    .reset_n           (reset_n),
    .instruction       (decode_in_vif.instruction),
    .pc_in             (decode_in_vif.pc_in),
    .write_en          (decode_wb_vif.write_en),
    .write_id          (decode_wb_vif.write_id),
    .write_data        (decode_wb_vif.write_data),
    .reg_rd_id         (decode_out_vif.reg_rd_id),
    .read_data1        (decode_out_vif.read_data1),
    .read_data2        (decode_out_vif.read_data2),
    .immediate_data    (decode_out_vif.immediate_data),
    .pc_out            (decode_out_vif.pc_out),
    .instruction_illegal(decode_out_vif.instruction_illegal),
    .control_signals   (decode_out_vif.control_signals)
  );

  execute_stage u_execute (
    .data1             (decode_out_vif.read_data1),
    .data2             (decode_out_vif.read_data2),
    .immediate_data    (decode_out_vif.immediate_data),
    .pc_in             (decode_out_vif.pc_out),
    .control_in        (decode_out_vif.control_signals),
    .wb_forward_data   ('0),
    .mem_forward_data  ('0),
    .forward_rs1       (FORWARD_NONE),
    .forward_rs2       (FORWARD_NONE),
    .control_out       (execute_out_vif.control_out),
    .alu_data          (execute_out_vif.alu_data),
    .memory_data       (execute_out_vif.memory_data),
    .pc_src            (execute_out_vif.pc_src),
    .jalr_target_offset(execute_out_vif.jalr_target_offset),
    .jalr_flag         (execute_out_vif.jalr_flag),
    .pc_out            (execute_out_vif.pc_out),
    .overflow          (execute_out_vif.overflow)
  );
endmodule
