// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Coverage for agent forward
//=============================================================================

`ifndef FORWARD_COVERAGE_SV
`define FORWARD_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file forward.tpl

class forward_coverage extends uvm_subscriber #(forward_tx);

  `uvm_component_utils(forward_coverage)

  forward_config m_config;    
  bit            m_is_covered;
  forward_tx     m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file forward.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file forward.tpl

  covergroup m_cov;
    option.per_instance = 1;
    // You may insert additional coverpoints here ...

    cp_wb_forward_data: coverpoint m_item.wb_forward_data;
    //  Add bins here if required

    cp_mem_forward_data: coverpoint m_item.mem_forward_data;
    //  Add bins here if required

    cp_forward_rs1: coverpoint m_item.forward_rs1;
    //  Add bins here if required

    cp_forward_rs2: coverpoint m_item.forward_rs2;
    //  Add bins here if required

  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file forward.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input forward_tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file forward.tpl

endclass : forward_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file forward.tpl

function forward_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void forward_coverage::write(input forward_tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void forward_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(forward_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "forward config not found")
endfunction : build_phase


function void forward_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file forward.tpl

`endif // FORWARD_COVERAGE_SV

