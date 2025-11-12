// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Monitor for forward
//=============================================================================

`ifndef FORWARD_MONITOR_SV
`define FORWARD_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file forward.tpl

class forward_monitor extends uvm_monitor;

  `uvm_component_utils(forward_monitor)

  virtual forward_if vif;

  forward_config     m_config;

  uvm_analysis_port #(forward_tx) analysis_port;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting monitor_inc_inside_class in file forward.tpl

endclass : forward_monitor 


function forward_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


// You can insert code here by setting monitor_inc_after_class in file forward.tpl

`endif // FORWARD_MONITOR_SV

