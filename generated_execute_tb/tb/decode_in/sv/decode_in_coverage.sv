// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: decode_in_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Coverage for agent decode_in
//=============================================================================

`ifndef DECODE_IN_COVERAGE_SV
`define DECODE_IN_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file decode_in.tpl

class decode_in_coverage extends uvm_subscriber #(decode_tx);

  `uvm_component_utils(decode_in_coverage)

  decode_in_config m_config;    
  bit              m_is_covered;
  decode_tx        m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file decode_in.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file decode_in.tpl

  covergroup m_cov;
    option.per_instance = 1;
    // You may insert additional coverpoints here ...

    cp_data1: coverpoint m_item.data1;
    //  Add bins here if required

    cp_data2: coverpoint m_item.data2;
    //  Add bins here if required

    cp_immediate_data: coverpoint m_item.immediate_data;
    //  Add bins here if required

    cp_pc_in: coverpoint m_item.pc_in;
    //  Add bins here if required

    cp_control_in: coverpoint m_item.control_in;
    //  Add bins here if required

  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file decode_in.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input decode_tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file decode_in.tpl

endclass : decode_in_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file decode_in.tpl

function decode_in_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void decode_in_coverage::write(input decode_tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void decode_in_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(decode_in_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "decode_in config not found")
endfunction : build_phase


function void decode_in_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file decode_in.tpl

`endif // DECODE_IN_COVERAGE_SV

