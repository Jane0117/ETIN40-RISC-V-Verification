// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Coverage for agent execute_out
//=============================================================================

`ifndef EXECUTE_OUT_COVERAGE_SV
`define EXECUTE_OUT_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file execute_out.tpl

class execute_out_coverage extends uvm_subscriber #(execute_out_tx);

  `uvm_component_utils(execute_out_coverage)

  execute_out_config m_config;    
  bit                m_is_covered;
  execute_out_tx     m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file execute_out.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file execute_out.tpl

  covergroup m_cov;
    option.per_instance = 1;
    // You may insert additional coverpoints here ...

    cp_control_out: coverpoint m_item.control_out;
    //  Add bins here if required

    cp_alu_data: coverpoint m_item.alu_data;
    //  Add bins here if required

    cp_memory_data: coverpoint m_item.memory_data;
    //  Add bins here if required

    cp_pc_src: coverpoint m_item.pc_src;
    //  Add bins here if required

    cp_jalr_target_offset: coverpoint m_item.jalr_target_offset;
    //  Add bins here if required

    cp_jalr_flag: coverpoint m_item.jalr_flag;
    //  Add bins here if required

    cp_pc_out: coverpoint m_item.pc_out;
    //  Add bins here if required

    cp_overflow: coverpoint m_item.overflow;
    //  Add bins here if required

  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file execute_out.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input execute_out_tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file execute_out.tpl

endclass : execute_out_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file execute_out.tpl

function execute_out_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void execute_out_coverage::write(input execute_out_tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void execute_out_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(execute_out_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "execute_out config not found")
endfunction : build_phase


function void execute_out_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file execute_out.tpl

`endif // EXECUTE_OUT_COVERAGE_SV

