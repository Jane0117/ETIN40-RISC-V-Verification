// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_top_tb.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Testbench
//=============================================================================

module alu_top_tb;

  timeunit      1ns;
  timeprecision 1ps;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  import alu_top_test_pkg::*;
  import alu_top_pkg::alu_top_config;

  // Configuration object for top-level environment
  alu_top_config top_env_config;

  // Test harness
  alu_top_th th();

  // You can insert code here by setting tb_inc_inside_module in file .\\common.tpl

  // You can remove the initial block below by setting tb_generate_run_test = no in file .\\common.tpl

  initial
  begin
    // You can insert code here by setting tb_prepend_to_initial in file .\\common.tpl

    // Create and populate top-level configuration object
    top_env_config = new("top_env_config");
    if ( !top_env_config.randomize() )
      `uvm_error("alu_top_tb", "Failed to randomize top-level configuration object" )

    top_env_config.alu_vif             = th.alu_if_0;
    top_env_config.is_active_alu       = UVM_ACTIVE; 
    top_env_config.checks_enable_alu   = 1;          
    top_env_config.coverage_enable_alu = 1;          


    uvm_config_db #(alu_top_config)::set(null, "uvm_test_top", "config", top_env_config);
    uvm_config_db #(alu_top_config)::set(null, "uvm_test_top.m_env", "config", top_env_config);

    // You can insert code here by setting tb_inc_before_run_test in file .\\common.tpl

    run_test();
  end

endmodule

