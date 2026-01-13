// cpu_typedefs.sv: helper functions and transaction types
`uvm_analysis_imp_decl(_issue)
`uvm_analysis_imp_decl(_wb)
`uvm_analysis_imp_decl(_store)
`uvm_analysis_imp_decl(_branch)
`uvm_analysis_imp_decl(_mem)

function automatic logic [31:0] instr_to_word(input instruction_type instr);
  return {instr.funct7, instr.rs2, instr.rs1, instr.funct3, instr.rd, instr.opcode};
endfunction

function automatic logic [31:0] encode_r(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
  return {funct7, rs2, rs1, funct3, rd, opcode};
endfunction

function automatic logic [31:0] encode_i(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input int imm
);
  logic [11:0] imm12;
  imm12 = imm[11:0];
  return {imm12, rs1, funct3, rd, opcode};
endfunction

function automatic logic [31:0] encode_s(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input int imm
);
  logic [11:0] imm12;
  imm12 = imm[11:0];
  return {imm12[11:5], rs2, rs1, funct3, imm12[4:0], opcode};
endfunction

function automatic logic [31:0] encode_b(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input int imm
);
  logic [12:0] imm13;
  imm13 = imm[12:0];
  return {imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], opcode};
endfunction

function automatic logic [31:0] encode_u(
    input logic [6:0] opcode,
    input logic [4:0] rd,
    input int imm20
);
  logic [19:0] u;
  u = imm20[19:0];
  return {u, rd, opcode};
endfunction

function automatic logic [31:0] encode_j(
    input logic [6:0] opcode,
    input logic [4:0] rd,
    input int imm
);
  logic [20:0] imm21;
  imm21 = imm[20:0];
  return {imm21[20], imm21[10:1], imm21[11], imm21[19:12], rd, opcode};
endfunction

function automatic int shift_imm(input int shamt, input bit is_arith);
  int imm;
  imm = shamt & 5'h1F;
  if (is_arith)
    imm |= 12'h400; // imm[11:5]=0100000 for srai
  return imm;
endfunction

function automatic int calc_offset(input int from_idx, input int to_idx);
  return (to_idx - from_idx) * 4;
endfunction

class issue_tx extends uvm_sequence_item;
  instruction_type instr;
  logic [31:0] pc;
  `uvm_object_utils(issue_tx)
  function new(string name = "issue_tx"); super.new(name); endfunction
  function logic [31:0] word(); return instr_to_word(instr); endfunction
endclass

class wb_tx extends uvm_sequence_item;
  logic [31:0] pc;
  logic [4:0] rd;
  logic [31:0] data;
  bit is_load;
  logic [1:0] mem_size;
  logic mem_sign;
  `uvm_object_utils(wb_tx)
  function new(string name = "wb_tx"); super.new(name); endfunction
endclass

class store_tx extends uvm_sequence_item;
  logic [31:0] pc;
  logic [31:0] addr;
  logic [31:0] data;
  logic [1:0] mem_size;
  `uvm_object_utils(store_tx)
  function new(string name = "store_tx"); super.new(name); endfunction
endclass

class branch_tx extends uvm_sequence_item;
  logic [31:0] pc;
  bit taken;
  logic [2:0] funct3;
  `uvm_object_utils(branch_tx)
  function new(string name = "branch_tx"); super.new(name); endfunction
endclass

class mem_tx extends uvm_sequence_item;
  logic [31:0] addr;
  bit is_read;
  bit is_write;
  logic [1:0] mem_size;
  logic mem_sign;
  `uvm_object_utils(mem_tx)
  function new(string name = "mem_tx"); super.new(name); endfunction
endclass
