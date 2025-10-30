// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Coverage for agent alu
//=============================================================================

`ifndef ALU_COVERAGE_SV
`define ALU_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file .\\alu.tpl

class alu_coverage extends uvm_subscriber #(alu_seq_item);

  `uvm_component_utils(alu_coverage)

  alu_config   m_config;    
  bit          m_is_covered;
  alu_seq_item m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file .\\alu.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file .\\alu.tpl

  covergroup m_cov;
    option.per_instance = 1;
    // You may insert additional coverpoints here ...

    cp_control: coverpoint m_item.control;
    //  Add bins here if required

    cp_left_operand: coverpoint m_item.left_operand;
    //  Add bins here if required

    cp_right_operand: coverpoint m_item.right_operand;
    //  Add bins here if required

    cp_zero_flag: coverpoint m_item.zero_flag;
    //  Add bins here if required

    cp_result: coverpoint m_item.result;
    //  Add bins here if required

    cp_overflow: coverpoint m_item.overflow;
    //  Add bins here if required

  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file .\\alu.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input alu_seq_item t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file .\\alu.tpl

endclass : alu_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file .\\alu.tpl

function alu_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void alu_coverage::write(input alu_seq_item t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void alu_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(alu_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "alu config not found")
endfunction : build_phase


function void alu_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file .\\alu.tpl

`endif // ALU_COVERAGE_SV

