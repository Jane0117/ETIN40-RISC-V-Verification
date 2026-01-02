// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_out_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Coverage for agent decode_out
//=============================================================================

`ifndef DECODE_OUT_COVERAGE_SV
`define DECODE_OUT_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file decode_out.tpl

class decode_out_coverage extends uvm_subscriber #(decode_out_tx);

  `uvm_component_utils(decode_out_coverage)

  decode_out_config m_config;    
  bit               m_is_covered;
  decode_out_tx     m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file decode_out.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file decode_out.tpl

  covergroup m_cov;
    option.per_instance = 1;

    cp_encoding: coverpoint m_item.control_signals.encoding;
    cp_alu_op:  coverpoint m_item.control_signals.alu_op;
    cp_mem_size: coverpoint m_item.control_signals.mem_size;
    cp_mem_sign: coverpoint m_item.control_signals.mem_sign;
    cp_mem_read: coverpoint m_item.control_signals.mem_read;
    cp_mem_write: coverpoint m_item.control_signals.mem_write;
    cp_mem_to_reg: coverpoint m_item.control_signals.mem_to_reg;
    cp_reg_write: coverpoint m_item.control_signals.reg_write;
    cp_is_branch: coverpoint m_item.control_signals.is_branch;

    cp_reg_rd_id: coverpoint m_item.reg_rd_id {
      bins x0 = {0};
      bins others = {[1:31]};
    }

    cp_instruction_illegal: coverpoint m_item.instruction_illegal;

    illegal_x_encoding: cross cp_instruction_illegal, cp_encoding;
  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file decode_out.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input decode_out_tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file decode_out.tpl

endclass : decode_out_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file decode_out.tpl

function decode_out_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void decode_out_coverage::write(input decode_out_tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void decode_out_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(decode_out_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "decode_out config not found")
endfunction : build_phase


function void decode_out_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file decode_out.tpl

`endif // DECODE_OUT_COVERAGE_SV

