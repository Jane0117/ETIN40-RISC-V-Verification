// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Configuration for execute_top
//=============================================================================

`ifndef EXECUTE_TOP_CONFIG_SV
`define EXECUTE_TOP_CONFIG_SV

// You can insert code here by setting top_env_config_inc_before_class in file execute_common.tpl

class execute_top_config extends uvm_object;

  // Do not register config class with the factory

  virtual decode_in_if     decode_in_vif;              
  virtual forward_if       forward_vif;                
  virtual execute_out_if   execute_out_vif;            

  uvm_active_passive_enum  is_active_decode_in         = UVM_ACTIVE;
  uvm_active_passive_enum  is_active_forward           = UVM_ACTIVE;
  uvm_active_passive_enum  is_active_execute_out       = UVM_ACTIVE;

  bit                      checks_enable_decode_in;    
  bit                      checks_enable_forward;      
  bit                      checks_enable_execute_out;  

  bit                      coverage_enable_decode_in;  
  bit                      coverage_enable_forward;    
  bit                      coverage_enable_execute_out;

  // You can insert variables here by setting config_var in file execute_common.tpl

  // You can remove new by setting top_env_config_generate_methods_inside_class = no in file execute_common.tpl

  extern function new(string name = "");

  // You can insert code here by setting top_env_config_inc_inside_class in file execute_common.tpl

endclass : execute_top_config 


// You can remove new by setting top_env_config_generate_methods_after_class = no in file execute_common.tpl

function execute_top_config::new(string name = "");
  super.new(name);

  // You can insert code here by setting top_env_config_append_to_new in file execute_common.tpl

endfunction : new


// You can insert code here by setting top_env_config_inc_after_class in file execute_common.tpl

`endif // EXECUTE_TOP_CONFIG_SV

