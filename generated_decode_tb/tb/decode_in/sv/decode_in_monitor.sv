// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_in_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Monitor for decode_in
//=============================================================================

`ifndef DECODE_IN_MONITOR_SV
`define DECODE_IN_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file decode_in.tpl

class decode_in_monitor extends uvm_monitor;

  `uvm_component_utils(decode_in_monitor)

  virtual decode_in_if vif;

  decode_in_config     m_config;

  uvm_analysis_port #(decode_in_tx) analysis_port;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_values(decode_in_tx tr);

  // You can insert code here by setting monitor_inc_inside_class in file decode_in.tpl

endclass : decode_in_monitor 


function decode_in_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


function void decode_in_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual decode_in_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "virtual interface must be set for decode_in_monitor.vif")
  void'(uvm_config_db#(decode_in_config)::get(this, "", "config", m_config));
endfunction : build_phase


task decode_in_monitor::run_phase(uvm_phase phase);
  decode_in_tx tr;
  super.run_phase(phase);
  forever begin
    @(posedge vif.clk);
    if (vif.reset_n === 1'b0 || !vif.valid || $isunknown(vif.pc_in)) begin
      continue;
    end
    tr = decode_in_tx::type_id::create("tr");
    collect_values(tr);
    tr.pc_tag = tr.pc_in; // use pc_in as tag
    analysis_port.write(tr);
  end
endtask : run_phase


task decode_in_monitor::collect_values(decode_in_tx tr);
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot sample decode_in interface because `vif` is null")
    return;
  end

  tr.instruction = vif.instruction;
  tr.pc_in       = vif.pc_in;
endtask : collect_values


// You can insert code here by setting monitor_inc_after_class in file decode_in.tpl

`endif // DECODE_IN_MONITOR_SV

