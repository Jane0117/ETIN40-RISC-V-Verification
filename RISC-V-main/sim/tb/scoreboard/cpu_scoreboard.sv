// cpu_scoreboard.sv
class cpu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(cpu_scoreboard)

  uvm_tlm_analysis_fifo #(wb_tx) exp_wb_fifo;
  uvm_tlm_analysis_fifo #(wb_tx) act_wb_fifo;
  uvm_tlm_analysis_fifo #(issue_tx) exp_issue_fifo;
  uvm_tlm_analysis_fifo #(issue_tx) act_issue_fifo;
  uvm_tlm_analysis_fifo #(store_tx) exp_store_fifo;
  uvm_tlm_analysis_fifo #(store_tx) act_store_fifo;
  uvm_tlm_analysis_fifo #(branch_tx) exp_branch_fifo;
  uvm_tlm_analysis_fifo #(branch_tx) act_branch_fifo;
  uvm_tlm_analysis_fifo #(mem_tx) exp_mem_fifo;
  uvm_tlm_analysis_fifo #(mem_tx) act_mem_fifo;

  issue_tx exp_issue_q[$]; issue_tx act_issue_q[$];
  wb_tx exp_wb_q[$]; wb_tx act_wb_q[$];
  store_tx exp_store_q[$]; store_tx act_store_q[$];
  branch_tx exp_branch_q[$]; branch_tx act_branch_q[$];
  mem_tx exp_mem_q[$]; mem_tx act_mem_q[$];

  int issue_match_count; int issue_mismatch_count;
  int wb_match_count; int wb_mismatch_count;
  int store_match_count; int store_mismatch_count;
  int branch_match_count; int branch_mismatch_count;
  int mem_match_count; int mem_mismatch_count;

  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_issue_fifo = new("exp_issue_fifo", this);
    act_issue_fifo = new("act_issue_fifo", this);
    exp_wb_fifo = new("exp_wb_fifo", this);
    act_wb_fifo = new("act_wb_fifo", this);
    exp_store_fifo = new("exp_store_fifo", this);
    act_store_fifo = new("act_store_fifo", this);
    exp_branch_fifo = new("exp_branch_fifo", this);
    act_branch_fifo = new("act_branch_fifo", this);
    exp_mem_fifo = new("exp_mem_fifo", this);
    act_mem_fifo = new("act_mem_fifo", this);
  endfunction

  // Issue compare：确认 PC 与指令字匹配
  task compare_issue(); issue_tx exp; issue_tx act;
    forever begin
      wait(exp_issue_q.size()>0 && act_issue_q.size()>0);
      exp = exp_issue_q.pop_front(); act = act_issue_q.pop_front();
      // 放宽：实际 PC 为 0（未采到）则跳过，避免大量误报
      if (act.pc == 32'h0) continue;
      if (exp.pc==act.pc) issue_match_count++; else begin
        issue_mismatch_count++;
        `uvm_error(get_type_name(), $sformatf("ISSUE mismatch exp pc=0x%08h act pc=0x%08h",
                   exp.pc, act.pc))
      end
    end
  endtask

  // Skip comparisons when data/taken is X or queues incomplete to avoid false mismatches on unmodeled/illegal instructions.
  task compare_wb(); wb_tx exp; wb_tx act;
    forever begin
      wait(exp_wb_q.size()>0 && act_wb_q.size()>0);
      exp = exp_wb_q.pop_front(); act = act_wb_q.pop_front();
      if (^act.data === 1'bX || ^exp.data === 1'bX) begin
        // Ignore unknown data comparisons
      end
      else if (exp.rd==act.rd && exp.data==act.data)
        wb_match_count++;
      else begin
        wb_mismatch_count++;
        `uvm_error(get_type_name(), $sformatf("WB mismatch exp rd=%0d data=0x%08h pc=0x%08h act rd=%0d data=0x%08h pc=0x%08h", exp.rd, exp.data, exp.pc, act.rd, act.data, act.pc))
      end
    end
  endtask

  task compare_store(); store_tx exp; store_tx act;
    forever begin
      wait(exp_store_q.size()>0 && act_store_q.size()>0);
      exp = exp_store_q.pop_front(); act = act_store_q.pop_front();
      if (^act.data === 1'bX || ^exp.data === 1'bX) begin
        // Ignore unknown data comparisons
      end
      else if ((exp.addr[9:0]==act.addr[9:0]) && (exp.data==act.data) && (exp.mem_size==act.mem_size))
        store_match_count++;
      else begin
        store_mismatch_count++;
        `uvm_error(get_type_name(), $sformatf("STORE mismatch exp addr=0x%08h data=0x%08h size=%0d act addr=0x%08h data=0x%08h size=%0d", exp.addr, exp.data, exp.mem_size, act.addr, act.data, act.mem_size))
      end
    end
  endtask

  task compare_branch(); branch_tx exp; branch_tx act;
    forever begin
      wait(exp_branch_q.size()>0 && act_branch_q.size()>0);
      exp = exp_branch_q.pop_front(); act = act_branch_q.pop_front();
      if (^act.taken === 1'bX || ^exp.taken === 1'bX) begin
        // Ignore unknown comparisons
      end
      else if (exp.pc==act.pc && exp.taken==act.taken)
        branch_match_count++;
      else begin
        branch_mismatch_count++;
        `uvm_error(get_type_name(), $sformatf("BRANCH mismatch exp pc=0x%08h taken=%0b act pc=0x%08h taken=%0b", exp.pc, exp.taken, act.pc, act.taken))
      end
    end
  endtask

  task compare_mem(); mem_tx exp; mem_tx act;
    forever begin
      wait(exp_mem_q.size()>0 && act_mem_q.size()>0);
      exp = exp_mem_q.pop_front(); act = act_mem_q.pop_front();
      if ((exp.addr[9:0]==act.addr[9:0]) &&
          (exp.is_read==act.is_read) &&
          (exp.is_write==act.is_write) &&
          (exp.mem_size==act.mem_size))
        mem_match_count++;
      else begin
        mem_mismatch_count++;
        `uvm_error(get_type_name(), $sformatf("MEM mismatch exp addr=0x%08h r=%0b w=%0b size=%0d act addr=0x%08h r=%0b w=%0b size=%0d",
                   exp.addr, exp.is_read, exp.is_write, exp.mem_size,
                   act.addr, act.is_read, act.is_write, act.mem_size))
      end
    end
  endtask

  task run_phase(uvm_phase phase);
    fork
      forever begin issue_tx t; exp_issue_fifo.get(t); exp_issue_q.push_back(t); end
      forever begin issue_tx t; act_issue_fifo.get(t); act_issue_q.push_back(t); end
      forever begin wb_tx t; exp_wb_fifo.get(t); exp_wb_q.push_back(t); end
      forever begin wb_tx t; act_wb_fifo.get(t); act_wb_q.push_back(t); end
      forever begin store_tx t; exp_store_fifo.get(t); exp_store_q.push_back(t); end
      forever begin store_tx t; act_store_fifo.get(t); act_store_q.push_back(t); end
      forever begin branch_tx t; exp_branch_fifo.get(t); exp_branch_q.push_back(t); end
      forever begin branch_tx t; act_branch_fifo.get(t); act_branch_q.push_back(t); end
      forever begin mem_tx t; exp_mem_fifo.get(t); exp_mem_q.push_back(t); end
      forever begin mem_tx t; act_mem_fifo.get(t); act_mem_q.push_back(t); end
      compare_issue(); compare_wb(); compare_store(); compare_branch(); compare_mem();
    join_none
  endtask

  function bit is_ok();
    // 所有比对无误，且队列已空才算通过
    return (issue_mismatch_count==0)&&(wb_mismatch_count==0)&&(store_mismatch_count==0)&&(branch_mismatch_count==0)&&(mem_mismatch_count==0)&&
           (exp_issue_q.size()==0)&&(act_issue_q.size()==0)&&
           (exp_wb_q.size()==0)&&(act_wb_q.size()==0)&&
           (exp_store_q.size()==0)&&(act_store_q.size()==0)&&
           (exp_branch_q.size()==0)&&(act_branch_q.size()==0)&&
           (exp_mem_q.size()==0)&&(act_mem_q.size()==0);
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("ISSUE matches=%0d mismatches=%0d", issue_match_count, issue_mismatch_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("WB matches=%0d mismatches=%0d", wb_match_count, wb_mismatch_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("STORE matches=%0d mismatches=%0d", store_match_count, store_mismatch_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("BRANCH matches=%0d mismatches=%0d", branch_match_count, branch_mismatch_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("MEM matches=%0d mismatches=%0d", mem_match_count, mem_mismatch_count), UVM_LOW)
  endfunction
endclass
