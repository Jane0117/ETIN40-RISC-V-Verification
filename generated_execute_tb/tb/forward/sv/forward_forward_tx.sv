// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Sequence item for forward_sequencer
//=============================================================================

`ifndef FORWARD_SEQ_ITEM_SV
`define FORWARD_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file forward.tpl

class forward_tx extends uvm_sequence_item; 

  `uvm_object_utils(forward_tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file forward.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file forward.tpl

  // Transaction variables
  rand logic [31:0] wb_forward_data;
  rand logic [31:0] mem_forward_data;
  rand forward_type  forward_rs1;
  rand forward_type  forward_rs2;


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file forward.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file forward.tpl

endclass : forward_tx 


function forward_tx::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file forward.tpl

function void forward_tx::do_copy(uvm_object rhs);
  forward_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  wb_forward_data  = rhs_.wb_forward_data; 
  mem_forward_data = rhs_.mem_forward_data;
  forward_rs1      = rhs_.forward_rs1;     
  forward_rs2      = rhs_.forward_rs2;     
endfunction : do_copy


function bit forward_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  forward_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("wb_forward_data", wb_forward_data,   rhs_.wb_forward_data,  $bits(wb_forward_data));
  result &= comparer.compare_field("mem_forward_data", mem_forward_data, rhs_.mem_forward_data, $bits(mem_forward_data));
  result &= comparer.compare_field("forward_rs1", forward_rs1,           rhs_.forward_rs1,      $bits(forward_rs1));
  result &= comparer.compare_field("forward_rs2", forward_rs2,           rhs_.forward_rs2,      $bits(forward_rs2));
  return result;
endfunction : do_compare


function void forward_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void forward_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("wb_forward_data",  wb_forward_data) 
  `uvm_record_field("mem_forward_data", mem_forward_data)
  `uvm_record_field("forward_rs1",      forward_rs1)     
  `uvm_record_field("forward_rs2",      forward_rs2)     
endfunction : do_record


function void forward_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(wb_forward_data)  
  `uvm_pack_int(mem_forward_data) 
  `uvm_pack_int(forward_rs1)      
  `uvm_pack_int(forward_rs2)      
endfunction : do_pack


function void forward_tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(wb_forward_data)  
  `uvm_unpack_int(mem_forward_data) 
  `uvm_unpack_int(forward_rs1)      
  `uvm_unpack_int(forward_rs2)      
endfunction : do_unpack


function string forward_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "wb_forward_data  = 'h%0h  'd%0d\n", 
    "mem_forward_data = 'h%0h  'd%0d\n", 
    "forward_rs1      = 'h%0h  'd%0d\n", 
    "forward_rs2      = 'h%0h  'd%0d\n"},
    get_full_name(), wb_forward_data, wb_forward_data, mem_forward_data, mem_forward_data, forward_rs1, forward_rs1, forward_rs2, forward_rs2);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file forward.tpl

`endif // FORWARD_SEQ_ITEM_SV

