// Simple decode scoreboard with reference model for control/immediate/illegal

`ifndef DECODE_SCOREBOARD_SV
`define DECODE_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import common::*;

// Declare unique analysis imp types for multiple exports
`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
`uvm_analysis_imp_decl(_wb)

class decode_scoreboard extends uvm_component;

  `uvm_component_utils(decode_scoreboard)

  // analysis imps for input/output streams
  uvm_analysis_imp_in   #(decode_in_tx,  decode_scoreboard) in_imp;
  uvm_analysis_imp_out  #(decode_out_tx, decode_scoreboard) out_imp;
  uvm_analysis_imp_wb   #(decode_wb_tx,  decode_scoreboard) wb_imp;

  typedef struct packed {
    control_type control;
    logic [31:0] imm;
    logic instruction_illegal;
    logic [4:0] rd;
    logic [31:0] pc_in;
    logic [31:0] pc_tag;
    logic [4:0] rs1;
    logic [4:0] rs2;
  } exp_t;

  // expectations indexed by pc_tag; each tag can have a small queue
  exp_t exp_by_pc [logic [31:0]] [$];

  // Simple regfile model
  logic [31:0] regfile[0:31];
  bit x0_write_attempted;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_imp  = new("in_imp",  this);
    out_imp = new("out_imp", this);
    wb_imp  = new("wb_imp",  this);
    // init regfile to zero
    foreach (regfile[ii]) regfile[ii] = '0;
    x0_write_attempted = 1'b0;
  endfunction

  // Reference decode function mirroring control.sv
  function automatic void ref_decode(instruction_type instruction,
                                     output control_type control,
                                     output logic decode_failed);
    control = '0;
    decode_failed = 1'b0;
    unique case (instruction.opcode)
      7'b0110011: begin
        control.encoding  = R_TYPE;
        control.reg_write = 1'b1;
        unique casez({instruction.funct7[5], instruction.funct3})
          4'b0_000: control.alu_op = ALU_ADD;
          4'b1_000: control.alu_op = ALU_SUB;
          4'b?_001: control.alu_op = ALU_SLL;
          4'b?_010: control.alu_op = ALU_SLT;
          4'b?_011: control.alu_op = ALU_SLTU;
          4'b?_100: control.alu_op = ALU_XOR;
          4'b0_101: control.alu_op = ALU_SRL;
          4'b1_101: control.alu_op = ALU_SRA;
          4'b?_110: control.alu_op = ALU_OR;
          4'b?_111: control.alu_op = ALU_AND;
          default: decode_failed = 1'b1;
        endcase
      end
      7'b0010011: begin
        control.encoding  = I_TYPE;
        control.reg_write = 1'b1;
        control.alu_src   = 1'b1;
        unique casez({instruction.funct7[5], instruction.funct3})
          4'b?_000: control.alu_op = ALU_ADD;
          4'b?_001: control.alu_op = ALU_SLL;
          4'b?_010: control.alu_op = ALU_SLT;
          4'b?_011: control.alu_op = ALU_SLTU;
          4'b?_100: control.alu_op = ALU_XOR;
          4'b0_101: control.alu_op = ALU_SRL;
          4'b1_101: control.alu_op = ALU_SRA;
          4'b?_110: control.alu_op = ALU_OR;
          4'b?_111: control.alu_op = ALU_AND;
          default: decode_failed = 1'b1;
        endcase
      end
      7'b0000011: begin
        control.encoding   = I_TYPE;
        control.reg_write  = 1'b1;
        control.alu_src    = 1'b1;
        control.mem_read   = 1'b1;
        control.mem_to_reg = 1'b1;
        control.alu_op     = ALU_ADD;
        unique casez(instruction.funct3)
          3'b000: control.mem_size = 2'b00;
          3'b001: control.mem_size = 2'b01;
          3'b010: control.mem_size = 2'b10;
          3'b100: control.mem_size = 2'b00;
          3'b101: control.mem_size = 2'b01;
          default: decode_failed = 1'b1;
        endcase
        unique casez(instruction.funct3)
          3'b0??: control.mem_sign = 1'b1;
          3'b1??: control.mem_sign = 1'b0;
          default: decode_failed = 1'b1;
        endcase
      end
      7'b1100111: begin
        control.encoding  = I_TYPE;
        control.is_branch = 1'b1;
        control.reg_write = 1'b1;
        control.alu_op    = ALU_ADD;
      end
      7'b1101111: begin
        control.encoding  = J_TYPE;
        control.is_branch = 1'b0;
        control.reg_write = 1'b1;
        control.alu_op    = ALU_ADD;
      end
      7'b0100011: begin
        control.encoding = S_TYPE;
        control.alu_src  = 1'b1;
        control.mem_write= 1'b1;
        control.alu_op   = ALU_ADD;
        unique casez(instruction.funct3)
          3'b000: control.mem_size = 2'b00;
          3'b001: control.mem_size = 2'b01;
          3'b010: control.mem_size = 2'b10;
          default: decode_failed = 1'b1;
        endcase
      end
      7'b1100011: begin
        control.encoding  = B_TYPE;
        control.is_branch = 1'b1;
        unique casez({instruction.funct3, instruction.opcode})
          BEQ_INSTRUCTION: control.alu_op = ALU_SUB;
          BNE_INSTRUCTION: control.alu_op = B_BNE;
          BLT_INSTRUCTION: control.alu_op = B_BLT;
          BGE_INSTRUCTION: control.alu_op = B_BGE;
          BLTU_INSTRUCTION: control.alu_op = B_LTU;
          BGEU_INSTRUCTION: control.alu_op = B_GEU;
          default: decode_failed = 1'b1;
        endcase
      end
      7'b0110111: begin
        control.encoding  = U_TYPE;
        control.reg_write = 1'b1;
        control.alu_src   = 1'b1;
        control.alu_op    = ALU_LUI;
      end
      7'b0010111: begin
        control.encoding  = U_TYPE;
        control.reg_write = 1'b1;
        control.alu_op    = ALU_ADD;
      end
      default: begin
        if (instruction == 32'h00001111 || instruction == 32'h00000000)
          control = '0;
        else
          decode_failed = 1'b1;
      end
    endcase
  endfunction : ref_decode

  function automatic logic ref_reg_illegal(control_type control,
                                           instruction_type instruction,
                                           logic [4:0] reg_rd_id);
    logic reg_illegal;
    reg_illegal = 1'b0;
    if (((control.encoding == R_TYPE||control.encoding == I_TYPE||control.encoding == U_TYPE||control.encoding == J_TYPE) 
         && reg_rd_id == 0) || reg_rd_id >= REGISTER_FILE_SIZE) begin
      if(instruction.opcode != 7'b1100111 && instruction != 32'h00000013)
        reg_illegal = 1'b1;
    end
    if ((control.encoding == R_TYPE||control.encoding == I_TYPE||control.encoding == S_TYPE
        ||control.encoding == B_TYPE)&&instruction.rs1 >= REGISTER_FILE_SIZE) begin
      reg_illegal = 1'b1;
    end
    if ((control.encoding == R_TYPE||control.encoding == S_TYPE||control.encoding == B_TYPE)
        && instruction.rs2 >= REGISTER_FILE_SIZE) begin
      reg_illegal = 1'b1;
    end
    return reg_illegal;
  endfunction

  // Input stream: compute expected and store by pc_tag
  function void write_in(decode_in_tx t);
    exp_t exp;
    control_type c;
    logic decode_failed;
    if ($isunknown(t.pc_tag)) begin
      `uvm_warning(get_type_name(), "Skip write_in with X pc_tag")
      return;
    end
    ref_decode(t.instruction, c, decode_failed);
    exp.control = c;
    exp.imm     = immediate_extension(t.instruction, c.encoding);
    exp.rd      = t.instruction.rd;
    exp.pc_in   = t.pc_in;
    exp.pc_tag  = t.pc_tag;
    exp.instruction_illegal = decode_failed | ref_reg_illegal(c, t.instruction, t.instruction.rd);
    exp.rs1 = t.instruction.rs1;
    exp.rs2 = t.instruction.rs2;
    exp_by_pc[t.pc_tag].push_back(exp);
    `uvm_info(get_type_name(), $sformatf("Stored expectation pc_tag=0x%0h depth=%0d", t.pc_tag, exp_by_pc[t.pc_tag].size()), UVM_DEBUG)
  endfunction

  // Output stream: compare with expected
  function void write_out(decode_out_tx t);
    exp_t exp;
    if ($isunknown(t.pc_tag)) begin
      `uvm_warning(get_type_name(), "Skip write_out with X pc_tag")
      return;
    end
    if (!exp_by_pc.exists(t.pc_tag) || exp_by_pc[t.pc_tag].size() == 0) begin
      `uvm_warning(get_type_name(), $sformatf("No expected entry available for pc_tag=0x%0h", t.pc_tag))
      return;
    end
    exp = exp_by_pc[t.pc_tag].pop_front();

    // Assertions / checks
    // reg_rd_id
    if (t.reg_rd_id !== exp.rd) begin
      `uvm_error(get_type_name(), $sformatf("reg_rd_id mismatch tag exp=%0d got=%0d", exp.rd, t.reg_rd_id));
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("reg_rd_id match: %0d", t.reg_rd_id), UVM_LOW);
    end

    // pc_out vs pc_in
    if (t.pc_out !== exp.pc_in) begin
      `uvm_error(get_type_name(), $sformatf("pc_out mismatch tag exp=0x%0h got=0x%0h", exp.pc_in, t.pc_out));
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("pc_out match: 0x%0h", t.pc_out), UVM_LOW);
    end

    // read_data checks against regfile model
    if (regfile[exp.rs1] !== t.read_data1) begin
      `uvm_error(get_type_name(), $sformatf("read_data1 mismatch rs1=%0d exp=0x%0h got=0x%0h", exp.rs1, regfile[exp.rs1], t.read_data1));
    end else begin
      `uvm_info(get_type_name(), $sformatf("read_data1 match rs1=%0d val=0x%0h", exp.rs1, t.read_data1), UVM_LOW);
    end
    if (regfile[exp.rs2] !== t.read_data2) begin
      `uvm_error(get_type_name(), $sformatf("read_data2 mismatch rs2=%0d exp=0x%0h got=0x%0h", exp.rs2, regfile[exp.rs2], t.read_data2));
    end else begin
      `uvm_info(get_type_name(), $sformatf("read_data2 match rs2=%0d val=0x%0h", exp.rs2, t.read_data2), UVM_LOW);
    end
    if (x0_write_attempted) begin
      if (exp.rs1 == 0 && t.read_data1 !== 32'h0)
        `uvm_error(get_type_name(), $sformatf("x0 changed after write attempt: read_data1=0x%0h", t.read_data1))
      if (exp.rs2 == 0 && t.read_data2 !== 32'h0)
        `uvm_error(get_type_name(), $sformatf("x0 changed after write attempt: read_data2=0x%0h", t.read_data2))
    end

    // immediate
    if (t.immediate_data !== exp.imm) begin
      `uvm_error(get_type_name(), $sformatf("immediate mismatch tag exp=0x%0h got=0x%0h", exp.imm, t.immediate_data));
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("immediate match: 0x%0h", t.immediate_data), UVM_LOW);
    end

    // control
    if (t.control_signals !== exp.control) begin
      `uvm_error(get_type_name(), "control mismatch");
    end
    else begin
      `uvm_info(get_type_name(), "control match", UVM_LOW);
    end

    // illegal flag
    if (t.instruction_illegal !== exp.instruction_illegal) begin
      `uvm_error(get_type_name(), $sformatf("illegal mismatch exp=%0b got=%0b", exp.instruction_illegal, t.instruction_illegal));
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("illegal match: %0b", t.instruction_illegal), UVM_LOW);
    end

    if (t.reg_rd_id === exp.rd &&
        t.pc_out === exp.pc_in &&
        t.immediate_data === exp.imm &&
        t.control_signals === exp.control &&
        t.instruction_illegal === exp.instruction_illegal) begin
      `uvm_info(get_type_name(),
        $sformatf("PASS pc_tag=0x%0h rd=%0d imm=0x%0h pc_out=0x%0h illegal=%0b",
                  t.pc_tag, t.reg_rd_id, t.immediate_data, t.pc_out, t.instruction_illegal),
        UVM_MEDIUM)
    end else begin
      `uvm_info(get_type_name(),
        $sformatf("MISMATCH pc_tag=0x%0h exp(rd=%0d imm=0x%0h pc=0x%0h illegal=%0b) got(rd=%0d imm=0x%0h pc=0x%0h illegal=%0b)",
                  t.pc_tag,
                  exp.rd, exp.imm, exp.pc_in, exp.instruction_illegal,
                  t.reg_rd_id, t.immediate_data, t.pc_out, t.instruction_illegal),
        UVM_MEDIUM)
    end
  endfunction

  // writeback stream updates regfile model
  function void write_wb(decode_wb_tx t);
    if (t.write_en && t.write_id == 0) begin
      x0_write_attempted = 1'b1;
      `uvm_info(get_type_name(), "Write to x0 attempted; expecting x0 to remain 0", UVM_LOW)
    end
    if (t.write_en && t.write_id != 0) begin
      regfile[t.write_id] = t.write_data;
      `uvm_info(get_type_name(), $sformatf("WB update rd=%0d data=0x%0h", t.write_id, t.write_data), UVM_LOW)
    end
  endfunction

endclass : decode_scoreboard

`endif // DECODE_SCOREBOARD_SV
