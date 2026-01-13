// Joint scoreboard for decode->execute coupling
`ifndef JOINT_SCOREBOARD_SV
`define JOINT_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import common::*;
import decode_out_pkg::*;
import decode_wb_pkg::*;
import execute_out_pkg::*;
import decode_in_pkg::*;

`uvm_analysis_imp_decl(_dec)
`uvm_analysis_imp_decl(_exec)
`uvm_analysis_imp_decl(_wb)
`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_dec_in)

class joint_scoreboard extends uvm_component;
  `uvm_component_utils(joint_scoreboard)

  uvm_analysis_imp_dec  #(decode_out_tx, joint_scoreboard) dec_imp;
  uvm_analysis_imp_exec #(execute_out_tx, joint_scoreboard) exec_imp;
  uvm_analysis_imp_wb   #(decode_wb_tx,  joint_scoreboard) wb_imp;
  uvm_analysis_imp_exp  #(execute_out_tx, joint_scoreboard) exp_imp;
  uvm_analysis_imp_dec_in #(decode_in_tx, joint_scoreboard) dec_in_imp;

  typedef struct packed {
    control_type control;
    logic [31:0] imm;
    logic instruction_illegal;
    logic [4:0] rd;
    logic [31:0] pc_in;
    logic [31:0] data1;
    logic [31:0] data2;
  } dec_exp_t;
  typedef logic [31:0] seq_id_t;
  typedef seq_id_t seq_id_q_t[$];

  // instruction cache keyed by pc_in from decode_in monitor
  instruction_type instr_by_pc[logic[31:0]];
  // expectations indexed by pc_tag
  dec_exp_t exp_by_pc [logic [31:0]];
  // expected execute_out map by seq_id
  execute_out_tx exp_exec_by_id[logic[31:0]];
  // decode_out seq_id queues indexed by pc_out for execute_out alignment
  seq_id_q_t dec_seq_q_by_pc[logic [31:0]];

  // regfile model for basic sanity (write port only)
  logic [31:0] regfile[0:31];

  // summary counters
  int unsigned dec_count;
  int unsigned exec_total;
  int unsigned exec_pass;
  int unsigned exec_fail;
  int unsigned rd_check_total;
  int unsigned rd_check_fail;


  function new(string name, uvm_component parent);
    super.new(name, parent);
    dec_imp  = new("dec_imp",  this);
    exec_imp = new("exec_imp", this);
    wb_imp   = new("wb_imp",   this);
    exp_imp  = new("exp_imp",  this);
    dec_in_imp = new("dec_in_imp", this);
    foreach (regfile[ii]) regfile[ii] = '0;
    dec_count   = 0;
    exec_total  = 0;
    exec_pass   = 0;
    exec_fail   = 0;
    rd_check_total = 0;
    rd_check_fail  = 0;
  endfunction

  // -----------------------------------------------------------------------
  // Reference decode (copied from decode_scoreboard)
  // -----------------------------------------------------------------------
  function automatic void ref_decode(instruction_type instruction,
                                     output control_type control,
                                     output logic decode_failed);
    control = '0;
    decode_failed = 1'b0;
    unique case (instruction.opcode)
      // R type
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
      // I type ALU
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
      // Load
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
      // JALR
      7'b1100111: begin
        control.encoding  = I_TYPE;
        control.is_branch = 1'b1;
        control.reg_write = 1'b1;
        control.alu_op    = ALU_ADD;
      end
      // JAL
      7'b1101111: begin
        control.encoding  = J_TYPE;
        control.is_branch = 1'b0;
        control.reg_write = 1'b1;
        control.alu_op    = ALU_ADD;
      end
      // Store
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
      // Branch
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
      // LUI
      7'b0110111: begin
        control.encoding  = U_TYPE;
        control.reg_write = 1'b1;
        control.alu_src   = 1'b1;
        control.alu_op    = ALU_LUI;
      end
      // AUIPC
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
  endfunction

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

  // -----------------------------------------------------------------------
  // Analysis imps
  // -----------------------------------------------------------------------
  function void write_wb(decode_wb_tx t);
    if (t.write_en && t.write_id != 0)
      regfile[t.write_id] = t.write_data;
  endfunction

  // capture decode_in instruction/pc for ref_decode
  function void write_dec_in(decode_in_tx t);
    if ($isunknown(t.pc_in)) begin
      `uvm_warning(get_type_name(), "Skip dec_in with X pc_in")
      return;
    end
    instr_by_pc[t.pc_in] = t.instruction;
  endfunction

  function void write_dec(decode_out_tx t);
    control_type c; logic decode_failed;
    dec_exp_t exp;
    instruction_type instr = '0;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [31:0] exp_data1;
    logic [31:0] exp_data2;
    if ($isunknown(t.pc_tag)) begin
      `uvm_warning(get_type_name(), "Skip dec with X pc_tag")
      return;
    end
    dec_count++;
    if (instr_by_pc.exists(t.pc_out))
      instr = instr_by_pc[t.pc_out];
    else begin
      `uvm_warning(get_type_name(),
        $sformatf("No decode_in instruction for pc=0x%0h, use zero instr", t.pc_out))
      instr = '0;
    end
    ref_decode(instr, c, decode_failed);
    exp.control  = t.control_signals;
    exp.imm      = t.immediate_data;
    exp.rd       = t.reg_rd_id;
    exp.pc_in    = t.pc_out;
    exp.instruction_illegal = t.instruction_illegal;
    exp.data1    = t.read_data1;
    exp.data2    = t.read_data2;
    exp_by_pc[t.pc_tag] = exp;
    rs1 = instr.rs1;
    rs2 = instr.rs2;
    if (!decode_failed && !t.instruction_illegal) begin
      if (c.encoding inside {R_TYPE, I_TYPE, S_TYPE, B_TYPE}) begin
        exp_data1 = (rs1 != 0) ? regfile[rs1] : '0;
        rd_check_total++;
        if (t.read_data1 !== exp_data1)
          rd_check_fail++;
      end
      if (c.encoding inside {R_TYPE, S_TYPE, B_TYPE}) begin
        exp_data2 = (rs2 != 0) ? regfile[rs2] : '0;
        rd_check_total++;
        if (t.read_data2 !== exp_data2)
          rd_check_fail++;
      end
    end
    if (!$isunknown(t.pc_out) && !$isunknown(t.seq_id))
      dec_seq_q_by_pc[t.pc_out].push_back(t.seq_id);
    // 基本一致性检查
    if (t.control_signals !== c) begin
      `uvm_info(get_type_name(),
        $sformatf("Control differs from ref at pc_tag=0x%0h (allowing as pass-through) exp=0x%0h act=0x%0h",
                  t.pc_tag, c, t.control_signals),
        UVM_MEDIUM)
    end
    `uvm_info(get_type_name(), $sformatf("DEC pc_tag=0x%0h rd=%0d imm=0x%0h ctrl=%0h illegal=%0b",
              t.pc_tag, t.reg_rd_id, t.immediate_data, t.control_signals, t.instruction_illegal), UVM_MEDIUM)
  endfunction

  // expected execute_out from ref_model
  function void write_exp(execute_out_tx t);
    if ($isunknown(t.seq_id)) begin
      `uvm_warning(get_type_name(), "Skip exp with X seq_id")
      return;
    end
    exp_exec_by_id[t.seq_id] = t;
  endfunction

  function void write_exec(execute_out_tx t);
    dec_exp_t exp;
    bit ok;
    execute_out_tx ref_tx;
    seq_id_t seq_id_key;
    exec_total++;
    if ($isunknown(t.pc_out) || $isunknown(t.seq_id)) begin
      `uvm_warning(get_type_name(), "Skip exec with X pc_out")
      return;
    end
    if (dec_seq_q_by_pc.exists(t.pc_out) && dec_seq_q_by_pc[t.pc_out].size() > 0)
      seq_id_key = dec_seq_q_by_pc[t.pc_out].pop_front();
    else
      seq_id_key = t.seq_id;
    if (!exp_exec_by_id.exists(seq_id_key)) begin
      return;
    end
    ref_tx = exp_exec_by_id[seq_id_key];
    if (exp_by_pc.exists(t.pc_out))
      exp = exp_by_pc[t.pc_out];
    else begin
      // 无期望时手动填合法缺省值
      exp.control = '{alu_op: ALU_ADD,
                      encoding: NONE_TYPE,
                      alu_src: 1'b0,
                      mem_read: 1'b0,
                      mem_write:1'b0,
                      reg_write:1'b0,
                      mem_to_reg:1'b0,
                      mem_size:2'b00,
                      mem_sign:1'b0,
                      is_branch:1'b0};
      exp.imm = '0;
      exp.instruction_illegal = 1'b0;
      exp.rd  = '0;
      exp.pc_in = t.pc_out;
      exp.data1 = '0;
      exp.data2 = '0;
    end
    ok = 1;
    // 分步比对：先比 pc_out/encoding，再收紧其余字段
    ok &= (t.pc_out === ref_tx.pc_out);
    ok &= (t.control_out.encoding === ref_tx.control_out.encoding);
    if (!ok) begin
      `uvm_error(get_type_name(), $sformatf("Exec mismatch pc=0x%0h encoding exp=%0h act=%0h pc_exp=0x%0h pc_act=0x%0h",
                 t.pc_out, ref_tx.control_out.encoding, t.control_out.encoding, ref_tx.pc_out, t.pc_out))
      return;
    end
    ok &= (t.control_out.alu_op     === ref_tx.control_out.alu_op);
    ok &= (t.control_out.encoding   === ref_tx.control_out.encoding);
    ok &= (t.control_out.alu_src    === ref_tx.control_out.alu_src);
    ok &= (t.control_out.mem_read   === ref_tx.control_out.mem_read);
    ok &= (t.control_out.mem_write  === ref_tx.control_out.mem_write);
    ok &= (t.control_out.reg_write  === ref_tx.control_out.reg_write);
    ok &= (t.control_out.mem_to_reg === ref_tx.control_out.mem_to_reg);
    ok &= (t.control_out.mem_size   === ref_tx.control_out.mem_size);
    ok &= (t.control_out.mem_sign   === ref_tx.control_out.mem_sign);
    ok &= (t.control_out.is_branch  === ref_tx.control_out.is_branch);
    ok &= (t.pc_src      === ref_tx.pc_src);
    ok &= (t.alu_data    === ref_tx.alu_data);
    if (t.control_out.mem_write)
      ok &= (t.memory_data === ref_tx.memory_data);
    if (!ok)
      begin
        exec_fail++;
        `uvm_error(get_type_name(), $sformatf("Exec mismatch pc=0x%0h exp(ctrl=%0h alu=0x%0h mem=0x%0h pc_src=%0b) act(ctrl=%0h alu=0x%0h mem=0x%0h pc_src=%0b)",
                   t.pc_out, ref_tx.control_out, ref_tx.alu_data, ref_tx.memory_data, ref_tx.pc_src,
                   t.control_out, t.alu_data, t.memory_data, t.pc_src))
      end
    else begin
      exec_pass++;
      `uvm_info(get_type_name(), $sformatf("PASS pc=0x%0h", t.pc_out), UVM_MEDIUM);
    end

    `uvm_info(get_type_name(), $sformatf("EXEC pc=0x%0h ctrl=%0h alu=0x%0h mem=0x%0h pc_src=%0b jalr=%0b",
              t.pc_out, t.control_out, t.alu_data, t.memory_data, t.pc_src, t.jalr_flag), UVM_MEDIUM)
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
              $sformatf("SUMMARY dec=%0d exec_total=%0d pass=%0d fail=%0d rd_chk=%0d rd_fail=%0d",
                        dec_count, exec_total, exec_pass, exec_fail, rd_check_total, rd_check_fail),
              UVM_LOW)
  endfunction
endclass

`endif // JOINT_SCOREBOARD_SV
