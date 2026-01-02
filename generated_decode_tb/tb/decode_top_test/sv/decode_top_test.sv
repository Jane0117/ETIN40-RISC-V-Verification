// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_test.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Test class for decode_top (included in package decode_top_test_pkg)
//=============================================================================

`ifndef DECODE_TOP_TEST_SV
`define DECODE_TOP_TEST_SV

// You can insert code here by setting test_inc_before_class in file decode_common.tpl

class decode_top_test extends uvm_test;

  `uvm_component_utils(decode_top_test)

  decode_top_env m_env;

  extern function new(string name, uvm_component parent);

  // You can remove build_phase method by setting test_generate_methods_inside_class = no in file decode_common.tpl

  extern function void build_phase(uvm_phase phase);

  // You can insert code here by setting test_inc_inside_class in file decode_common.tpl

endclass : decode_top_test


function decode_top_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can remove build_phase method by setting test_generate_methods_after_class = no in file decode_common.tpl

function void decode_top_test::build_phase(uvm_phase phase);

  // You can insert code here by setting test_prepend_to_build_phase in file decode_common.tpl

  // You could modify any test-specific configuration object variables here



  m_env = decode_top_env::type_id::create("m_env", this);

  // You can insert code here by setting test_append_to_build_phase in file decode_common.tpl

endfunction : build_phase


// You can insert code here by setting test_inc_after_class in file decode_common.tpl

`endif // DECODE_TOP_TEST_SV

