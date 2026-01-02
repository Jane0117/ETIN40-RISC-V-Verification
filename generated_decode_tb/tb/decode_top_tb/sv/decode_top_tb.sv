// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_tb.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Testbench
//=============================================================================

module decode_top_tb;

  timeunit      1ns;
  timeprecision 1ps;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  import decode_top_test_pkg::*;
  import decode_top_pkg::decode_top_config;

  // Configuration object for top-level environment
  decode_top_config top_env_config;

  // Test harness
  decode_top_th th();

  // You can insert code here by setting tb_inc_inside_module in file decode_common.tpl

  // You can remove the initial block below by setting tb_generate_run_test = no in file decode_common.tpl

  initial
  begin
    // You can insert code here by setting tb_prepend_to_initial in file decode_common.tpl

    // Create and populate top-level configuration object
    top_env_config = new("top_env_config");
    if ( !top_env_config.randomize() )
      `uvm_error("decode_top_tb", "Failed to randomize top-level configuration object" )

    top_env_config.decode_in_vif              = th.decode_in_if_0; 
    top_env_config.is_active_decode_in        = UVM_ACTIVE;        
    top_env_config.checks_enable_decode_in    = 1;                 
    top_env_config.coverage_enable_decode_in  = 1;                 

    top_env_config.decode_wb_vif              = th.decode_wb_if_0; 
    top_env_config.is_active_decode_wb        = UVM_ACTIVE;        
    top_env_config.checks_enable_decode_wb    = 1;                 
    top_env_config.coverage_enable_decode_wb  = 1;                 

    top_env_config.decode_out_vif             = th.decode_out_if_0;
    top_env_config.is_active_decode_out       = UVM_PASSIVE;       
    top_env_config.checks_enable_decode_out   = 1;                 
    top_env_config.coverage_enable_decode_out = 1;                 


    uvm_config_db #(decode_top_config)::set(null, "uvm_test_top", "config", top_env_config);
    uvm_config_db #(decode_top_config)::set(null, "uvm_test_top.m_env", "config", top_env_config);

    // You can insert code here by setting tb_inc_before_run_test in file decode_common.tpl

    run_test();
  end

endmodule

