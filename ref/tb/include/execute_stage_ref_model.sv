`include "uvm_macros.svh"
import uvm_pkg::*;
import execute_out_pkg::*;
import common::*;

class execute_stage_ref_model extends uvm_component;
  `uvm_component_utils(execute_stage_ref_model)

  uvm_get_peek_port    #(execute_out_tx) port;
  uvm_analysis_port  #(execute_out_tx) ref_ap;  // 用来把参考值送 scoreboard

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase); // 或 main_phase
endclass

function execute_stage_ref_model::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void execute_stage_ref_model::build_phase(uvm_phase phase);
  super.build_phase(phase);
  port = new("port", this);
  ref_ap = new("ref_ap", this);
endfunction

task execute_stage_ref_model::main_phase(uvm_phase phase);
  execute_out_tx tr;
  execute_out_tx ref_tr;
  super.main_phase(phase);
  forever begin
    port.get(tr);
    ref_tr = new("ref_tr");
    ref_tr.copy(tr); // 或实现 custom copy/compute
    // 在这里根据 control_out 等字段执行参考计算
    // e.g. ref_tr.alu_data = <ALU calc>;
    // ref_ap.write(ref_tr);
  end
endtask
