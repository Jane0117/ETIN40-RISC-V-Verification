// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Monitor for alu
//=============================================================================

`ifndef ALU_MONITOR_SV
`define ALU_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file .\\alu.tpl

class alu_monitor extends uvm_monitor;

  `uvm_component_utils(alu_monitor)

  virtual alu_if vif;

  alu_config     m_config;

  uvm_analysis_port #(alu_seq_item) analysis_port;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting monitor_inc_inside_class in file .\\alu.tpl

endclass : alu_monitor 


function alu_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


// You can insert code here by setting monitor_inc_after_class in file .\\alu.tpl

`endif // ALU_MONITOR_SV

