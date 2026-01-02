// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_agent.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Agent for decode_wb
//=============================================================================

`ifndef DECODE_WB_AGENT_SV
`define DECODE_WB_AGENT_SV

// You can insert code here by setting agent_inc_before_class in file decode_wb.tpl

class decode_wb_agent extends uvm_agent;

  `uvm_component_utils(decode_wb_agent)

  uvm_analysis_port #(decode_wb_tx) analysis_port;

  decode_wb_config       m_config;
  decode_wb_sequencer_t  m_sequencer;
  decode_wb_driver       m_driver;
  decode_wb_monitor      m_monitor;

  local int m_is_active = -1;

  extern function new(string name, uvm_component parent);

  // You can remove build/connect_phase and get_is_active by setting agent_generate_methods_inside_class = no in file decode_wb.tpl

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function uvm_active_passive_enum get_is_active();

  // You can insert code here by setting agent_inc_inside_class in file decode_wb.tpl

endclass : decode_wb_agent 


function  decode_wb_agent::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


// You can remove build/connect_phase and get_is_active by setting agent_generate_methods_after_class = no in file decode_wb.tpl

function void decode_wb_agent::build_phase(uvm_phase phase);

  // You can insert code here by setting agent_prepend_to_build_phase in file decode_wb.tpl

  if (!uvm_config_db #(decode_wb_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "decode_wb config not found")

  m_monitor     = decode_wb_monitor    ::type_id::create("m_monitor", this);

  if (get_is_active() == UVM_ACTIVE)
  begin
    m_driver    = decode_wb_driver     ::type_id::create("m_driver", this);
    m_sequencer = decode_wb_sequencer_t::type_id::create("m_sequencer", this);
  end

  // You can insert code here by setting agent_append_to_build_phase in file decode_wb.tpl

endfunction : build_phase


function void decode_wb_agent::connect_phase(uvm_phase phase);
  if (m_config.vif == null)
    `uvm_warning(get_type_name(), "decode_wb virtual interface is not set!")

  m_monitor.vif      = m_config.vif;
  m_monitor.m_config = m_config;
  m_monitor.analysis_port.connect(analysis_port);

  if (get_is_active() == UVM_ACTIVE)
  begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    m_driver.vif      = m_config.vif;
    m_driver.m_config = m_config;
  end

  // You can insert code here by setting agent_append_to_connect_phase in file decode_wb.tpl

endfunction : connect_phase


function uvm_active_passive_enum decode_wb_agent::get_is_active();
  if (m_is_active == -1)
  begin
    if (uvm_config_db#(uvm_bitstream_t)::get(this, "", "is_active", m_is_active))
    begin
      if (m_is_active != m_config.is_active)
        `uvm_warning(get_type_name(), "is_active field in config_db conflicts with config object")
    end
    else 
      m_is_active = m_config.is_active;
  end
  return uvm_active_passive_enum'(m_is_active);
endfunction : get_is_active


// You can insert code here by setting agent_inc_after_class in file decode_wb.tpl

`endif // DECODE_WB_AGENT_SV

