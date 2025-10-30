// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Sequence item for alu_sequencer
//=============================================================================

`ifndef ALU_SEQ_ITEM_SV
`define ALU_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file .\\alu.tpl

class alu_seq_item extends uvm_sequence_item; 

  `uvm_object_utils(alu_seq_item)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file .\\alu.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file .\\alu.tpl

  // Transaction variables
  rand logic [3:0]   control;
  rand logic [31:0]  left_operand;
  rand logic [31:0]  right_operand;
  logic         zero_flag;
  logic [31:0]  result;
  logic         overflow;


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file .\\alu.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file .\\alu.tpl

endclass : alu_seq_item 


function alu_seq_item::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file .\\alu.tpl

function void alu_seq_item::do_copy(uvm_object rhs);
  alu_seq_item rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  control       = rhs_.control;      
  left_operand  = rhs_.left_operand; 
  right_operand = rhs_.right_operand;
  zero_flag     = rhs_.zero_flag;    
  result        = rhs_.result;       
  overflow      = rhs_.overflow;     
endfunction : do_copy


function bit alu_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  alu_seq_item rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("control", control,             rhs_.control,       $bits(control));
  result &= comparer.compare_field("left_operand", left_operand,   rhs_.left_operand,  $bits(left_operand));
  result &= comparer.compare_field("right_operand", right_operand, rhs_.right_operand, $bits(right_operand));
  result &= comparer.compare_field("zero_flag", zero_flag,         rhs_.zero_flag,     $bits(zero_flag));
  result &= comparer.compare_field("result", result,               rhs_.result,        $bits(result));
  result &= comparer.compare_field("overflow", overflow,           rhs_.overflow,      $bits(overflow));
  return result;
endfunction : do_compare


function void alu_seq_item::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void alu_seq_item::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("control",       control)      
  `uvm_record_field("left_operand",  left_operand) 
  `uvm_record_field("right_operand", right_operand)
  `uvm_record_field("zero_flag",     zero_flag)    
  `uvm_record_field("result",        result)       
  `uvm_record_field("overflow",      overflow)     
endfunction : do_record


function void alu_seq_item::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(control)       
  `uvm_pack_int(left_operand)  
  `uvm_pack_int(right_operand) 
  `uvm_pack_int(zero_flag)     
  `uvm_pack_int(result)        
  `uvm_pack_int(overflow)      
endfunction : do_pack


function void alu_seq_item::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(control)       
  `uvm_unpack_int(left_operand)  
  `uvm_unpack_int(right_operand) 
  `uvm_unpack_int(zero_flag)     
  `uvm_unpack_int(result)        
  `uvm_unpack_int(overflow)      
endfunction : do_unpack


function string alu_seq_item::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "control       = 'h%0h  'd%0d\n", 
    "left_operand  = 'h%0h  'd%0d\n", 
    "right_operand = 'h%0h  'd%0d\n", 
    "zero_flag     = 'h%0h  'd%0d\n", 
    "result        = 'h%0h  'd%0d\n", 
    "overflow      = 'h%0h  'd%0d\n"},
    get_full_name(), control, control, left_operand, left_operand, right_operand, right_operand, zero_flag, zero_flag, result, result, overflow, overflow);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file .\\alu.tpl

`endif // ALU_SEQ_ITEM_SV

