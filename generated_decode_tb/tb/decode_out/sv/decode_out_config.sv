// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_out_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Configuration for agent decode_out
//=============================================================================

`ifndef DECODE_OUT_CONFIG_SV
`define DECODE_OUT_CONFIG_SV

// You can insert code here by setting agent_config_inc_before_class in file decode_out.tpl

class decode_out_config extends uvm_object;

  // Do not register config class with the factory

  virtual decode_out_if    vif;
                  
  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;       
  bit                      checks_enable;         

  // You can insert variables here by setting config_var in file decode_out.tpl

  // You can remove new by setting agent_config_generate_methods_inside_class = no in file decode_out.tpl

  extern function new(string name = "");

  // You can insert code here by setting agent_config_inc_inside_class in file decode_out.tpl

endclass : decode_out_config 


// You can remove new by setting agent_config_generate_methods_after_class = no in file decode_out.tpl

function decode_out_config::new(string name = "");
  super.new(name);
endfunction : new


// You can insert code here by setting agent_config_inc_after_class in file decode_out.tpl

`endif // DECODE_OUT_CONFIG_SV

