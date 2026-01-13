`include "uvm_macros.svh"
import uvm_pkg::*;

class forward_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(forward_scoreboard)
//生成了两个带后缀的 uvm_analysis_imp_* 类型。
//宏会为该 imp 自动实现一个 write()，内部转调宿主类的 write_act() / write_exp()。
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
  forward_tx exp_match;
  int match_idx;
  clone = forward_tx::type_id::create("act_clone");
  clone.copy(t);
  match_idx = -1;

  // FIFO 匹配：只比较队首，确保 exp/act 一一对应
  if (exp_queue.size() > 0) begin
    forward_tx exp = exp_queue[0];
    if (clone.forward_rs1 == exp.forward_rs1 &&
        clone.forward_rs2 == exp.forward_rs2 &&
        clone.wb_forward_data == exp.wb_forward_data &&
        clone.mem_forward_data == exp.mem_forward_data &&
        clone.path_tag == exp.path_tag) begin
      match_idx = 0;
      exp_match = exp;
      exp_queue.delete(0);
    end
  end

  if (match_idx != -1) begin
    `uvm_info(get_type_name(),
              $sformatf("forward comparison passed (FIFO match, qsize_after=%0d)\n  EXP: rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path=%0d\n  ACT: rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path=%0d",
                        exp_queue.size(),
                        exp_match.forward_rs1, exp_match.forward_rs2,
                        exp_match.wb_forward_data, exp_match.mem_forward_data, exp_match.path_tag,
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
