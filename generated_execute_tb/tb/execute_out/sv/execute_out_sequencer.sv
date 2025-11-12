// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_sequencer.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Sequencer for execute_out
//=============================================================================

`ifndef EXECUTE_OUT_SEQUENCER_SV
`define EXECUTE_OUT_SEQUENCER_SV

// You can insert code here by setting sequencer_inc_before_class in file execute_out.tpl

class execute_out_sequencer extends uvm_sequencer #(execute_out_tx);

  `uvm_component_utils(execute_out_sequencer)

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting sequencer_inc_inside_class in file execute_out.tpl

endclass : execute_out_sequencer 


function execute_out_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting sequencer_inc_after_class in file execute_out.tpl


typedef execute_out_sequencer execute_out_sequencer_t;


`endif // EXECUTE_OUT_SEQUENCER_SV

