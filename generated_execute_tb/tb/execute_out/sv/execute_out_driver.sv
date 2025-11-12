// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Driver for execute_out
//=============================================================================

`ifndef EXECUTE_OUT_DRIVER_SV
`define EXECUTE_OUT_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file execute_out.tpl

class execute_out_driver extends uvm_driver #(execute_out_tx);

  `uvm_component_utils(execute_out_driver)

  virtual execute_out_if vif;

  execute_out_config     m_config;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file execute_out.tpl

endclass : execute_out_driver 


function execute_out_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting driver_inc_after_class in file execute_out.tpl

`endif // EXECUTE_OUT_DRIVER_SV

