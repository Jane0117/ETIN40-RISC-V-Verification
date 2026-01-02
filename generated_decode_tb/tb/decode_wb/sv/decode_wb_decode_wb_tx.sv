// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequence item for decode_wb_sequencer
//=============================================================================

`ifndef DECODE_WB_SEQ_ITEM_SV
`define DECODE_WB_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file decode_wb.tpl

class decode_wb_tx extends uvm_sequence_item; 

  `uvm_object_utils(decode_wb_tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file decode_wb.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file decode_wb.tpl

  // Transaction variables
  rand logic        write_en;
  rand logic [4:0]  write_id;
  rand logic [31:0] write_data;


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file decode_wb.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file decode_wb.tpl

endclass : decode_wb_tx 


function decode_wb_tx::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file decode_wb.tpl

function void decode_wb_tx::do_copy(uvm_object rhs);
  decode_wb_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  write_en   = rhs_.write_en;  
  write_id   = rhs_.write_id;  
  write_data = rhs_.write_data;
endfunction : do_copy


function bit decode_wb_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  decode_wb_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("write_en", write_en,     rhs_.write_en,   $bits(write_en));
  result &= comparer.compare_field("write_id", write_id,     rhs_.write_id,   $bits(write_id));
  result &= comparer.compare_field("write_data", write_data, rhs_.write_data, $bits(write_data));
  return result;
endfunction : do_compare


function void decode_wb_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void decode_wb_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("write_en",   write_en)  
  `uvm_record_field("write_id",   write_id)  
  `uvm_record_field("write_data", write_data)
endfunction : do_record


function void decode_wb_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(write_en)   
  `uvm_pack_int(write_id)   
  `uvm_pack_int(write_data) 
endfunction : do_pack


function void decode_wb_tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(write_en)   
  `uvm_unpack_int(write_id)   
  `uvm_unpack_int(write_data) 
endfunction : do_unpack


function string decode_wb_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "write_en   = 'h%0h  'd%0d\n", 
    "write_id   = 'h%0h  'd%0d\n", 
    "write_data = 'h%0h  'd%0d\n"},
    get_full_name(), write_en, write_en, write_id, write_id, write_data, write_data);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file decode_wb.tpl

`endif // DECODE_WB_SEQ_ITEM_SV

