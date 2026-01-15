`timescale 1ns/1ps

interface cpu_mon_if(input logic clk);
  import common::*;

  logic reset_n;
  logic io_rx;
  logic indication;

  if_id_type  if_id;
  id_ex_type  id_ex;
  ex_mem_type ex_mem;
  mem_wb_type mem_wb;
  //手动添加写回阶段的指令信号
  logic [31:0] mem_wb_instr;
  logic if_id_flush;
  logic id_ex_flush;
  logic ex_mem_flush;
  logic if_id_write;
  logic id_ex_write;
  logic pc_write;

  logic pc_src;
  forward_type forwardA;
  forward_type forwardB;
  logic [31:0] execute_pc;
  logic execute_jalr_flag;
  logic [31:0] execute_jalr_target;
  logic execute_overflow;

  logic run_flag;
  logic run_finished;
  logic fetch_decompress_failed;
  logic fetch_prediction;
  logic [31:0] program_mem_read_data;

  // UART/program memory write observe
  logic program_mem_write_enable;
  logic [31:0] program_mem_write_data;
  logic [31:0] uart_write_address;
endinterface
