// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Configuration for agent alu
//=============================================================================

`ifndef ALU_CONFIG_SV
`define ALU_CONFIG_SV

// You can insert code here by setting agent_config_inc_before_class in file .\\alu.tpl

class alu_config extends uvm_object;

  // Do not register config class with the factory

  virtual alu_if           vif;
                  
  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;       
  bit                      checks_enable;         

  // You can insert variables here by setting config_var in file .\\alu.tpl

  // You can remove new by setting agent_config_generate_methods_inside_class = no in file .\\alu.tpl

  extern function new(string name = "");

  // You can insert code here by setting agent_config_inc_inside_class in file .\\alu.tpl

endclass : alu_config 


// You can remove new by setting agent_config_generate_methods_after_class = no in file .\\alu.tpl

function alu_config::new(string name = "");
  super.new(name);
endfunction : new


// You can insert code here by setting agent_config_inc_after_class in file .\\alu.tpl

`endif // ALU_CONFIG_SV

