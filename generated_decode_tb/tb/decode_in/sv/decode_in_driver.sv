// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_in_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Driver for decode_in
//=============================================================================

`ifndef DECODE_IN_DRIVER_SV
`define DECODE_IN_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file decode_in.tpl

class decode_in_driver extends uvm_driver #(decode_in_tx);

  `uvm_component_utils(decode_in_driver)

  virtual decode_in_if vif;

  decode_in_config     m_config;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive_transaction(decode_in_tx tr);

  // You can insert code here by setting driver_inc_inside_class in file decode_in.tpl

endclass : decode_in_driver 


function decode_in_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void decode_in_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual decode_in_if)::get(this, "", "vif", vif)) begin
    `uvm_fatal(get_type_name(), "virtual interface must be set for decode_in_driver.vif")
  end
  void'(uvm_config_db#(decode_in_config)::get(this, "", "config", m_config));
  if (m_config == null)
    `uvm_warning(get_type_name(), "decode_in_config not provided to driver")
  else if (m_config.vif == null && vif == null)
    `uvm_error(get_type_name(), "decode_in_config.vif is null")
endfunction : build_phase


task decode_in_driver::run_phase(uvm_phase phase);
  decode_in_tx req;
  super.run_phase(phase);
  // wait for reset deassert
  if (vif.reset_n === 1'b0) begin
    @(posedge vif.reset_n);
  end
  vif.valid <= 1'b0;
  forever begin
    seq_item_port.get_next_item(req);
    drive_transaction(req);
    seq_item_port.item_done();
  end
endtask : run_phase


task decode_in_driver::drive_transaction(decode_in_tx tr);
  if (vif == null && m_config != null)
    vif = m_config.vif;
  if (vif == null) begin
    `uvm_error(get_type_name(), "Cannot drive decode_in interface because `vif` is null")
    return;
  end
  @(posedge vif.clk);
  vif.valid       <= 1'b1;
  vif.instruction <= tr.instruction;
  vif.pc_in       <= tr.pc_in;
  @(posedge vif.clk);
  vif.valid       <= 1'b0;
endtask : drive_transaction


// You can insert code here by setting driver_inc_after_class in file decode_in.tpl

`endif // DECODE_IN_DRIVER_SV

