// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_sequencer.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Sequencer for forward
//=============================================================================

`ifndef FORWARD_SEQUENCER_SV
`define FORWARD_SEQUENCER_SV

// You can insert code here by setting sequencer_inc_before_class in file forward.tpl

class forward_sequencer extends uvm_sequencer #(forward_tx);

  `uvm_component_utils(forward_sequencer)

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting sequencer_inc_inside_class in file forward.tpl

endclass : forward_sequencer 


function forward_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting sequencer_inc_after_class in file forward.tpl


typedef forward_sequencer forward_sequencer_t;


`endif // FORWARD_SEQUENCER_SV

