// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Coverage for agent execute_out
//=============================================================================

`ifndef EXECUTE_OUT_COVERAGE_SV
`define EXECUTE_OUT_COVERAGE_SV

class execute_out_coverage extends uvm_subscriber #(execute_out_tx);

  `uvm_component_utils(execute_out_coverage)

  execute_out_config m_config;
  bit                m_is_covered;
  execute_out_tx     m_item;

  covergroup m_cov;
    option.per_instance = 1;

    // ---------- 控制类（输出行为相关） ----------
    cp_pc_src    : coverpoint m_item.pc_src    { bins b0 = {0}; bins b1 = {1}; }
    cp_jalr_flag : coverpoint m_item.jalr_flag { bins b0 = {0}; bins b1 = {1}; }
    cp_overflow  : coverpoint m_item.overflow  { bins b0 = {0}; bins b1 = {1}; }

    // ---------- control_out：把“整体覆盖”改为“字段级覆盖”（关键改动点） ----------
    // 这会直接消灭你 report 里 cp_control_out 的 64 个 auto bins 大缺口
    cp_enc: coverpoint m_item.control_out.encoding {
      bins none = {common::NONE_TYPE};
      bins r    = {common::R_TYPE};
      bins i    = {common::I_TYPE};
      bins s    = {common::S_TYPE};
      bins b    = {common::B_TYPE};
      bins u    = {common::U_TYPE};
      bins j    = {common::J_TYPE};
    }

    cp_alu_op: coverpoint m_item.control_out.alu_op {
      bins and_  = {common::ALU_AND};
      bins or_   = {common::ALU_OR};
      bins xor_  = {common::ALU_XOR};
      bins add   = {common::ALU_ADD};
      bins sub   = {common::ALU_SUB};
      bins slt   = {common::ALU_SLT};
      bins sltu  = {common::ALU_SLTU};
      bins sll   = {common::ALU_SLL};
      bins srl   = {common::ALU_SRL};
      bins sra   = {common::ALU_SRA};
      bins lui   = {common::ALU_LUI};
      bins bne   = {common::B_BNE};
      bins blt   = {common::B_BLT};
      bins bge   = {common::B_BGE};
      bins bltu  = {common::B_LTU};
      bins bgeu  = {common::B_GEU};
    }

    cp_alu_src   : coverpoint m_item.control_out.alu_src   { bins b0={0}; bins b1={1}; }
    cp_mem_read  : coverpoint m_item.control_out.mem_read  { bins b0={0}; bins b1={1}; }
    cp_mem_write : coverpoint m_item.control_out.mem_write { bins b0={0}; bins b1={1}; }
    cp_reg_write : coverpoint m_item.control_out.reg_write { bins b0={0}; bins b1={1}; }
    cp_mem2reg   : coverpoint m_item.control_out.mem_to_reg{ bins b0={0}; bins b1={1}; }
    cp_mem_size  : coverpoint m_item.control_out.mem_size  { 
  bins b8   = {2'b00};  // byte
  bins h16  = {2'b01};  // half word
  bins w32  = {2'b10};  // word
  // 可选：如果 mem_size 可能出现 2'b11，可以加一个“其他”桶
  bins other = default;
}

    cp_mem_sign  : coverpoint m_item.control_out.mem_sign  { bins b0={0}; bins b1={1}; }
    cp_is_branch : coverpoint m_item.control_out.is_branch { bins b0={0}; bins b1={1}; }

    // （可选但不强制）一些“明显非法/不合理”的组合可以标 illegal_bins
    // 例如同时 mem_read & mem_write 通常不应发生：
    cx_mem_rw: cross cp_mem_read, cp_mem_write {
      illegal_bins both = binsof(cp_mem_read.b1) && binsof(cp_mem_write.b1);
    }

    // ---------- 数据类（形态覆盖） ----------
    cp_alu_zero: coverpoint (m_item.alu_data == 32'h0) { bins zero = {1}; bins nonzero = {0}; }
    cp_alu_sign: coverpoint m_item.alu_data[31]        { bins pos  = {0}; bins neg    = {1}; }

    cp_mem_zero: coverpoint (m_item.memory_data == 32'h0) { bins zero = {1}; bins nonzero = {0}; }

    // execute_stage 里 pc_out=pc_in，通常永远对齐；misaligned 设 ignore
    cp_pc_align: coverpoint m_item.pc_out[1:0] {
      bins aligned = {2'b00};
      ignore_bins misaligned = {[2'b01:2'b11]};
    }

    cp_jalr_off_zero: coverpoint (m_item.jalr_target_offset == 32'h0) { bins zero = {1}; bins nonzero = {0}; }
    cp_jalr_off_sign: coverpoint m_item.jalr_target_offset[31]        { bins pos  = {0}; bins neg    = {1}; }

    // ---------- 关键组合覆盖 ----------
    // pc_src=1 仅在 B_TYPE；jalr_flag=1 仅在 I_TYPE&&is_branch，因此 <1,1> 互斥
    cx_flow: cross cp_pc_src, cp_jalr_flag {
      ignore_bins impossible = binsof(cp_pc_src.b1) && binsof(cp_jalr_flag.b1);
    }

    // overflow x pc_src：你原 report 里 <1,1> 为 ZERO，保守 ignore 掉
    cx_ovf_flow: cross cp_overflow, cp_pc_src {
      ignore_bins unlikely_or_impossible = binsof(cp_overflow.b1) && binsof(cp_pc_src.b1);
    }

  endgroup

  extern function new(string name, uvm_component parent);
  extern function void write(input execute_out_tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

endclass : execute_out_coverage


function execute_out_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void execute_out_coverage::write(input execute_out_tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void execute_out_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(execute_out_config)::get(this, "", "config", m_config))
    `uvm_fatal(get_type_name(), "execute_out config not found")
endfunction : build_phase


function void execute_out_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


`endif // EXECUTE_OUT_COVERAGE_SV
