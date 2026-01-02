// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_out_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Driver for decode_out
//=============================================================================

`ifndef DECODE_OUT_DRIVER_SV
`define DECODE_OUT_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file decode_out.tpl

class decode_out_driver extends uvm_driver #(decode_out_tx);

  `uvm_component_utils(decode_out_driver)

  virtual decode_out_if vif;

  decode_out_config     m_config;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file decode_out.tpl

endclass : decode_out_driver 


function decode_out_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting driver_inc_after_class in file decode_out.tpl

`endif // DECODE_OUT_DRIVER_SV

