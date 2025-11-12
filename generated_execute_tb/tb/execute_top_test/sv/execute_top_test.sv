// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_test.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Test class for execute_top (included in package execute_top_test_pkg)
//=============================================================================

`ifndef EXECUTE_TOP_TEST_SV
`define EXECUTE_TOP_TEST_SV

// You can insert code here by setting test_inc_before_class in file execute_common.tpl

class execute_top_test extends uvm_test;

  `uvm_component_utils(execute_top_test)

  execute_top_env m_env;

  extern function new(string name, uvm_component parent);

  // You can remove build_phase method by setting test_generate_methods_inside_class = no in file execute_common.tpl

  extern function void build_phase(uvm_phase phase);

  // You can insert code here by setting test_inc_inside_class in file execute_common.tpl

endclass : execute_top_test


function execute_top_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can remove build_phase method by setting test_generate_methods_after_class = no in file execute_common.tpl

function void execute_top_test::build_phase(uvm_phase phase);

  // You can insert code here by setting test_prepend_to_build_phase in file execute_common.tpl

  // You could modify any test-specific configuration object variables here



  m_env = execute_top_env::type_id::create("m_env", this);

  // You can insert code here by setting test_append_to_build_phase in file execute_common.tpl

endfunction : build_phase


// You can insert code here by setting test_inc_after_class in file execute_common.tpl

`endif // EXECUTE_TOP_TEST_SV

