// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Configuration for agent execute_out
//=============================================================================

`ifndef EXECUTE_OUT_CONFIG_SV
`define EXECUTE_OUT_CONFIG_SV

// You can insert code here by setting agent_config_inc_before_class in file execute_out.tpl

class execute_out_config extends uvm_object;

  // Do not register config class with the factory

  virtual execute_out_if   vif;
                  
  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;       
  bit                      checks_enable;         

  // You can insert variables here by setting config_var in file execute_out.tpl

  // You can remove new by setting agent_config_generate_methods_inside_class = no in file execute_out.tpl

  extern function new(string name = "");

  // You can insert code here by setting agent_config_inc_inside_class in file execute_out.tpl

endclass : execute_out_config 


// You can remove new by setting agent_config_generate_methods_after_class = no in file execute_out.tpl

function execute_out_config::new(string name = "");
  super.new(name);
endfunction : new


// You can insert code here by setting agent_config_inc_after_class in file execute_out.tpl

`endif // EXECUTE_OUT_CONFIG_SV

