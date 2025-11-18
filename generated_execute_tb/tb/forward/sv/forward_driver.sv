// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Driver for forward
//=============================================================================

`ifndef FORWARD_DRIVER_SV
`define FORWARD_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file forward.tpl

class forward_driver extends uvm_driver #(forward_tx);

  `uvm_component_utils(forward_driver)

  virtual forward_if vif;

  forward_config     m_config;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive_transaction(forward_tx tr);

  // You can insert code here by setting driver_inc_inside_class in file forward.tpl

endclass : forward_driver 


function forward_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void forward_driver::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "build_phase start", UVM_LOW)
  super.build_phase(phase);
  if (!uvm_config_db#(virtual forward_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "virtual interface must be set for forward_driver.vif")
  if (m_config == null)
    `uvm_warning(get_type_name(), "forward_config not provided to driver")
  else if ((m_config != null) && (m_config.vif == null) && (vif == null))
    `uvm_error(get_type_name(), "forward_config.vif is null")
  `uvm_info(get_type_name(), "build_phase end", UVM_LOW)
endfunction : build_phase


task forward_driver::run_phase(uvm_phase phase);
  forward_tx req;
  `uvm_info(get_type_name(), "main_phase start", UVM_LOW)
  super.main_phase(phase);
  forever begin
    seq_item_port.get_next_item(req);
    drive_transaction(req);
    seq_item_port.item_done();
  end
  `uvm_info(get_type_name(), "main_phase end", UVM_LOW)
endtask : run_phase


task forward_driver::drive_transaction(forward_tx tr);
  `uvm_info(get_type_name(), "drive_transaction start", UVM_LOW)
  `uvm_info("DRV", $sformatf("driver sees clock=%0b", vif.clock), UVM_LOW)

  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot drive forward interface because `vif` is null")
    return;
  end
  vif.wb_forward_data <= tr.wb_forward_data;
  vif.mem_forward_data <= tr.mem_forward_data;
  vif.forward_rs1 <= tr.forward_rs1;
  vif.forward_rs2 <= tr.forward_rs2;
  `uvm_info(get_type_name(), $sformatf("Driving forward transaction: wb=%0h mem=%0h rs1=%0h rs2=%0h",
                                      tr.wb_forward_data, tr.mem_forward_data,
                                      tr.forward_rs1, tr.forward_rs2), UVM_LOW)
  @(posedge vif.clock);
  `uvm_info(get_type_name(), "drive_transaction end", UVM_LOW)
endtask : drive_transaction


// You can insert code here by setting driver_inc_after_class in file forward.tpl

`endif // FORWARD_DRIVER_SV

