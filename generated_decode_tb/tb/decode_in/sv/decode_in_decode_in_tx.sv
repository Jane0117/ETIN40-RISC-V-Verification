// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_in_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequence item for decode_in_sequencer
//=============================================================================

`ifndef DECODE_IN_SEQ_ITEM_SV
`define DECODE_IN_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file decode_in.tpl

class decode_in_tx extends uvm_sequence_item; 

  `uvm_object_utils(decode_in_tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file decode_in.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file decode_in.tpl

  // Transaction variables
  rand instruction_type instruction;
  rand logic [31:0] pc_in;
  logic [31:0] pc_tag;


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file decode_in.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file decode_in.tpl

endclass : decode_in_tx 


function decode_in_tx::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file decode_in.tpl

function void decode_in_tx::do_copy(uvm_object rhs);
  decode_in_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  instruction = rhs_.instruction;
  pc_in       = rhs_.pc_in;
  pc_tag      = rhs_.pc_tag;      
endfunction : do_copy


function bit decode_in_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  decode_in_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("instruction", instruction, rhs_.instruction, $bits(instruction));
  result &= comparer.compare_field("pc_in", pc_in,             rhs_.pc_in,       $bits(pc_in));
  result &= comparer.compare_field("pc_tag", pc_tag,           rhs_.pc_tag,      $bits(pc_tag));
  return result;
endfunction : do_compare


function void decode_in_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void decode_in_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("instruction", instruction)
  `uvm_record_field("pc_in",       pc_in)
  `uvm_record_field("pc_tag",      pc_tag)      
endfunction : do_record


function void decode_in_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(instruction) 
  `uvm_pack_int(pc_in)
  `uvm_pack_int(pc_tag)       
endfunction : do_pack


function void decode_in_tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(instruction) 
  `uvm_unpack_int(pc_in)
  `uvm_unpack_int(pc_tag)       
endfunction : do_unpack


function string decode_in_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "instruction = 'h%0h  'd%0d\n", 
    "pc_in       = 'h%0h  'd%0d\n",
    "pc_tag      = 'h%0h  'd%0d\n"},
    get_full_name(), instruction, instruction, pc_in, pc_in, pc_tag, pc_tag);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file decode_in.tpl

`endif // DECODE_IN_SEQ_ITEM_SV

