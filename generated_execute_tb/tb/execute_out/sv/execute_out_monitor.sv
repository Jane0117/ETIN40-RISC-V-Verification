// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Monitor for execute_out
//=============================================================================

`ifndef EXECUTE_OUT_MONITOR_SV
`define EXECUTE_OUT_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file execute_out.tpl

class execute_out_monitor extends uvm_monitor;

  `uvm_component_utils(execute_out_monitor)

  virtual execute_out_if vif;

  execute_out_config     m_config;

  uvm_analysis_port #(execute_out_tx) analysis_port;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting monitor_inc_inside_class in file execute_out.tpl

endclass : execute_out_monitor 


function execute_out_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


// You can insert code here by setting monitor_inc_after_class in file execute_out.tpl

`endif // EXECUTE_OUT_MONITOR_SV

