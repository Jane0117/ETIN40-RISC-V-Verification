`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
import joint_top_pkg::*;
import decode_in_pkg::*;
import decode_wb_pkg::*;
import decode_out_pkg::*;
import execute_out_pkg::*;

module joint_top_tb;
  // bring in testbench top with DUT/if
  joint_top_th th();

  initial begin
    // create and set agent configs with vifs (declarations first)
    decode_in_config   din_cfg;
    decode_wb_config   dwb_cfg;
    decode_out_config  dout_cfg;
    execute_out_config eout_cfg;

    din_cfg  = new("din_cfg");   din_cfg.vif   = th.decode_in_vif;   din_cfg.is_active   = UVM_ACTIVE;  din_cfg.coverage_enable = 1'b0; din_cfg.checks_enable = 1'b1;
    dwb_cfg  = new("dwb_cfg");   dwb_cfg.vif   = th.decode_wb_vif;   dwb_cfg.is_active   = UVM_ACTIVE;  dwb_cfg.coverage_enable = 1'b0; dwb_cfg.checks_enable = 1'b1;
    dout_cfg = new("dout_cfg");  dout_cfg.vif  = th.decode_out_vif;  dout_cfg.is_active  = UVM_PASSIVE; dout_cfg.coverage_enable = 1'b0; dout_cfg.checks_enable = 1'b1;
    eout_cfg = new("eout_cfg");  eout_cfg.vif  = th.execute_out_vif; eout_cfg.is_active  = UVM_PASSIVE; eout_cfg.coverage_enable = 1'b0; eout_cfg.checks_enable = 1'b1;

    uvm_config_db#(decode_in_config)  ::set(null, "*m_decode_in_agent*",   "config", din_cfg);
    uvm_config_db#(decode_wb_config)  ::set(null, "*m_decode_wb_agent*",   "config", dwb_cfg);
    uvm_config_db#(decode_out_config) ::set(null, "*m_decode_out_agent*",  "config", dout_cfg);
    uvm_config_db#(execute_out_config)::set(null, "*m_execute_out_agent*", "config", eout_cfg);

    // bind virtual interfaces
    uvm_config_db#(virtual decode_in_if)  ::set(null, "*m_decode_in_agent*driver*", "vif", th.decode_in_vif);
    uvm_config_db#(virtual decode_in_if)  ::set(null, "*m_decode_in_agent*monitor*", "vif", th.decode_in_vif);
    uvm_config_db#(virtual decode_wb_if)  ::set(null, "*m_decode_wb_agent*driver*", "vif", th.decode_wb_vif);
    uvm_config_db#(virtual decode_wb_if)  ::set(null, "*m_decode_wb_agent*monitor*", "vif", th.decode_wb_vif);
    uvm_config_db#(virtual decode_out_if) ::set(null, "*m_decode_out_agent*monitor*", "vif", th.decode_out_vif);
    uvm_config_db#(virtual execute_out_if)::set(null, "*m_execute_out_agent*monitor*", "vif", th.execute_out_vif);

    // optional: reduce verbosity
    // uvm_top.set_report_verbosity_level_hier(UVM_MEDIUM);
    run_test("joint_top_test");
  end
endmodule
