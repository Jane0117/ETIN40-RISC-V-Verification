// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Sequence for agent alu
//=============================================================================

`ifndef ALU_SEQ_LIB_SV
`define ALU_SEQ_LIB_SV

class alu_default_seq extends uvm_sequence #(alu_seq_item);

  `uvm_object_utils(alu_default_seq)

  alu_config  m_config;

  extern function new(string name = "");
  extern task body();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : alu_default_seq


function alu_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task alu_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)

  req = alu_seq_item::type_id::create("req");
  start_item(req); 
  if ( !req.randomize() )
    `uvm_error(get_type_name(), "Failed to randomize transaction")
  finish_item(req); 

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


`ifndef UVM_POST_VERSION_1_1
function uvm_phase alu_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void alu_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting agent_seq_inc in file .\\alu.tpl

`endif // ALU_SEQ_LIB_SV

