`ifndef JOINT_COVERAGE_SV
`define JOINT_COVERAGE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import common::*;
import decode_out_pkg::*;
import execute_out_pkg::*;

`uvm_analysis_imp_decl(_dec_cov)
`uvm_analysis_imp_decl(_exec_cov)

class joint_coverage extends uvm_subscriber #(execute_out_tx);
  `uvm_component_utils(joint_coverage)

  // decode stream for context
  uvm_analysis_imp_dec_cov  #(decode_out_tx,  joint_coverage) dec_imp;
  // execute stream inherited via write(execute_out_tx)

  // sampled state
  control_type cov_ctrl;
  bit cov_illegal;
  logic [31:0] cov_pc;

  // covergroups
  covergroup cg_joint;
    cp_encoding  : coverpoint cov_ctrl.encoding;
    cp_alu_op    : coverpoint cov_ctrl.alu_op;
    cp_mem_size  : coverpoint cov_ctrl.mem_size;
    cp_mem_sign  : coverpoint cov_ctrl.mem_sign;
    cp_mem_read  : coverpoint cov_ctrl.mem_read;
    cp_mem_write : coverpoint cov_ctrl.mem_write;
    cp_reg_write : coverpoint cov_ctrl.reg_write;
    cp_is_branch : coverpoint cov_ctrl.is_branch;
    cp_pc_src    : coverpoint cov_pc[0]; // low bit of pc_src sample
    cp_illegal   : coverpoint cov_illegal;
    cross_enc_pc : cross cp_encoding, cp_pc_src;
    cross_alu_pc : cross cp_alu_op, cp_pc_src;
    cross_illegal_ctrl : cross cp_illegal, cp_reg_write, cp_mem_read, cp_mem_write;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    dec_imp = new("dec_imp", this);
    cg_joint = new();
  endfunction

  // capture decode context
  function void write_dec_cov(decode_out_tx t);
    cov_ctrl    = t.control_signals;
    cov_illegal = t.instruction_illegal;
  endfunction

  // execute stream drives sampling
  virtual function void write(execute_out_tx t);
    cov_pc      = t.pc_out;
    cg_joint.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    real cov;
    super.report_phase(phase);
    cov = cg_joint.get_coverage();
    `uvm_info(get_type_name(),
              $sformatf("COVERAGE cg_joint=%0.2f%%", cov),
              UVM_LOW)
  endfunction
endclass

`endif // JOINT_COVERAGE_SV
