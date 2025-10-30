// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_top_test.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Test class for alu_top (included in package alu_top_test_pkg)
//=============================================================================

`ifndef ALU_TOP_TEST_SV
`define ALU_TOP_TEST_SV

// You can insert code here by setting test_inc_before_class in file .\\common.tpl

class alu_top_test extends uvm_test;

  `uvm_component_utils(alu_top_test)

  alu_top_env m_env;

  extern function new(string name, uvm_component parent);

  // You can remove build_phase method by setting test_generate_methods_inside_class = no in file .\\common.tpl

  extern function void build_phase(uvm_phase phase);

  // You can insert code here by setting test_inc_inside_class in file .\\common.tpl

endclass : alu_top_test


function alu_top_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can remove build_phase method by setting test_generate_methods_after_class = no in file .\\common.tpl

function void alu_top_test::build_phase(uvm_phase phase);

  // You can insert code here by setting test_prepend_to_build_phase in file .\\common.tpl

  // You could modify any test-specific configuration object variables here



  m_env = alu_top_env::type_id::create("m_env", this);

  // You can insert code here by setting test_append_to_build_phase in file .\\common.tpl

endfunction : build_phase


// You can insert code here by setting test_inc_after_class in file .\\common.tpl

`endif // ALU_TOP_TEST_SV

