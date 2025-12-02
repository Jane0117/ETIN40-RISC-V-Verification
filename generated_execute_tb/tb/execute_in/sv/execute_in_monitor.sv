// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Monitor for execute_in
//=============================================================================

`ifndef EXECUTE_IN_MONITOR_SV
`define EXECUTE_IN_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file execute_in.tpl

class execute_in_monitor extends uvm_monitor;

  `uvm_component_utils(execute_in_monitor)

  virtual execute_in_if vif;
  execute_in_config     m_config;

  uvm_analysis_port #(execute_tx) analysis_port;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_values(execute_tx tr);

  // You can insert code here by setting monitor_inc_inside_class in file execute_in.tpl

endclass : execute_in_monitor 


function execute_in_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


function void execute_in_monitor::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "build_phase start", UVM_LOW)
  super.build_phase(phase);
  if (!uvm_config_db#(virtual execute_in_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "virtual interface must be set for execute_in_monitor.vif")
  if (m_config == null)
    `uvm_warning(get_type_name(), "execute_in_config not provided to monitor")
  else if ((m_config != null) && (m_config.vif == null) && (vif == null))
    `uvm_error(get_type_name(), "execute_in_config.vif is null")
  `uvm_info(get_type_name(), "build_phase end", UVM_LOW)
endfunction : build_phase

task execute_in_monitor::run_phase(uvm_phase phase);
  execute_tx tr;
  `uvm_info(get_type_name(), "main_phase start", UVM_LOW)
  super.run_phase(phase);
  forever begin
    tr = execute_tx::type_id::create("tr");
    collect_values(tr);
    analysis_port.write(tr);
    #1;
  end
  `uvm_info(get_type_name(), "main_phase end", UVM_LOW)
endtask : run_phase

task execute_in_monitor::collect_values(execute_tx tr);
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot sample execute_in interface because `vif` is null")
    return;
  end

  if (vif.valid == 1'b1) begin
  tr.data1          = vif.data1;
  tr.data2          = vif.data2;
  tr.immediate_data = vif.immediate_data;
  tr.pc_in          = vif.pc_in;
  tr.control_in     = vif.control_in;
  `uvm_info(get_type_name(), $sformatf("Monitor captured execute_in: data1=%0h data2=%0h pc=%0h", tr.data1, tr.data2, tr.pc_in), UVM_LOW)
  `uvm_info(get_type_name(), "collect_values end", UVM_LOW)
    end
endtask : collect_values


// You can insert code here by setting monitor_inc_after_class in file execute_in.tpl

`endif // EXECUTE_IN_MONITOR_SV

