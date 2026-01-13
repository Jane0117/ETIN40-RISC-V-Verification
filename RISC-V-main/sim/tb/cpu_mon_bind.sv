`timescale 1ns/1ps
import common::*;

module cpu_mon_bind(
    cpu_mon_if mon_if,
    input logic reset_n,
    input logic io_rx,
    input logic indication,
    input if_id_type  if_id_reg,
    input id_ex_type  id_ex_reg,
    input ex_mem_type ex_mem_reg,
    input mem_wb_type mem_wb_reg,
    input logic if_id_flush,
    input logic id_ex_flush,
    input logic ex_mem_flush,
    input logic if_id_write,
    input logic id_ex_write,
    input logic pc_write,
    input logic pc_src,
    input forward_type execute_forwardA,
    input forward_type execute_forwardB,
    input logic [31:0] execute_pc_out,
    input logic execute_jalr_flag,
    input logic [31:0] execute_jalr_target_offset,
    input logic execute_overflow,
    input logic run_flag,
    input logic run_finished,
    input logic fetch_decpompress_failed,
    input logic fetch_prediction,
    input logic [31:0] program_mem_read_data,
    input logic program_mem_write_enable,
    input logic [31:0] program_mem_write_data,
    input logic [31:0] uart_write_address
);
  import common::*;

  // simple debug flags to avoid repeated prints
  logic indication_q, run_flag_q, run_finished_q;

  assign mon_if.reset_n = reset_n;
  assign mon_if.io_rx = io_rx;
  assign mon_if.indication = indication;

  assign mon_if.if_id = if_id_reg;
  assign mon_if.id_ex = id_ex_reg;
  assign mon_if.ex_mem = ex_mem_reg;
  assign mon_if.mem_wb = mem_wb_reg;

  assign mon_if.if_id_flush = if_id_flush;
  assign mon_if.id_ex_flush = id_ex_flush;
  assign mon_if.ex_mem_flush = ex_mem_flush;
  assign mon_if.if_id_write = if_id_write;
  assign mon_if.id_ex_write = id_ex_write;
  assign mon_if.pc_write = pc_write;

  assign mon_if.pc_src = pc_src;
  assign mon_if.forwardA = execute_forwardA;
  assign mon_if.forwardB = execute_forwardB;
  assign mon_if.execute_pc = execute_pc_out;
  assign mon_if.execute_jalr_flag = execute_jalr_flag;
  assign mon_if.execute_jalr_target = execute_jalr_target_offset;
  assign mon_if.execute_overflow = execute_overflow;

  assign mon_if.run_flag = run_flag;
  assign mon_if.run_finished = run_finished;
  assign mon_if.fetch_decompress_failed = fetch_decpompress_failed;
  assign mon_if.fetch_prediction = fetch_prediction;
  assign mon_if.program_mem_read_data = program_mem_read_data;
  assign mon_if.program_mem_write_enable = program_mem_write_enable;
  assign mon_if.program_mem_write_data = program_mem_write_data;
  assign mon_if.uart_write_address = uart_write_address;

  // Debug printing: catch key events to help debug stalls/timeouts
  always @(posedge mon_if.clk or negedge reset_n) begin
    if (!reset_n) begin
      indication_q   <= 1'b0;
      run_flag_q     <= 1'b0;
      run_finished_q <= 1'b0;
    end else begin
      indication_q   <= indication;
      run_flag_q     <= run_flag;
      run_finished_q <= run_finished;

      if (!run_flag_q && run_flag) begin
        $display("[%0t] RUN_FLAG asserted (UART sentinel seen)", $time);
      end

      if (!run_finished_q && run_finished) begin
        $display("[%0t] RUN_FINISHED asserted, PC=%h", $time, mon_if.if_id.pc);
      end

      if (!indication_q && indication) begin
        $display("[%0t] INDICATION asserted: dec_fail=%0b illegal=%0b overflow=%0b pc=%h instr=%h",
                 $time,
                 fetch_decpompress_failed,
                 id_ex_reg.instruction_illegal,
                 execute_overflow,
                 mon_if.if_id.pc,
                 mon_if.if_id.instruction);
      end

      if (program_mem_write_enable) begin
        $display("[%0t] UART WRITE byte_addr=%0d word_idx=%0d data=%08h",
                 $time, uart_write_address, uart_write_address[9:2], program_mem_write_data);
      end
    end
  end
endmodule
