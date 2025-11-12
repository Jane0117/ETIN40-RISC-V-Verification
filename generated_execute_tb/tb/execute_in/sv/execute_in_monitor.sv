// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Monitor for execute_in
//=============================================================================

`ifndef EXECUTE_IN_MONITOR_SV
`define EXECUTE_IN_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file execute_in.tpl

class execute_in_monitor extends uvm_monitor;

  `uvm_component_utils(execute_in_monitor)

  virtual execute_in_if vif;

  execute_in_config     m_config;

  uvm_analysis_port #(execute_tx) analysis_port;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting monitor_inc_inside_class in file execute_in.tpl

endclass : execute_in_monitor 


function execute_in_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


// You can insert code here by setting monitor_inc_after_class in file execute_in.tpl

`endif // EXECUTE_IN_MONITOR_SV

