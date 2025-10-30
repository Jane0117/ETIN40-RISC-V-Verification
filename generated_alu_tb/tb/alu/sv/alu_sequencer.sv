// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_sequencer.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Sequencer for alu
//=============================================================================

`ifndef ALU_SEQUENCER_SV
`define ALU_SEQUENCER_SV

// You can insert code here by setting sequencer_inc_before_class in file .\\alu.tpl

class alu_sequencer extends uvm_sequencer #(alu_seq_item);

  `uvm_component_utils(alu_sequencer)

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting sequencer_inc_inside_class in file .\\alu.tpl

endclass : alu_sequencer 


function alu_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting sequencer_inc_after_class in file .\\alu.tpl


typedef alu_sequencer alu_sequencer_t;


`endif // ALU_SEQUENCER_SV

