// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Configuration for decode_top
//=============================================================================

`ifndef DECODE_TOP_CONFIG_SV
`define DECODE_TOP_CONFIG_SV

// You can insert code here by setting top_env_config_inc_before_class in file decode_common.tpl

class decode_top_config extends uvm_object;

  // Do not register config class with the factory

  virtual decode_in_if     decode_in_vif;             
  virtual decode_wb_if     decode_wb_vif;             
  virtual decode_out_if    decode_out_vif;            

  uvm_active_passive_enum  is_active_decode_in        = UVM_ACTIVE;
  uvm_active_passive_enum  is_active_decode_wb        = UVM_ACTIVE;
  uvm_active_passive_enum  is_active_decode_out       = UVM_ACTIVE;

  bit                      checks_enable_decode_in;   
  bit                      checks_enable_decode_wb;   
  bit                      checks_enable_decode_out;  

  bit                      coverage_enable_decode_in; 
  bit                      coverage_enable_decode_wb; 
  bit                      coverage_enable_decode_out;

  // You can insert variables here by setting config_var in file decode_common.tpl

  // You can remove new by setting top_env_config_generate_methods_inside_class = no in file decode_common.tpl

  extern function new(string name = "");

  // You can insert code here by setting top_env_config_inc_inside_class in file decode_common.tpl

endclass : decode_top_config 


// You can remove new by setting top_env_config_generate_methods_after_class = no in file decode_common.tpl

function decode_top_config::new(string name = "");
  super.new(name);

  // You can insert code here by setting top_env_config_append_to_new in file decode_common.tpl

endfunction : new


// You can insert code here by setting top_env_config_inc_after_class in file decode_common.tpl

`endif // DECODE_TOP_CONFIG_SV

