// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Driver for execute_in
//=============================================================================

`ifndef EXECUTE_IN_DRIVER_SV
`define EXECUTE_IN_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file execute_in.tpl

class execute_in_driver extends uvm_driver #(execute_tx);

  `uvm_component_utils(execute_in_driver)

  virtual execute_in_if vif;

  execute_in_config     m_config;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive_transaction(execute_tx tr);

  // You can insert code here by setting driver_inc_inside_class in file execute_in.tpl

endclass : execute_in_driver 


function execute_in_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

function void execute_in_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name(), "build_phase is called", UVM_LOW);
  if (!uvm_config_db#(virtual execute_in_if)::get(this, "", "vif", vif)) begin
    `uvm_fatal(get_type_name(), "virtual interface must be set for execute_in_driver.vif")
  end
  if (m_config == null)
    `uvm_warning(get_type_name(), "execute_in_config not provided to driver")
  else if (m_config.vif == null && vif == null)
    `uvm_error(get_type_name(), "execute_in_config.vif is null")
endfunction : build_phase

task execute_in_driver::run_phase(uvm_phase phase);
  execute_tx req;
  super.run_phase(phase);
  `uvm_info(get_type_name(), "main_phase is called", UVM_LOW);
  forever begin
    seq_item_port.get_next_item(req);
    drive_transaction(req);
    seq_item_port.item_done();
  end
endtask : run_phase

task execute_in_driver::drive_transaction(execute_tx tr);
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot drive execute_in interface because `vif` is null")
    return;
  end
   `uvm_info(get_type_name(), "begin to drive execute_in", UVM_LOW);
   `uvm_info("DRV", $sformatf("driver sees clock=%0b", vif.clock), UVM_LOW)
    @(posedge vif.clock);
  vif.data1          <= tr.data1;
  vif.data2          <= tr.data2;
  vif.immediate_data <= tr.immediate_data;
  vif.pc_in          <= tr.pc_in;
  vif.control_in     <= tr.control_in;
  vif.valid <= 1'b1;
  `uvm_info(get_type_name(), $sformatf("Driving transaction: data1=%0h data2=%0h immediate=%0h pc=%0h", tr.data1, tr.data2, tr.immediate_data, tr.pc_in), UVM_LOW)
  @(posedge vif.clock);
    vif.valid <= 1'b0;
  `uvm_info(get_type_name(), "drive_transaction end", UVM_LOW)
endtask : drive_transaction

// You can insert code here by setting driver_inc_after_class in file execute_in.tpl

`endif // EXECUTE_IN_DRIVER_SV