// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_out_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Monitor for execute_out
//=============================================================================

`ifndef EXECUTE_OUT_MONITOR_SV
`define EXECUTE_OUT_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file execute_out.tpl

class execute_out_monitor extends uvm_monitor;

  `uvm_component_utils(execute_out_monitor)

  virtual execute_out_if vif;

  execute_out_config     m_config;

  uvm_analysis_port #(execute_out_tx) analysis_port;
  execute_out_tx pending_tr;
  bit pending_valid;
  int unsigned seq_gen;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_values(execute_out_tx tr);

  // You can insert code here by setting monitor_inc_inside_class in file execute_out.tpl

endclass : execute_out_monitor 


function execute_out_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


function void execute_out_monitor::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "build_phase start", UVM_LOW)
  super.build_phase(phase);
  if (!uvm_config_db#(virtual execute_out_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "virtual interface must be set for execute_out_monitor.vif")
  if (m_config == null)
    `uvm_warning(get_type_name(), "execute_out_config not provided to monitor")
  else if ((m_config != null) && (m_config.vif == null) && (vif == null))
    `uvm_error(get_type_name(), "execute_out_config.vif is null")
  `uvm_info(get_type_name(), "build_phase end", UVM_LOW)
endfunction : build_phase


task execute_out_monitor::run_phase(uvm_phase phase);
  execute_out_tx tr;
  `uvm_info(get_type_name(), "run_phase start", UVM_LOW)
  super.run_phase(phase);
  // wait for reset deassert
  if (vif.reset === 1'b0)
    @(posedge vif.reset);
  forever begin
    @(posedge vif.clock);
    if (pending_valid) begin
      analysis_port.write(pending_tr);
      `uvm_info(get_type_name(), $sformatf("MON exec_out pc=0x%0h ctrl=%0h alu=0x%0h mem=0x%0h pc_src=%0b jalr=%0b",
                pending_tr.pc_out, pending_tr.control_out, pending_tr.alu_data, pending_tr.memory_data,
                pending_tr.pc_src, pending_tr.jalr_flag), UVM_MEDIUM)
      pending_valid = 1'b0;
    end
    if (vif.valid) begin
      #1ps;
      tr = execute_out_tx::type_id::create("tr");
      collect_values(tr);
      // 使用 pc_out 作为 seq_id，与参考模型保持一致
      tr.seq_id = tr.pc_out;
      if ($isunknown(tr.pc_out)) continue;
      pending_tr = tr;
      pending_valid = 1'b1;
    end
  end
endtask : run_phase


task execute_out_monitor::collect_values(execute_out_tx tr);
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot sample execute_out interface because `vif` is null")
    return;
  end

  tr.control_out        = vif.control_out;
  tr.alu_data           = vif.alu_data;
  tr.memory_data        = vif.memory_data;
  tr.pc_src             = vif.pc_src;
  tr.jalr_target_offset = vif.jalr_target_offset;
  tr.jalr_flag          = vif.jalr_flag;
  tr.pc_out             = vif.pc_out;
  tr.overflow           = vif.overflow;
endtask : collect_values


// You can insert code here by setting monitor_inc_after_class in file execute_out.tpl

`endif // EXECUTE_OUT_MONITOR_SV

