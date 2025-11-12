// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Sequence item for execute_out_sequencer
//=============================================================================

`ifndef EXECUTE_OUT_SEQ_ITEM_SV
`define EXECUTE_OUT_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file execute_out.tpl

class execute_out_tx extends uvm_sequence_item; 

  `uvm_object_utils(execute_out_tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file execute_out.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file execute_out.tpl

  // Transaction variables
  control_type control_out;
  logic [31:0] alu_data;
  logic [31:0] memory_data;
  logic       pc_src;
  logic [31:0] jalr_target_offset;
  logic       jalr_flag;
  logic [31:0] pc_out;
  logic       overflow;


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file execute_out.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file execute_out.tpl

endclass : execute_out_tx 


function execute_out_tx::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file execute_out.tpl

function void execute_out_tx::do_copy(uvm_object rhs);
  execute_out_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  control_out        = rhs_.control_out;       
  alu_data           = rhs_.alu_data;          
  memory_data        = rhs_.memory_data;       
  pc_src             = rhs_.pc_src;            
  jalr_target_offset = rhs_.jalr_target_offset;
  jalr_flag          = rhs_.jalr_flag;         
  pc_out             = rhs_.pc_out;            
  overflow           = rhs_.overflow;          
endfunction : do_copy


function bit execute_out_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  execute_out_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("control_out", control_out,               rhs_.control_out,        $bits(control_out));
  result &= comparer.compare_field("alu_data", alu_data,                     rhs_.alu_data,           $bits(alu_data));
  result &= comparer.compare_field("memory_data", memory_data,               rhs_.memory_data,        $bits(memory_data));
  result &= comparer.compare_field("pc_src", pc_src,                         rhs_.pc_src,             $bits(pc_src));
  result &= comparer.compare_field("jalr_target_offset", jalr_target_offset, rhs_.jalr_target_offset, $bits(jalr_target_offset));
  result &= comparer.compare_field("jalr_flag", jalr_flag,                   rhs_.jalr_flag,          $bits(jalr_flag));
  result &= comparer.compare_field("pc_out", pc_out,                         rhs_.pc_out,             $bits(pc_out));
  result &= comparer.compare_field("overflow", overflow,                     rhs_.overflow,           $bits(overflow));
  return result;
endfunction : do_compare


function void execute_out_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void execute_out_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("control_out",        control_out)       
  `uvm_record_field("alu_data",           alu_data)          
  `uvm_record_field("memory_data",        memory_data)       
  `uvm_record_field("pc_src",             pc_src)            
  `uvm_record_field("jalr_target_offset", jalr_target_offset)
  `uvm_record_field("jalr_flag",          jalr_flag)         
  `uvm_record_field("pc_out",             pc_out)            
  `uvm_record_field("overflow",           overflow)          
endfunction : do_record


function void execute_out_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(control_out)        
  `uvm_pack_int(alu_data)           
  `uvm_pack_int(memory_data)        
  `uvm_pack_int(pc_src)             
  `uvm_pack_int(jalr_target_offset) 
  `uvm_pack_int(jalr_flag)          
  `uvm_pack_int(pc_out)             
  `uvm_pack_int(overflow)           
endfunction : do_pack


function void execute_out_tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(control_out)        
  `uvm_unpack_int(alu_data)           
  `uvm_unpack_int(memory_data)        
  `uvm_unpack_int(pc_src)             
  `uvm_unpack_int(jalr_target_offset) 
  `uvm_unpack_int(jalr_flag)          
  `uvm_unpack_int(pc_out)             
  `uvm_unpack_int(overflow)           
endfunction : do_unpack


function string execute_out_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "control_out        = 'h%0h  'd%0d\n", 
    "alu_data           = 'h%0h  'd%0d\n", 
    "memory_data        = 'h%0h  'd%0d\n", 
    "pc_src             = 'h%0h  'd%0d\n", 
    "jalr_target_offset = 'h%0h  'd%0d\n", 
    "jalr_flag          = 'h%0h  'd%0d\n", 
    "pc_out             = 'h%0h  'd%0d\n", 
    "overflow           = 'h%0h  'd%0d\n"},
    get_full_name(), control_out, control_out, alu_data, alu_data, memory_data, memory_data, pc_src, pc_src, jalr_target_offset, jalr_target_offset, jalr_flag, jalr_flag, pc_out, pc_out, overflow, overflow);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file execute_out.tpl

`endif // EXECUTE_OUT_SEQ_ITEM_SV

