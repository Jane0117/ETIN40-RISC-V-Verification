// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Sequence for agent execute_out
//=============================================================================

`ifndef EXECUTE_OUT_SEQ_LIB_SV
`define EXECUTE_OUT_SEQ_LIB_SV

class execute_out_default_seq extends uvm_sequence #(execute_out_tx);

  `uvm_object_utils(execute_out_default_seq)

  execute_out_config  m_config;

  extern function new(string name = "");
  extern task body();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : execute_out_default_seq


function execute_out_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task execute_out_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)

  req = execute_out_tx::type_id::create("req");
  start_item(req); 
  if ( !req.randomize() )
    `uvm_error(get_type_name(), "Failed to randomize transaction")
  finish_item(req); 

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


`ifndef UVM_POST_VERSION_1_1
function uvm_phase execute_out_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void execute_out_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting agent_seq_inc in file execute_out.tpl

`endif // EXECUTE_OUT_SEQ_LIB_SV

