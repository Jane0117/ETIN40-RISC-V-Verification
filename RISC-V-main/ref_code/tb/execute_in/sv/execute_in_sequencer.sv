// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_sequencer.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Sequencer for execute_in
//=============================================================================

`ifndef EXECUTE_IN_SEQUENCER_SV
`define EXECUTE_IN_SEQUENCER_SV

// You can insert code here by setting sequencer_inc_before_class in file execute_in.tpl

class execute_in_sequencer extends uvm_sequencer #(execute_tx);

  `uvm_component_utils(execute_in_sequencer)

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting sequencer_inc_inside_class in file execute_in.tpl

endclass : execute_in_sequencer 


function execute_in_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting sequencer_inc_after_class in file execute_in.tpl


typedef execute_in_sequencer execute_in_sequencer_t;


`endif // EXECUTE_IN_SEQUENCER_SV

