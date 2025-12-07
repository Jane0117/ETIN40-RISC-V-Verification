`include "uvm_macros.svh"
import uvm_pkg::*;

class forward_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(forward_scoreboard)

  `uvm_analysis_imp_decl(_exp)
  `uvm_analysis_imp_decl(_act)

  uvm_analysis_imp_exp #(forward_tx, forward_scoreboard) exp_imp;
  uvm_analysis_imp_act #(forward_tx, forward_scoreboard) act_imp;

  forward_tx exp_queue[$];

  extern function new(string name, uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void write_exp(forward_tx t);
  extern function void write_act(forward_tx t);
endclass : forward_scoreboard
function forward_scoreboard::new(string name, uvm_component parent = null);
  super.new(name, parent);
endfunction

function void forward_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  exp_imp = new("exp_imp", this);
  act_imp = new("act_imp", this);
endfunction

function void forward_scoreboard::write_exp(forward_tx t);
  forward_tx clone;
  clone = forward_tx::type_id::create("exp_clone");
  clone.copy(t);
  exp_queue.push_back(clone);
endfunction

function void forward_scoreboard::write_act(forward_tx t);
  forward_tx clone;
  int match_idx;
  clone = forward_tx::type_id::create("act_clone");
  clone.copy(t);
  match_idx = -1;
  // 在 exp_queue 中寻找匹配项（按 selector/数据/path）
  foreach (exp_queue[i]) begin
    if (clone.forward_rs1 == exp_queue[i].forward_rs1 &&
        clone.forward_rs2 == exp_queue[i].forward_rs2 &&
        clone.wb_forward_data == exp_queue[i].wb_forward_data &&
        clone.mem_forward_data == exp_queue[i].mem_forward_data &&
        clone.path_tag == exp_queue[i].path_tag) begin
      match_idx = i;
      break;
    end
  end

  if (match_idx != -1) begin
    forward_tx exp = exp_queue[match_idx];
    exp_queue.delete(match_idx);
    `uvm_info(get_type_name(),
              $sformatf("forward comparison passed (match_idx=%0d qsize_after=%0d)\n  EXP: rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path=%0d\n  ACT: rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path=%0d",
                        match_idx, exp_queue.size(),
                        exp.forward_rs1, exp.forward_rs2,
                        exp.wb_forward_data, exp.mem_forward_data, exp.path_tag,
                        clone.forward_rs1, clone.forward_rs2,
                        clone.wb_forward_data, clone.mem_forward_data, clone.path_tag),
              UVM_LOW)
  end else begin
    `uvm_error(get_type_name(), "forward comparison FAILED")
    if (exp_queue.size() > 0) begin
      forward_tx exp = exp_queue[0];
      `uvm_info(get_type_name(),
                $sformatf("Expect(front): rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path=%0d",
                          exp.forward_rs1, exp.forward_rs2,
                          exp.wb_forward_data, exp.mem_forward_data, exp.path_tag),
                UVM_LOW)
    end
    `uvm_info(get_type_name(),
              $sformatf("Actual: rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path=%0d",
                        clone.forward_rs1, clone.forward_rs2,
                        clone.wb_forward_data, clone.mem_forward_data, clone.path_tag),
              UVM_LOW)
  end
endfunction
