// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_out_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequence item for decode_out_sequencer
//=============================================================================

`ifndef DECODE_OUT_SEQ_ITEM_SV
`define DECODE_OUT_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file decode_out.tpl

class decode_out_tx extends uvm_sequence_item; 

  `uvm_object_utils(decode_out_tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file decode_out.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file decode_out.tpl

  // Transaction variables
  logic [4:0]   reg_rd_id;
  logic [31:0]  read_data1;
  logic [31:0]  read_data2;
  logic [31:0]  immediate_data;
  logic [31:0]  pc_out;
  logic [31:0]  pc_tag;
  logic         instruction_illegal;
  control_type  control_signals;


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file decode_out.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file decode_out.tpl

endclass : decode_out_tx 


function decode_out_tx::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file decode_out.tpl

function void decode_out_tx::do_copy(uvm_object rhs);
  decode_out_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  reg_rd_id           = rhs_.reg_rd_id;          
  read_data1          = rhs_.read_data1;         
  read_data2          = rhs_.read_data2;         
  immediate_data      = rhs_.immediate_data;     
  pc_out              = rhs_.pc_out;             
  pc_tag              = rhs_.pc_tag;             
  instruction_illegal = rhs_.instruction_illegal;
  control_signals     = rhs_.control_signals;    
endfunction : do_copy


function bit decode_out_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  decode_out_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("reg_rd_id", reg_rd_id,                     rhs_.reg_rd_id,           $bits(reg_rd_id));
  result &= comparer.compare_field("read_data1", read_data1,                   rhs_.read_data1,          $bits(read_data1));
  result &= comparer.compare_field("read_data2", read_data2,                   rhs_.read_data2,          $bits(read_data2));
  result &= comparer.compare_field("immediate_data", immediate_data,           rhs_.immediate_data,      $bits(immediate_data));
  result &= comparer.compare_field("pc_out", pc_out,                           rhs_.pc_out,              $bits(pc_out));
  result &= comparer.compare_field("pc_tag", pc_tag,                           rhs_.pc_tag,              $bits(pc_tag));
  result &= comparer.compare_field("instruction_illegal", instruction_illegal, rhs_.instruction_illegal, $bits(instruction_illegal));
  result &= comparer.compare_field("control_signals", control_signals,         rhs_.control_signals,     $bits(control_signals));
  return result;
endfunction : do_compare


function void decode_out_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void decode_out_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("reg_rd_id",           reg_rd_id)          
  `uvm_record_field("read_data1",          read_data1)         
  `uvm_record_field("read_data2",          read_data2)         
  `uvm_record_field("immediate_data",      immediate_data)     
  `uvm_record_field("pc_out",              pc_out)             
  `uvm_record_field("pc_tag",              pc_tag)             
  `uvm_record_field("instruction_illegal", instruction_illegal)
  `uvm_record_field("control_signals",     control_signals)    
endfunction : do_record


function void decode_out_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(reg_rd_id)           
  `uvm_pack_int(read_data1)          
  `uvm_pack_int(read_data2)          
  `uvm_pack_int(immediate_data)      
  `uvm_pack_int(pc_out)              
  `uvm_pack_int(pc_tag)              
  `uvm_pack_int(instruction_illegal) 
  `uvm_pack_int(control_signals)     
endfunction : do_pack


function void decode_out_tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(reg_rd_id)           
  `uvm_unpack_int(read_data1)          
  `uvm_unpack_int(read_data2)          
  `uvm_unpack_int(immediate_data)      
  `uvm_unpack_int(pc_out)              
  `uvm_unpack_int(pc_tag)              
  `uvm_unpack_int(instruction_illegal) 
  `uvm_unpack_int(control_signals)     
endfunction : do_unpack


function string decode_out_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "reg_rd_id           = 'h%0h  'd%0d\n", 
    "read_data1          = 'h%0h  'd%0d\n", 
    "read_data2          = 'h%0h  'd%0d\n", 
    "immediate_data      = 'h%0h  'd%0d\n", 
    "pc_out              = 'h%0h  'd%0d\n", 
    "pc_tag              = 'h%0h  'd%0d\n", 
    "instruction_illegal = 'h%0h  'd%0d\n", 
    "control_signals     = 'h%0h  'd%0d\n"},
    get_full_name(), reg_rd_id, reg_rd_id, read_data1, read_data1, read_data2, read_data2, immediate_data, immediate_data, pc_out, pc_out, pc_tag, pc_tag, instruction_illegal, instruction_illegal, control_signals, control_signals);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file decode_out.tpl

`endif // DECODE_OUT_SEQ_ITEM_SV

