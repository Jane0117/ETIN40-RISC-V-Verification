// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: decode_in_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Driver for decode_in
//=============================================================================

`ifndef DECODE_IN_DRIVER_SV
`define DECODE_IN_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file decode_in.tpl

class decode_in_driver extends uvm_driver #(decode_tx);

  `uvm_component_utils(decode_in_driver)

  virtual decode_in_if vif;

  decode_in_config     m_config;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file decode_in.tpl

endclass : decode_in_driver 


function decode_in_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting driver_inc_after_class in file decode_in.tpl

`endif // DECODE_IN_DRIVER_SV

