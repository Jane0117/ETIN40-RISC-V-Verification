// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: decode_in_sequencer.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Sequencer for decode_in
//=============================================================================

`ifndef DECODE_IN_SEQUENCER_SV
`define DECODE_IN_SEQUENCER_SV

// You can insert code here by setting sequencer_inc_before_class in file decode_in.tpl

class decode_in_sequencer extends uvm_sequencer #(decode_tx);

  `uvm_component_utils(decode_in_sequencer)

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting sequencer_inc_inside_class in file decode_in.tpl

endclass : decode_in_sequencer 


function decode_in_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting sequencer_inc_after_class in file decode_in.tpl


typedef decode_in_sequencer decode_in_sequencer_t;


`endif // DECODE_IN_SEQUENCER_SV

