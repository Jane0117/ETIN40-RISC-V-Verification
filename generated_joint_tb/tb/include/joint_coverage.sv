`ifndef JOINT_COVERAGE_SV
`define JOINT_COVERAGE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import common::*;
import decode_out_pkg::*;
import execute_out_pkg::*;
import decode_wb_pkg::*;
import decode_in_pkg::*;

`uvm_analysis_imp_decl(_dec_cov)
`uvm_analysis_imp_decl(_exec_cov)
`uvm_analysis_imp_decl(_wb_cov)
`uvm_analysis_imp_decl(_dec_in_cov)

class joint_coverage extends uvm_subscriber #(execute_out_tx);
  `uvm_component_utils(joint_coverage)

  // decode stream for context
  uvm_analysis_imp_dec_cov  #(decode_out_tx,  joint_coverage) dec_imp;
  // decode_in stream for instruction coverage
  uvm_analysis_imp_dec_in_cov #(decode_in_tx, joint_coverage) dec_in_imp;
  // wb stream for x0 write attempt coverage
  uvm_analysis_imp_wb_cov   #(decode_wb_tx,  joint_coverage) wb_imp;
  // execute stream inherited via write(execute_out_tx)

  // sampled state
  control_type cov_ctrl;
  bit cov_illegal;
  logic [31:0] cov_pc;
  bit cov_pc_src;
  bit cov_x0_write_attempt;
  instruction_type cov_instr;

  // covergroups
  covergroup cg_joint;
    cp_encoding  : coverpoint cov_ctrl.encoding;
    cp_alu_op    : coverpoint cov_ctrl.alu_op;
    //覆盖访存宽度控制位对应 byte/half/word
    //（如 LB/LBU 是 byte，LH/LHU 是 half，LW 是 word，SB/SH/SW 也是对应宽度）。
    cp_mem_size  : coverpoint cov_ctrl.mem_size {
      ignore_bins illegal = {2'b11}; // 2'b11 is illegal for mem_size
    }
    cp_mem_sign  : coverpoint cov_ctrl.mem_sign;
    cp_mem_read  : coverpoint cov_ctrl.mem_read;
    cp_mem_write : coverpoint cov_ctrl.mem_write;
    cp_reg_write : coverpoint cov_ctrl.reg_write;
    cp_is_branch : coverpoint cov_ctrl.is_branch;
    cp_pc_src    : coverpoint cov_pc_src;
    cp_illegal   : coverpoint cov_illegal;
    cross_enc_pc : cross cp_encoding, cp_pc_src {
      //pc_src=1 表示分支/跳转“跳走”，非分支指令不应跳转
      //only consider non-branch instructions here,because pc_src=1 means branch taken
      ignore_bins non_branch_taken = binsof(cp_pc_src) intersect {1'b1} &&
                                    binsof(cp_encoding) intersect {R_TYPE, I_TYPE, S_TYPE, U_TYPE, J_TYPE, NONE_TYPE};
    }
    cross_alu_pc : cross cp_alu_op, cp_pc_src {
      //pc_src=1 表示分支/跳转“跳走”，ALU操作应为算术逻辑类
      //pc_src=1 means branch taken, alu_op should be arithmetic/logic operations
      ignore_bins non_branch_taken = binsof(cp_pc_src) intersect {1'b1} &&
                                     binsof(cp_alu_op) intersect {
                                       ALU_AND, ALU_OR, ALU_XOR,
                                       ALU_ADD, ALU_SLT, ALU_SLTU,
                                       ALU_SLL, ALU_SRL, ALU_SRA,
                                       ALU_LUI
                                     };
    }

    cross_illegal_ctrl : cross cp_illegal, cp_reg_write, cp_mem_read, cp_mem_write {
      //illegal=1 本身是“异常/非法指令”，对控制信号的组合没有意义，通常不希望把它纳入功能覆盖。
      //illegal=1 itself is an "exception/illegal instruction", 
      //the combination of control signals has no meaning, 
      //usually we don't want to include it in functional coverage.
      ignore_bins illegal = binsof(cp_illegal) intersect {1'b1};
      //mem_read 与 mem_write 同时为 1、mem_read 但 reg_write=0 等组合在本设计中是不成立的
      //mem_read 只对应 load 指令（LB/LH/LW/LBU/LHU), 从内存读数据并写回寄存器, reg_write 必须为 1
      ignore_bins mem_read_and_write = binsof(cp_mem_read) intersect {1'b1} &&
                                       binsof(cp_mem_write) intersect {1'b1};
      ignore_bins mem_read_no_regwrite = binsof(cp_mem_read) intersect {1'b1} &&
                                         binsof(cp_reg_write) intersect {1'b0};
      ignore_bins mem_write_with_regwrite = binsof(cp_mem_write) intersect {1'b1} &&
                                            binsof(cp_reg_write) intersect {1'b1};
    }
  endgroup

  typedef enum int {
    ID_ILLEGAL = 0,
    ID_ADD,
    ID_SUB,
    ID_SLL,
    ID_SRL,
    ID_SRA,
    ID_SLT,
    ID_SLTU,
    ID_XOR,
    ID_OR,
    ID_AND,
    ID_ADDI,
    ID_SLLI,
    ID_SRLI,
    ID_SRAI,
    ID_SLTI,
    ID_SLTIU,
    ID_XORI,
    ID_ORI,
    ID_ANDI,
    ID_LB,
    ID_LH,
    ID_LW,
    ID_LBU,
    ID_LHU,
    ID_SB,
    ID_SH,
    ID_SW,
    ID_BEQ,
    ID_BNE,
    ID_BLT,
    ID_BGE,
    ID_BLTU,
    ID_BGEU,
    ID_JAL,
    ID_JALR,
    ID_LUI,
    ID_AUIPC
  } instr_id_t;

  instr_id_t cov_instr_id;

  function automatic instr_id_t classify_instr(instruction_type instr);
    unique case (instr.opcode)
      7'b0110011: begin
        unique casez ({instr.funct7[5], instr.funct3})
          4'b0_000: return ID_ADD;
          4'b1_000: return ID_SUB;
          4'b?_001: return ID_SLL;
          4'b?_010: return ID_SLT;
          4'b?_011: return ID_SLTU;
          4'b?_100: return ID_XOR;
          4'b0_101: return ID_SRL;
          4'b1_101: return ID_SRA;
          4'b?_110: return ID_OR;
          4'b?_111: return ID_AND;
          default:  return ID_ILLEGAL;
        endcase
      end
      7'b0010011: begin
        unique casez ({instr.funct7[5], instr.funct3})
          4'b?_000: return ID_ADDI;
          4'b?_001: return ID_SLLI;
          4'b?_010: return ID_SLTI;
          4'b?_011: return ID_SLTIU;
          4'b?_100: return ID_XORI;
          4'b0_101: return ID_SRLI;
          4'b1_101: return ID_SRAI;
          4'b?_110: return ID_ORI;
          4'b?_111: return ID_ANDI;
          default:  return ID_ILLEGAL;
        endcase
      end
      7'b0000011: begin
        unique casez (instr.funct3)
          3'b000: return ID_LB;
          3'b001: return ID_LH;
          3'b010: return ID_LW;
          3'b100: return ID_LBU;
          3'b101: return ID_LHU;
          default: return ID_ILLEGAL;
        endcase
      end
      7'b0100011: begin
        unique casez (instr.funct3)
          3'b000: return ID_SB;
          3'b001: return ID_SH;
          3'b010: return ID_SW;
          default: return ID_ILLEGAL;
        endcase
      end
      7'b1100011: begin
        unique casez (instr.funct3)
          3'b000: return ID_BEQ;
          3'b001: return ID_BNE;
          3'b100: return ID_BLT;
          3'b101: return ID_BGE;
          3'b110: return ID_BLTU;
          3'b111: return ID_BGEU;
          default: return ID_ILLEGAL;
        endcase
      end
      7'b1101111: return ID_JAL;
      7'b1100111: return ID_JALR;
      7'b0110111: return ID_LUI;
      7'b0010111: return ID_AUIPC;
      default:    return ID_ILLEGAL;
    endcase
  endfunction


  covergroup cg_instr;
    option.per_instance = 1;
    option.goal = 100;
    cp_instr: coverpoint cov_instr_id {
      bins add   = {ID_ADD};
      bins sub   = {ID_SUB};
      bins sll   = {ID_SLL};
      bins srl   = {ID_SRL};
      bins sra   = {ID_SRA};
      bins slt   = {ID_SLT};
      bins sltu  = {ID_SLTU};
      bins xor_b = {ID_XOR};
      bins or_b  = {ID_OR};
      bins and_b = {ID_AND};
      bins addi  = {ID_ADDI};
      bins slli  = {ID_SLLI};
      bins srli  = {ID_SRLI};
      bins srai  = {ID_SRAI};
      bins slti  = {ID_SLTI};
      bins sltiu = {ID_SLTIU};
      bins xori  = {ID_XORI};
      bins ori   = {ID_ORI};
      bins andi  = {ID_ANDI};
      bins lb    = {ID_LB};
      bins lh    = {ID_LH};
      bins lw    = {ID_LW};
      bins lbu   = {ID_LBU};
      bins lhu   = {ID_LHU};
      bins sb    = {ID_SB};
      bins sh    = {ID_SH};
      bins sw    = {ID_SW};
      bins beq   = {ID_BEQ};
      bins bne   = {ID_BNE};
      bins blt   = {ID_BLT};
      bins bge   = {ID_BGE};
      bins bltu  = {ID_BLTU};
      bins bgeu  = {ID_BGEU};
      bins jal   = {ID_JAL};
      bins jalr  = {ID_JALR};
      bins lui   = {ID_LUI};
      bins auipc = {ID_AUIPC};
      bins illegal = {ID_ILLEGAL};
    }
  endgroup

  covergroup cg_wb;
    option.per_instance = 1;
    cp_x0_write_attempt : coverpoint cov_x0_write_attempt;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    dec_imp = new("dec_imp", this);
    dec_in_imp = new("dec_in_imp", this);
    wb_imp  = new("wb_imp",  this);
    cg_joint = new();
    cg_instr = new();
    cg_wb    = new();
  endfunction

  // capture decode context
  function void write_dec_cov(decode_out_tx t);
    cov_ctrl    = t.control_signals;
    cov_illegal = t.instruction_illegal;
  endfunction

  function void write_wb_cov(decode_wb_tx t);
    cov_x0_write_attempt = (t.write_en && (t.write_id == 0));
    cg_wb.sample();
  endfunction

  function void write_dec_in_cov(decode_in_tx t);
    cov_instr = t.instruction;
    cov_instr_id = classify_instr(t.instruction);
    cg_instr.sample();
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
    `uvm_info(get_type_name(), $sformatf("COVERAGE cg_instr=%0.2f%%", cg_instr.get_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_instr=%0.2f%%", cg_instr.cp_instr.get_inst_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cg_wb=%0.2f%%", cg_wb.get_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("COVERAGE cp_x0_write_attempt=%0.2f%%", cg_wb.cp_x0_write_attempt.get_inst_coverage()), UVM_LOW)
  endfunction
endclass

`endif // JOINT_COVERAGE_SV
