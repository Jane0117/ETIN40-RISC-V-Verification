`include "uvm_macros.svh"
import uvm_pkg::*;
import execute_in_pkg::*;
import execute_out_pkg::*;
import common::*;

class execute_stage_ref_model extends uvm_component;
  `uvm_component_utils(execute_stage_ref_model)

  uvm_get_peek_port #(execute_tx) port;
  uvm_analysis_port #(execute_out_tx) ref_ap;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern function void compute_expected(execute_tx tr, ref execute_out_tx ref_tr);
  extern function void alu_calc(
    input alu_op_type op,
    input logic [31:0] left_operand,
    input logic [31:0] right_operand,
    output logic [31:0] result,
    output logic zero_flag,
    output logic overflow
  );
endclass

function execute_stage_ref_model::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void execute_stage_ref_model::build_phase(uvm_phase phase);
  super.build_phase(phase);
  port = new("port", this);
  ref_ap = new("ref_ap", this);
endfunction

task execute_stage_ref_model::run_phase(uvm_phase phase);
  execute_out_tx ref_tr;
  execute_tx tr;
  super.run_phase(phase);
  forever begin
    port.get(tr);
    ref_tr = execute_out_tx::type_id::create("ref_tr");
    compute_expected(tr, ref_tr);
    ref_ap.write(ref_tr);
  end
endtask

function void execute_stage_ref_model::compute_expected(execute_tx tr, ref execute_out_tx ref_tr);
  logic [31:0] left_operand;
  logic [31:0] right_operand;
  logic [31:0] data2_or_imm;
  logic [31:0] store_data;
  logic [31:0] alu_result;
  logic        zero_flag;
  logic        overflow;

  data2_or_imm = tr.control_in.alu_src ? tr.immediate_data : tr.data2;

  case (tr.forward_rs1)
    FORWARD_FROM_EX:  left_operand = tr.mem_forward_data;
    FORWARD_FROM_MEM: left_operand = tr.wb_forward_data;
    default:          left_operand = tr.data1;
  endcase

  case (tr.control_in.encoding)
    R_TYPE, S_TYPE, B_TYPE: begin
      case (tr.forward_rs2)
        FORWARD_FROM_EX:  right_operand = tr.mem_forward_data;
        FORWARD_FROM_MEM: right_operand = tr.wb_forward_data;
        default:          right_operand = data2_or_imm;
      endcase
    end
    default: right_operand = data2_or_imm;
  endcase

  if (tr.control_in.encoding == S_TYPE)
    right_operand = data2_or_imm;

  case (tr.forward_rs2)
    FORWARD_FROM_EX:  store_data = tr.mem_forward_data;
    FORWARD_FROM_MEM: store_data = tr.wb_forward_data;
    default:          store_data = tr.data2;
  endcase

  alu_calc(tr.control_in.alu_op, left_operand, right_operand, alu_result, zero_flag, overflow);

  ref_tr.control_out = tr.control_in;
  ref_tr.alu_data = alu_result;
  ref_tr.jalr_flag = 1'b0;
  ref_tr.jalr_target_offset = '0;

  if (tr.control_in.encoding == I_TYPE && tr.control_in.is_branch) begin
    ref_tr.alu_data = tr.pc_in + 32'd4;
    ref_tr.jalr_flag = 1'b1;
    ref_tr.jalr_target_offset = left_operand + tr.immediate_data;
  end else if (tr.control_in.encoding == J_TYPE) begin
    ref_tr.alu_data = tr.pc_in + 32'd4;
  end

  ref_tr.memory_data = (tr.control_in.encoding == S_TYPE) ? store_data : tr.data2;
  ref_tr.pc_src = (tr.control_in.encoding == B_TYPE) ? zero_flag : 1'b0;
  ref_tr.pc_out = tr.pc_in;
  ref_tr.overflow = overflow;
endfunction

function void execute_stage_ref_model::alu_calc(
  input alu_op_type op,
  input logic [31:0] left_operand,
  input logic [31:0] right_operand,
  output logic [31:0] result,
  output logic zero_flag,
  output logic overflow
);
  logic [31:0] temp_result;

  case (op)
    ALU_AND:  temp_result = left_operand & right_operand;
    ALU_OR:   temp_result = left_operand | right_operand;
    ALU_XOR:  temp_result = left_operand ^ right_operand;
    ALU_ADD:  temp_result = left_operand + right_operand;
    ALU_SUB:  temp_result = left_operand - right_operand;
    ALU_SLT:  temp_result = ($signed(left_operand) < $signed(right_operand)) ? 32'b1 : 32'b0;
    ALU_SLTU: temp_result = (left_operand < right_operand) ? 32'b1 : 32'b0;
    ALU_SLL:  temp_result = left_operand << right_operand[4:0];
    ALU_SRL:  temp_result = left_operand >> right_operand[4:0];
    ALU_SRA:  temp_result = $signed(left_operand) >>> right_operand[4:0];
    ALU_LUI:  temp_result = right_operand;
    B_BNE:    temp_result = !(left_operand != right_operand);
    B_BLT:    temp_result = !($signed(left_operand) < $signed(right_operand));
    B_BGE:    temp_result = !($signed(left_operand) >= $signed(right_operand));
    B_LTU:    temp_result = !(left_operand < right_operand);
    B_GEU:    temp_result = !(left_operand >= right_operand);
    default:  temp_result = 32'b0;
  endcase

  if (op == ALU_ADD) begin
    overflow = (~(left_operand[31] ^ right_operand[31])) & (left_operand[31] ^ temp_result[31]);
  end else if (op == ALU_SUB) begin
    overflow = ((left_operand[31] ^ right_operand[31]) & (left_operand[31] ^ temp_result[31]));
  end else begin
    overflow = 1'b0;
  end

  zero_flag = (temp_result == 0);
  result = temp_result;
endfunction
