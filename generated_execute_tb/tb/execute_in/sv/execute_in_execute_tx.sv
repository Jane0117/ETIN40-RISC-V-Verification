// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Sequence item for execute_in_sequencer
//=============================================================================

`ifndef EXECUTE_IN_SEQ_ITEM_SV
`define EXECUTE_IN_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file execute_in.tpl

class execute_tx extends uvm_sequence_item; 

  `uvm_object_utils(execute_tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file execute_in.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file execute_in.tpl

  // Transaction variables
  rand logic [31:0] data1;
  rand logic [31:0] data2;
  rand logic [31:0] immediate_data;
  rand logic [31:0] pc_in;
  rand control_type  control_in;

  constraint c_basic {
    pc_in[1:0] == 2'b00;
    !(control_in.mem_read && control_in.mem_write);

    // 如果不是访存，则 mem 相关信号应处于“空”状态
    if (!(control_in.mem_read || control_in.mem_write)) {
      control_in.mem_size == 2'b00;
      control_in.mem_sign == 1'b0;
      control_in.mem_to_reg == 1'b0;
    }
  }

  constraint c_encoding_relation {

    // R_TYPE：纯 ALU 寄存器运算
    if (control_in.encoding == R_TYPE) {
      control_in.mem_read   == 1'b0;
      control_in.mem_write  == 1'b0;
      control_in.mem_to_reg == 1'b0;
      control_in.is_branch  == 1'b0;
      control_in.reg_write  == 1'b1;   // 写回寄存器
      control_in.alu_src    == 1'b0;   // 使用 data1/data2
      control_in.alu_op inside {
        ALU_AND, ALU_OR, ALU_XOR,
        ALU_ADD, ALU_SUB,
        ALU_SLT, ALU_SLTU,
        ALU_SLL, ALU_SRL, ALU_SRA
      };
    }

    // I_TYPE：ALU 立即数 / LOAD
    if (control_in.encoding == I_TYPE) {
      control_in.alu_src == 1'b1; // 使用 immediate_data

      if (control_in.mem_read) {
        // LOAD 指令
        control_in.mem_write  == 1'b0;
        control_in.reg_write  == 1'b1;
        control_in.mem_to_reg == 1'b1; // 从 memory 写回
        control_in.is_branch  == 1'b0;
        control_in.alu_op     == ALU_ADD; // 地址 = data1 + imm
      }
      else {
        // I 型 ALU：ADDI/ANDI/ORI/...（简化假设）
        control_in.mem_write  == 1'b0;
        control_in.mem_to_reg == 1'b0;
        control_in.reg_write  == 1'b1;
        control_in.is_branch  == 1'b0;
        control_in.alu_op inside {
          ALU_AND, ALU_OR, ALU_XOR,
          ALU_ADD,
          ALU_SLT, ALU_SLTU,
          ALU_SLL, ALU_SRL, ALU_SRA
        };
      }
    }

    // S_TYPE：STORE
    if (control_in.encoding == S_TYPE) {
      control_in.mem_read   == 1'b0;
      control_in.mem_write  == 1'b1;
      control_in.reg_write  == 1'b0;
      control_in.mem_to_reg == 1'b0;
      control_in.is_branch  == 1'b0;
      control_in.alu_src    == 1'b1;   // base + imm
      control_in.alu_op     == ALU_ADD;
    }

    // B_TYPE：分支
    if (control_in.encoding == B_TYPE) {
      control_in.mem_read   == 1'b0;
      control_in.mem_write  == 1'b0;
      control_in.mem_to_reg == 1'b0;
      control_in.reg_write  == 1'b0;
      control_in.is_branch  == 1'b1;
      // 选择一部分 branch op（你实际实现了哪些就填哪些）
      control_in.alu_op inside { B_BNE, B_BLT, B_BGE, B_LTU, B_GEU };
    }

    // U_TYPE：LUI/AUIPC —— 这里先只考虑 LUI
    if (control_in.encoding == U_TYPE) {
      control_in.mem_read   == 1'b0;
      control_in.mem_write  == 1'b0;
      control_in.mem_to_reg == 1'b0;
      control_in.reg_write  == 1'b1;
      control_in.is_branch  == 1'b0;
      control_in.alu_op     == ALU_LUI;
      // alu_src 是否使用 imm，看你实现，这里不强约束
    }

    // J_TYPE：JAL/JALR
    if (control_in.encoding == J_TYPE) {
      control_in.mem_read   == 1'b0;
      control_in.mem_write  == 1'b0;
      control_in.mem_to_reg == 1'b0;
      control_in.reg_write  == 1'b1;  // 写 rd = PC+4
      // is_branch 是否置 1 取决于你的设计，这里可以不约束或者设为 1
      // control_in.is_branch  == 1'b1;
    }
  }

    // -------------------------
  // immediate 与 PC 的简单关系
  // -------------------------
  constraint c_immediate_branch_align {
    // B/J 型立即数来自 immediate_extension，最低位应为 0（2 字节对齐）
    if (control_in.encoding == B_TYPE || control_in.encoding == J_TYPE) {
      immediate_data[0] == 1'b0;
    }
  }

    // -------------------------
  // 访存地址对齐约束
  // -------------------------
  constraint c_memory_addr_align {
    if (control_in.mem_read || control_in.mem_write) {

      // 字访问：地址 4 对齐
      if (control_in.mem_size == 2'b10) {
        ((data1 + immediate_data) & 32'h3) == 0;

      }

      // 半字访问：地址 2 对齐
      if (control_in.mem_size == 2'b01) {
        ((data1 + immediate_data) & 32'h1) == 0;

      }

      // 字节访问：不做对齐约束
    }
  }

  // -------------------------
  // 访存地址范围约束（可按实际内存范围调整）
  // -------------------------
  localparam bit [31:0] MEM_BASE  = 32'h0000_1000;
  localparam bit [31:0] MEM_LIMIT = 32'h0000_FFFF;

  constraint c_memory_addr_range {
    if (control_in.mem_read || control_in.mem_write) {
      (data1 + immediate_data) inside {[MEM_BASE : MEM_LIMIT]};
    }
  }

  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file execute_in.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file execute_in.tpl

endclass : execute_tx 


function execute_tx::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file execute_in.tpl

function void execute_tx::do_copy(uvm_object rhs);
  execute_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  data1          = rhs_.data1;         
  data2          = rhs_.data2;         
  immediate_data = rhs_.immediate_data;
  pc_in          = rhs_.pc_in;         
  control_in     = rhs_.control_in;    
endfunction : do_copy


function bit execute_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  execute_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("data1", data1,                   rhs_.data1,          $bits(data1));
  result &= comparer.compare_field("data2", data2,                   rhs_.data2,          $bits(data2));
  result &= comparer.compare_field("immediate_data", immediate_data, rhs_.immediate_data, $bits(immediate_data));
  result &= comparer.compare_field("pc_in", pc_in,                   rhs_.pc_in,          $bits(pc_in));
  result &= comparer.compare_field("control_in", control_in,         rhs_.control_in,     $bits(control_in));
  return result;
endfunction : do_compare


function void execute_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void execute_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("data1",          data1)         
  `uvm_record_field("data2",          data2)         
  `uvm_record_field("immediate_data", immediate_data)
  `uvm_record_field("pc_in",          pc_in)         
  `uvm_record_field("control_in",     control_in)    
endfunction : do_record


function void execute_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(data1)          
  `uvm_pack_int(data2)          
  `uvm_pack_int(immediate_data) 
  `uvm_pack_int(pc_in)          
  `uvm_pack_int(control_in)     
endfunction : do_pack


function void execute_tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(data1)          
  `uvm_unpack_int(data2)          
  `uvm_unpack_int(immediate_data) 
  `uvm_unpack_int(pc_in)          
  `uvm_unpack_int(control_in)     
endfunction : do_unpack


function string execute_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "data1          = 'h%0h  'd%0d\n", 
    "data2          = 'h%0h  'd%0d\n", 
    "immediate_data = 'h%0h  'd%0d\n", 
    "pc_in          = 'h%0h  'd%0d\n", 
    "control_in     = 'h%0h  'd%0d\n"},
    get_full_name(), data1, data1, data2, data2, immediate_data, immediate_data, pc_in, pc_in, control_in, control_in);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file execute_in.tpl

`endif // EXECUTE_IN_SEQ_ITEM_SV

