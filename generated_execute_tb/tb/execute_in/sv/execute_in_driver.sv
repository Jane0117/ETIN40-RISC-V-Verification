// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Driver for execute_in
//=============================================================================

`ifndef EXECUTE_IN_DRIVER_SV
`define EXECUTE_IN_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file execute_in.tpl

class execute_in_driver extends uvm_driver #(execute_tx);

  `uvm_component_utils(execute_in_driver)

  virtual execute_in_if vif;

  execute_in_config     m_config;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file execute_in.tpl

endclass : execute_in_driver 


function execute_in_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting driver_inc_after_class in file execute_in.tpl

`endif // EXECUTE_IN_DRIVER_SV

