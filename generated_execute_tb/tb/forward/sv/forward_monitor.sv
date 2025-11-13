// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Monitor for forward
//=============================================================================

`ifndef FORWARD_MONITOR_SV
`define FORWARD_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file forward.tpl

class forward_monitor extends uvm_monitor;

  `uvm_component_utils(forward_monitor)

  virtual forward_if vif;

  forward_config     m_config;

  uvm_analysis_port #(forward_tx) analysis_port;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
  extern task collect_values(forward_tx tr);

  // You can insert code here by setting monitor_inc_inside_class in file forward.tpl

endclass : forward_monitor 


function forward_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new

function void forward_monitor::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "build_phase start", UVM_LOW)
  super.build_phase(phase);
  if (m_config == null)
    `uvm_warning(get_type_name(), "forward_config not provided to monitor")
  else if ((m_config != null) && (m_config.vif == null) && (vif == null))
    `uvm_error(get_type_name(), "forward_config.vif is null")
  `uvm_info(get_type_name(), "build_phase end", UVM_LOW)
endfunction : build_phase


task forward_monitor::main_phase(uvm_phase phase);
  forward_tx tr;
  `uvm_info(get_type_name(), "main_phase start", UVM_LOW)
  super.main_phase(phase);
  forever begin
    tr = forward_tx::type_id::create("tr");
    collect_values(tr);
    analysis_port.write(tr);
    #1;
  end
  `uvm_info(get_type_name(), "main_phase end", UVM_LOW)
endtask : main_phase


task forward_monitor::collect_values(forward_tx tr);
  `uvm_info(get_type_name(), "collect_values start", UVM_LOW)
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot sample forward interface because `vif` is null")
    return;
  end
  tr.wb_forward_data  = vif.wb_forward_data;
  tr.mem_forward_data = vif.mem_forward_data;
  tr.forward_rs1      = vif.forward_rs1;
  tr.forward_rs2      = vif.forward_rs2;
  `uvm_info(get_type_name(), $sformatf("Monitor captured forward: wb=%0h mem=%0h rs1=%0h rs2=%0h",
                                      tr.wb_forward_data, tr.mem_forward_data,
                                      tr.forward_rs1, tr.forward_rs2), UVM_LOW)
  `uvm_info(get_type_name(), "collect_values end", UVM_LOW)
endtask : collect_values


// You can insert code here by setting monitor_inc_after_class in file forward.tpl

`endif // FORWARD_MONITOR_SV

