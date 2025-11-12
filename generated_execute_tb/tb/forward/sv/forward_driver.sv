// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Driver for forward
//=============================================================================

`ifndef FORWARD_DRIVER_SV
`define FORWARD_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file forward.tpl

class forward_driver extends uvm_driver #(forward_tx);

  `uvm_component_utils(forward_driver)

  virtual forward_if vif;

  forward_config     m_config;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file forward.tpl

endclass : forward_driver 


function forward_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting driver_inc_after_class in file forward.tpl

`endif // FORWARD_DRIVER_SV

