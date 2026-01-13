// cpu_scoreboard.sv
class cpu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(cpu_scoreboard)

  uvm_tlm_analysis_fifo #(wb_tx) exp_wb_fifo;
  uvm_tlm_analysis_fifo #(wb_tx) act_wb_fifo;
  uvm_tlm_analysis_fifo #(store_tx) exp_store_fifo;
  uvm_tlm_analysis_fifo #(store_tx) act_store_fifo;
  uvm_tlm_analysis_fifo #(branch_tx) exp_branch_fifo;
  uvm_tlm_analysis_fifo #(branch_tx) act_branch_fifo;

  wb_tx exp_wb_q[$]; wb_tx act_wb_q[$];
  store_tx exp_store_q[$]; store_tx act_store_q[$];
  branch_tx exp_branch_q[$]; branch_tx act_branch_q[$];

  int wb_match_count; int wb_mismatch_count;
  int store_match_count; int store_mismatch_count;
  int branch_match_count; int branch_mismatch_count;

  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_wb_fifo = new("exp_wb_fifo", this);
    act_wb_fifo = new("act_wb_fifo", this);
    exp_store_fifo = new("exp_store_fifo", this);
    act_store_fifo = new("act_store_fifo", this);
    exp_branch_fifo = new("exp_branch_fifo", this);
    act_branch_fifo = new("act_branch_fifo", this);
  endfunction

  task compare_wb(); wb_tx exp; wb_tx act; forever begin wait(exp_wb_q.size()>0 && act_wb_q.size()>0); exp=exp_wb_q.pop_front(); act=act_wb_q.pop_front(); if (exp.rd==act.rd && exp.data==act.data) wb_match_count++; else begin wb_mismatch_count++; `uvm_error(get_type_name(), $sformatf("WB mismatch exp rd=%0d data=0x%08h pc=0x%08h act rd=%0d data=0x%08h pc=0x%08h", exp.rd, exp.data, exp.pc, act.rd, act.data, act.pc)) end end endtask
  task compare_store(); store_tx exp; store_tx act; forever begin wait(exp_store_q.size()>0 && act_store_q.size()>0); exp=exp_store_q.pop_front(); act=act_store_q.pop_front(); if ((exp.addr[9:0]==act.addr[9:0]) && (exp.data==act.data) && (exp.mem_size==act.mem_size)) store_match_count++; else begin store_mismatch_count++; `uvm_error(get_type_name(), $sformatf("STORE mismatch exp addr=0x%08h data=0x%08h size=%0d act addr=0x%08h data=0x%08h size=%0d", exp.addr, exp.data, exp.mem_size, act.addr, act.data, act.mem_size)) end end endtask
  task compare_branch(); branch_tx exp; branch_tx act; forever begin wait(exp_branch_q.size()>0 && act_branch_q.size()>0); exp=exp_branch_q.pop_front(); act=act_branch_q.pop_front(); if (exp.pc==act.pc && exp.taken==act.taken) branch_match_count++; else begin branch_mismatch_count++; `uvm_error(get_type_name(), $sformatf("BRANCH mismatch exp pc=0x%08h taken=%0b act pc=0x%08h taken=%0b", exp.pc, exp.taken, act.pc, act.taken)) end end endtask

  task run_phase(uvm_phase phase);
    fork
      forever begin wb_tx t; exp_wb_fifo.get(t); exp_wb_q.push_back(t); end
      forever begin wb_tx t; act_wb_fifo.get(t); act_wb_q.push_back(t); end
      forever begin store_tx t; exp_store_fifo.get(t); exp_store_q.push_back(t); end
      forever begin store_tx t; act_store_fifo.get(t); act_store_q.push_back(t); end
      forever begin branch_tx t; exp_branch_fifo.get(t); exp_branch_q.push_back(t); end
      forever begin branch_tx t; act_branch_fifo.get(t); act_branch_q.push_back(t); end
      compare_wb(); compare_store(); compare_branch();
    join_none
  endtask

  function bit is_ok();
    return (wb_mismatch_count==0)&&(store_mismatch_count==0)&&(branch_mismatch_count==0)&&
           (exp_wb_q.size()==0)&&(act_wb_q.size()==0)&&
           (exp_store_q.size()==0)&&(act_store_q.size()==0)&&
           (exp_branch_q.size()==0)&&(act_branch_q.size()==0);
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("WB matches=%0d mismatches=%0d", wb_match_count, wb_mismatch_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("STORE matches=%0d mismatches=%0d", store_match_count, store_mismatch_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("BRANCH matches=%0d mismatches=%0d", branch_match_count, branch_mismatch_count), UVM_LOW)
    if (exp_wb_q.size() || act_wb_q.size() || exp_store_q.size() || act_store_q.size() || exp_branch_q.size() || act_branch_q.size())
      `uvm_error(get_type_name(), "Scoreboard queues not empty at end of test")
  endfunction
endclass
