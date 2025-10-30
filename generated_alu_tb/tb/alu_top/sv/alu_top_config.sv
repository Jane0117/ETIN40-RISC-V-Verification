// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_top_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Configuration for alu_top
//=============================================================================

`ifndef ALU_TOP_CONFIG_SV
`define ALU_TOP_CONFIG_SV

// You can insert code here by setting top_env_config_inc_before_class in file .\\common.tpl

class alu_top_config extends uvm_object;

  // Do not register config class with the factory

  virtual alu_if           alu_vif;            

  uvm_active_passive_enum  is_active_alu       = UVM_ACTIVE;
  bit                      checks_enable_alu;  
  bit                      coverage_enable_alu;

  // You can insert variables here by setting config_var in file .\\common.tpl

  // You can remove new by setting top_env_config_generate_methods_inside_class = no in file .\\common.tpl

  extern function new(string name = "");

  // You can insert code here by setting top_env_config_inc_inside_class in file .\\common.tpl

endclass : alu_top_config 


// You can remove new by setting top_env_config_generate_methods_after_class = no in file .\\common.tpl

function alu_top_config::new(string name = "");
  super.new(name);

  // You can insert code here by setting top_env_config_append_to_new in file .\\common.tpl

endfunction : new


// You can insert code here by setting top_env_config_inc_after_class in file .\\common.tpl

`endif // ALU_TOP_CONFIG_SV

