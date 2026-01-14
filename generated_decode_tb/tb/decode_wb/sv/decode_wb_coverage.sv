// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Coverage for agent decode_wb
//=============================================================================

`ifndef DECODE_WB_COVERAGE_SV
`define DECODE_WB_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file decode_wb.tpl

class decode_wb_coverage extends uvm_subscriber #(decode_wb_tx);

  `uvm_component_utils(decode_wb_coverage)

  decode_wb_config m_config;    
  bit              m_is_covered;
  decode_wb_tx     m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file decode_wb.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file decode_wb.tpl

  covergroup m_cov;
    option.per_instance = 1;
    cp_write_en: coverpoint m_item.write_en;

    cp_write_id: coverpoint m_item.write_id {
      bins x0     = {0};
      bins others = {[1:31]};
    }

    cp_write_data: coverpoint m_item.write_data {
      bins zero    = {32'h0};
      bins all_one = {32'hFFFF_FFFF};
      bins others  = default;
    }

    x_en_id: cross cp_write_en, cp_write_id;

  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file decode_wb.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input decode_wb_tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file decode_wb.tpl

endclass : decode_wb_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file decode_wb.tpl

function decode_wb_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void decode_wb_coverage::write(input decode_wb_tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void decode_wb_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(decode_wb_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "decode_wb config not found")
endfunction : build_phase


function void decode_wb_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file decode_wb.tpl

`endif // DECODE_WB_COVERAGE_SV

