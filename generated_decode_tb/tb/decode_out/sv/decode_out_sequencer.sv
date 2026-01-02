// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_out_sequencer.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequencer for decode_out
//=============================================================================

`ifndef DECODE_OUT_SEQUENCER_SV
`define DECODE_OUT_SEQUENCER_SV

// You can insert code here by setting sequencer_inc_before_class in file decode_out.tpl

class decode_out_sequencer extends uvm_sequencer #(decode_out_tx);

  `uvm_component_utils(decode_out_sequencer)

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting sequencer_inc_inside_class in file decode_out.tpl

endclass : decode_out_sequencer 


function decode_out_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting sequencer_inc_after_class in file decode_out.tpl


typedef decode_out_sequencer decode_out_sequencer_t;


`endif // DECODE_OUT_SEQUENCER_SV

