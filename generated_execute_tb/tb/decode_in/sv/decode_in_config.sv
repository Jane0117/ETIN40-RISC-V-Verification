// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: decode_in_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Configuration for agent decode_in
//=============================================================================

`ifndef DECODE_IN_CONFIG_SV
`define DECODE_IN_CONFIG_SV

// You can insert code here by setting agent_config_inc_before_class in file decode_in.tpl

class decode_in_config extends uvm_object;

  // Do not register config class with the factory

  virtual decode_in_if     vif;
                  
  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;       
  bit                      checks_enable;         

  // You can insert variables here by setting config_var in file decode_in.tpl

  // You can remove new by setting agent_config_generate_methods_inside_class = no in file decode_in.tpl

  extern function new(string name = "");

  // You can insert code here by setting agent_config_inc_inside_class in file decode_in.tpl

endclass : decode_in_config 


// You can remove new by setting agent_config_generate_methods_after_class = no in file decode_in.tpl

function decode_in_config::new(string name = "");
  super.new(name);
endfunction : new


// You can insert code here by setting agent_config_inc_after_class in file decode_in.tpl

`endif // DECODE_IN_CONFIG_SV

