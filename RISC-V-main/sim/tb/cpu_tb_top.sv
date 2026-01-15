`timescale 1ns/1ps

module cpu_tb_top;
  import uvm_pkg::*;
  import cpu_tb_pkg::*;
  import uart_pkg::*;
  import common::*;

  logic clk;
  logic reset_n;
  logic io_rx;
  logic indication;

  uart_if uart_vif(.clk(clk));
  // 实例化 Monitor Interface
  cpu_mon_if mon_if(.clk(clk));

  // 40MHz clock
  initial clk = 1'b0;
  always #12.5 clk = ~clk;

  initial begin
    reset_n = 1'b0;
    uart_vif.io_rx = 1'b1;
    repeat (10) @(posedge clk);
    reset_n = 1'b1;
  end

  assign uart_vif.reset_n = reset_n;
  assign io_rx = uart_vif.io_rx;

  cpu dut(
    .clk(clk),
    .reset_n(reset_n),
    .io_rx(io_rx),
    .indication(indication)
  );

  // 将 DUT 内部信号绑定到 Interface
  bind cpu cpu_mon_bind u_cpu_mon_bind(
    .mon_if($root.cpu_tb_top.mon_if),
    .reset_n(reset_n),
    .io_rx(io_rx),
    .indication(indication),
    .if_id_reg(if_id_reg),
    .id_ex_reg(id_ex_reg),
    .ex_mem_reg(ex_mem_reg),
    .mem_wb_reg(mem_wb_reg),
    .if_id_flush(if_id_flush),
    .id_ex_flush(id_ex_flush),
    .ex_mem_flush(ex_mem_flush),
    .if_id_write(if_id_write),
    .id_ex_write(id_ex_write),
    .pc_write(pc_write),
    .pc_src(pc_src),
    .execute_forwardA(execute_forwardA),
    .execute_forwardB(execute_forwardB),
    .execute_pc_out(execute_pc_out),
    .execute_jalr_flag(execute_jalr_flag),
    .execute_jalr_target_offset(execute_jalr_target_offset),
    .execute_overflow(execute_overflow),
    .run_flag(run_flag),
    .run_finished(run_finished),
    .fetch_decpompress_failed(fetch_decpompress_failed),
    .fetch_prediction(fetch_prediction),
    .program_mem_read_data(program_mem_read_data),
    .program_mem_write_enable(program_mem_write_enable),
    .program_mem_write_data(program_mem_write_data),
    .uart_write_address(uart_write_address)
  );

  // =========================================================================
  // [关键修改] 手动连接写回阶段的指令 (wb_instr)
  // =========================================================================
  // 既然 Interface 中 mem_wb 结构体里没有指令码，我们就用 PC 去内存里取！
  // 
  // ⚠️⚠️⚠️ 请注意：下面的路径 "dut.program_mem.ram" 可能需要修改！！！ ⚠️⚠️⚠️
  // 请在波形里确认你的指令内存叫什么名字 (例如: dut.u_imem.mem, dut.dmem.ram 等)
  // pc[31:2] 是因为内存通常是按字(Word)寻址，而 PC 是按字节寻址

  assign mon_if.mem_wb_instr = dut.inst_mem.ram[mon_if.mem_wb.pc[31:2]];
  // =========================================================================

  initial begin
    uvm_config_db#(virtual uart_if)::set(null, "*", "uart_vif", uart_vif);
    uvm_config_db#(virtual cpu_mon_if)::set(null, "*", "cpu_mon_vif", mon_if);
    run_test();
  end
endmodule