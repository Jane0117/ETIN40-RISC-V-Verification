// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_sequencer.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequencer for decode_wb
//=============================================================================

`ifndef DECODE_WB_SEQUENCER_SV
`define DECODE_WB_SEQUENCER_SV

// You can insert code here by setting sequencer_inc_before_class in file decode_wb.tpl

class decode_wb_sequencer extends uvm_sequencer #(decode_wb_tx);

  `uvm_component_utils(decode_wb_sequencer)

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting sequencer_inc_inside_class in file decode_wb.tpl

endclass : decode_wb_sequencer 


function decode_wb_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting sequencer_inc_after_class in file decode_wb.tpl


typedef decode_wb_sequencer decode_wb_sequencer_t;


`endif // DECODE_WB_SEQUENCER_SV

