// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_out_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Monitor for decode_out
//=============================================================================

`ifndef DECODE_OUT_MONITOR_SV
`define DECODE_OUT_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file decode_out.tpl

class decode_out_monitor extends uvm_monitor;

  `uvm_component_utils(decode_out_monitor)

  virtual decode_out_if vif;

  decode_out_config     m_config;

  uvm_analysis_port #(decode_out_tx) analysis_port;
  int unsigned sample_cnt;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_values(decode_out_tx tr);

  // You can insert code here by setting monitor_inc_inside_class in file decode_out.tpl

endclass : decode_out_monitor 


function decode_out_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
  sample_cnt = 0;
endfunction : new


function void decode_out_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual decode_out_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "virtual interface must be set for decode_out_monitor.vif")
  void'(uvm_config_db#(decode_out_config)::get(this, "", "config", m_config));
endfunction : build_phase


task decode_out_monitor::run_phase(uvm_phase phase);
  decode_out_tx tr;
  super.run_phase(phase);
  // wait for reset release
  if (vif.rst_n === 1'b0)
    @(posedge vif.rst_n);
  forever begin
    @(posedge vif.clk);
    // skip unstable cycles with X pc_out (avoids scoreboard X tag warning)
    if ($isunknown(vif.pc_out))
      continue;

    tr = decode_out_tx::type_id::create("tr");
    collect_values(tr);
    tr.pc_tag = tr.pc_out; // default tag uses pc_out
    analysis_port.write(tr);
    sample_cnt++;
    `uvm_info(get_type_name(), $sformatf("sampled decode_out cnt=%0d pc_out=0x%0h", sample_cnt, tr.pc_out), UVM_MEDIUM)
  end
endtask : run_phase


task decode_out_monitor::collect_values(decode_out_tx tr);
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot sample decode_out interface because `vif` is null")
    return;
  end

  tr.reg_rd_id          = vif.reg_rd_id;
  tr.read_data1         = vif.read_data1;
  tr.read_data2         = vif.read_data2;
  tr.immediate_data     = vif.immediate_data;
  tr.pc_out             = vif.pc_out;
  tr.instruction_illegal= vif.instruction_illegal;
  tr.control_signals    = vif.control_signals;
endtask : collect_values


// You can insert code here by setting monitor_inc_after_class in file decode_out.tpl

`endif // DECODE_OUT_MONITOR_SV

