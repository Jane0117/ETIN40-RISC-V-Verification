// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Monitor for decode_wb
//=============================================================================

`ifndef DECODE_WB_MONITOR_SV
`define DECODE_WB_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file decode_wb.tpl

class decode_wb_monitor extends uvm_monitor;

  `uvm_component_utils(decode_wb_monitor)

  virtual decode_wb_if vif;

  decode_wb_config     m_config;

  uvm_analysis_port #(decode_wb_tx) analysis_port;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_values(decode_wb_tx tr);

  // You can insert code here by setting monitor_inc_inside_class in file decode_wb.tpl

endclass : decode_wb_monitor 


function decode_wb_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


function void decode_wb_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual decode_wb_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "virtual interface must be set for decode_wb_monitor.vif")
  void'(uvm_config_db#(decode_wb_config)::get(this, "", "config", m_config));
endfunction : build_phase


task decode_wb_monitor::run_phase(uvm_phase phase);
  decode_wb_tx tr;
  super.run_phase(phase);
  forever begin
    @(posedge vif.clk);
    if (vif.reset_n === 1'b0) begin
      continue;
    end
    // protocol check: warn if write_en asserted to x0 (register file will ignore)
    if (m_config != null && m_config.checks_enable) begin
      if (vif.write_en && vif.write_id == 0)
        `uvm_warning(get_type_name(), "write_en asserted with write_id==0 (ignored by regfile)")
    end
    tr = decode_wb_tx::type_id::create("tr");
    collect_values(tr);
    analysis_port.write(tr);
  end
endtask : run_phase


task decode_wb_monitor::collect_values(decode_wb_tx tr);
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot sample decode_wb interface because `vif` is null")
    return;
  end

  tr.write_en   = vif.write_en;
  tr.write_id   = vif.write_id;
  tr.write_data = vif.write_data;
endtask : collect_values


// You can insert code here by setting monitor_inc_after_class in file decode_wb.tpl

`endif // DECODE_WB_MONITOR_SV

