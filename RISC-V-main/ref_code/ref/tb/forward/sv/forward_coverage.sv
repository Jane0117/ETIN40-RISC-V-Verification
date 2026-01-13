// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
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
    option.per_instance = 1; // 意味着每个实例都有独立的覆盖率报告
    // You may insert additional coverpoints here ...

    // 数据通道覆盖（可按需细分）--通常数据值覆盖意义不大
    // cp_wb_forward_data:  coverpoint m_item.wb_forward_data;
    // cp_mem_forward_data: coverpoint m_item.mem_forward_data;

    // selector 覆盖
    cp_forward_rs1: coverpoint m_item.forward_rs1;
    cp_forward_rs2: coverpoint m_item.forward_rs2;

    // 9 条路径（hazard 模式）覆盖
    cp_path_tag: coverpoint m_item.path_tag {
      bins none_none = {forward_tx::PATH_NONE_NONE};
      bins mem_none  = {forward_tx::PATH_MEM_NONE};
      bins ex_none   = {forward_tx::PATH_EX_NONE};
      bins none_mem  = {forward_tx::PATH_NONE_MEM};
      bins mem_mem   = {forward_tx::PATH_MEM_MEM};
      bins ex_mem    = {forward_tx::PATH_EX_MEM};
      bins none_ex   = {forward_tx::PATH_NONE_EX};
      bins mem_ex    = {forward_tx::PATH_MEM_EX};
      bins ex_ex     = {forward_tx::PATH_EX_EX};
    }

    // hazard cross：所有 rs1/rs2 组合（等价于 9 条 path）
    cross_rs1_rs2: cross cp_forward_rs1, cp_forward_rs2;

    // 简单 hazard bins：只要 rs1/rs2 有前递即命中
    cp_hazard_rs1: coverpoint m_item.forward_rs1 {
      bins from_ex  = {FORWARD_FROM_EX};
      bins from_mem = {FORWARD_FROM_MEM};
    }
    cp_hazard_rs2: coverpoint m_item.forward_rs2 {
      bins from_ex  = {FORWARD_FROM_EX};
      bins from_mem = {FORWARD_FROM_MEM};
    }

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

