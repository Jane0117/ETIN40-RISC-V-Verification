// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Driver for alu
//=============================================================================

`ifndef ALU_DRIVER_SV
`define ALU_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file .\\alu.tpl

class alu_driver extends uvm_driver #(alu_seq_item);

  `uvm_component_utils(alu_driver)

  virtual alu_if vif;

  alu_config     m_config;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file .\\alu.tpl

endclass : alu_driver 


function alu_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting driver_inc_after_class in file .\\alu.tpl

`endif // ALU_DRIVER_SV

