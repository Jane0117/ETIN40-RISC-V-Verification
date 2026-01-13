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
  bit cov_pc_src;

  // covergroups
  covergroup cg_joint;
    cp_encoding  : coverpoint cov_ctrl.encoding;
    cp_alu_op    : coverpoint cov_ctrl.alu_op;
    cp_mem_size  : coverpoint cov_ctrl.mem_size {
      ignore_bins illegal = {2'b11};
    }
    cp_mem_sign  : coverpoint cov_ctrl.mem_sign;
    cp_mem_read  : coverpoint cov_ctrl.mem_read;
    cp_mem_write : coverpoint cov_ctrl.mem_write;
    cp_reg_write : coverpoint cov_ctrl.reg_write;
    cp_is_branch : coverpoint cov_ctrl.is_branch;
    cp_pc_src    : coverpoint cov_pc_src;
    cp_illegal   : coverpoint cov_illegal;
    cross_enc_pc : cross cp_encoding, cp_pc_src {
      ignore_bins non_branch_taken = binsof(cp_pc_src) intersect {1'b1} &&
                                    binsof(cp_encoding) intersect {R_TYPE, I_TYPE, S_TYPE, U_TYPE, J_TYPE, NONE_TYPE};
    }
    cross_alu_pc : cross cp_alu_op, cp_pc_src {
      ignore_bins non_branch_taken = binsof(cp_pc_src) intersect {1'b1} &&
                                     binsof(cp_alu_op) intersect {
                                       ALU_AND, ALU_OR, ALU_XOR,
                                       ALU_ADD, ALU_SLT, ALU_SLTU,
                                       ALU_SLL, ALU_SRL, ALU_SRA,
                                       ALU_LUI
                                     };
    }
    cross_illegal_ctrl : cross cp_illegal, cp_reg_write, cp_mem_read, cp_mem_write {
      ignore_bins illegal = binsof(cp_illegal) intersect {1'b1};
      ignore_bins mem_read_and_write = binsof(cp_mem_read) intersect {1'b1} &&
                                       binsof(cp_mem_write) intersect {1'b1};
      ignore_bins mem_read_no_regwrite = binsof(cp_mem_read) intersect {1'b1} &&
                                         binsof(cp_reg_write) intersect {1'b0};
      ignore_bins mem_write_with_regwrite = binsof(cp_mem_write) intersect {1'b1} &&
                                            binsof(cp_reg_write) intersect {1'b1};
    }
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
    cov_pc_src  = t.pc_src;
    cg_joint.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    real cov;
    super.report_phase(phase);
    cov = cg_joint.get_coverage();
    `uvm_info(get_type_name(),
              $sformatf("COVERAGE cg_joint=%0.2f%%", cov),
              UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_encoding=%0.2f%%", cg_joint.cp_encoding.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_alu_op=%0.2f%%", cg_joint.cp_alu_op.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_mem_size=%0.2f%%", cg_joint.cp_mem_size.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_mem_sign=%0.2f%%", cg_joint.cp_mem_sign.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_mem_read=%0.2f%%", cg_joint.cp_mem_read.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_mem_write=%0.2f%%", cg_joint.cp_mem_write.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_reg_write=%0.2f%%", cg_joint.cp_reg_write.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_is_branch=%0.2f%%", cg_joint.cp_is_branch.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_pc_src=%0.2f%%", cg_joint.cp_pc_src.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_illegal=%0.2f%%", cg_joint.cp_illegal.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cross_enc_pc=%0.2f%%", cg_joint.cross_enc_pc.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cross_alu_pc=%0.2f%%", cg_joint.cross_alu_pc.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cross_illegal_ctrl=%0.2f%%", cg_joint.cross_illegal_ctrl.get_inst_coverage()), UVM_LOW)
  endfunction
endclass

`endif // JOINT_COVERAGE_SV
