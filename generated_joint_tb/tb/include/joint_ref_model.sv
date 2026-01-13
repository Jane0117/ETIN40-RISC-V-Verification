`ifndef JOINT_REF_MODEL_SV
`define JOINT_REF_MODEL_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import common::*;
import decode_out_pkg::*;
import execute_out_pkg::*;

`uvm_analysis_imp_decl(_dec_ref)

class joint_ref_model extends uvm_component;
  `uvm_component_utils(joint_ref_model)

  uvm_analysis_imp_dec_ref #(decode_out_tx, joint_ref_model) dec_imp;
  uvm_analysis_port #(execute_out_tx) exp_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    dec_imp = new("dec_imp", this);
    exp_ap  = new("exp_ap", this);
  endfunction

  // 执行参考计算（无转发，与 joint_scoreboard 之前实现一致）
  function automatic execute_out_tx ref_execute(decode_out_tx dout);
    execute_out_tx ref_tx = new("ref_tx");
    logic [31:0] data2_or_imm;
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    logic [31:0] store_data;
    logic [31:0] alu_result;
    logic        zero_flag;

    data2_or_imm = (dout.control_signals.alu_src) ? dout.immediate_data : dout.read_data2;
    left_operand = dout.read_data1;

    case (dout.control_signals.encoding)
      S_TYPE: right_operand = dout.immediate_data;
      R_TYPE, B_TYPE: right_operand = dout.read_data2;
      default: right_operand = data2_or_imm;
    endcase
    store_data = dout.read_data2;

    unique case (dout.control_signals.alu_op)
      ALU_ADD:  alu_result = left_operand + right_operand;
      ALU_SUB:  alu_result = left_operand - right_operand;
      ALU_SLL:  alu_result = left_operand << right_operand[4:0];
      ALU_SRL:  alu_result = left_operand >> right_operand[4:0];
      ALU_SRA:  alu_result = $signed(left_operand) >>> right_operand[4:0];
      ALU_SLT:  alu_result = ($signed(left_operand)  < $signed(right_operand)) ? 32'd1 : 32'd0;
      ALU_SLTU: alu_result = (left_operand < right_operand) ? 32'd1 : 32'd0;
      ALU_XOR:  alu_result = left_operand ^ right_operand;
      ALU_OR:   alu_result = left_operand | right_operand;
      ALU_AND:  alu_result = left_operand & right_operand;
      ALU_LUI:  alu_result = dout.immediate_data;
      B_BNE:    alu_result = !(left_operand != right_operand);
      B_BLT:    alu_result = !($signed(left_operand) < $signed(right_operand));
      B_BGE:    alu_result = !($signed(left_operand) >= $signed(right_operand));
      B_LTU:    alu_result = !(left_operand < right_operand);
      B_GEU:    alu_result = !(left_operand >= right_operand);
      default:  alu_result = left_operand + right_operand;
    endcase
    zero_flag = (alu_result == 0);

    ref_tx.alu_data = alu_result;
    ref_tx.jalr_flag = 1'b0;
    ref_tx.jalr_target_offset = '0;
    if (dout.control_signals.encoding == I_TYPE && dout.control_signals.is_branch) begin
      ref_tx.alu_data = dout.pc_out + 32'd4;
      ref_tx.jalr_flag = 1'b1;
      ref_tx.jalr_target_offset = left_operand + dout.immediate_data;
    end else if (dout.control_signals.encoding == J_TYPE) begin
      ref_tx.alu_data = dout.pc_out + 32'd4;
    end

    if (dout.control_signals.encoding == B_TYPE) begin
      case (dout.control_signals.alu_op)
        ALU_SUB: ref_tx.pc_src = zero_flag;        // BEQ
        B_BLT,
        B_BGE,
        B_LTU,
        B_GEU,
        B_BNE:   ref_tx.pc_src = zero_flag;
        default: ref_tx.pc_src = 1'b0;
      endcase
    end else begin
      ref_tx.pc_src = 1'b0;
    end

    ref_tx.control_out        = dout.control_signals;
    ref_tx.memory_data        = (dout.control_signals.encoding == S_TYPE) ? store_data : dout.read_data2;
    ref_tx.pc_out             = dout.pc_out;
    ref_tx.overflow           = 1'b0;
    // 使用 decode_out 的 seq_id，便于跨阶段对齐
    ref_tx.seq_id             = dout.seq_id;
    return ref_tx;
  endfunction

  function void write_dec_ref(decode_out_tx t);
    execute_out_tx ref_tx = ref_execute(t);
    exp_ap.write(ref_tx);
  endfunction
endclass

`endif // JOINT_REF_MODEL_SV
