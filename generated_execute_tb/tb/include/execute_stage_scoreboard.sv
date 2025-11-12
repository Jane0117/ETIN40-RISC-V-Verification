class execute_stage_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(execute_stage_scoreboard)

  uvm_blocking_get_port #(execute_out_tx) exp_port;
  uvm_blocking_get_port #(execute_out_tx) act_port;
  execute_out_tx expect_queue[$];

  extern function new(string name, uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
endclass

function execute_stage_scoreboard::new(string name, uvm_component parent = null);
  super.new(name, parent);
endfunction

function void execute_stage_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  exp_port = new("exp_port", this);
  act_port = new("act_port", this);
endfunction

task execute_stage_scoreboard::main_phase(uvm_phase phase);
  execute_out_tx get_expect;
  execute_out_tx get_actual;
  execute_out_tx tmp_tran;
  bit result;
  super.main_phase(phase);
  fork
    //thread1:不断从 exp_port（reference model）中 get() expect transaction，
    //并推到 expect_queue
    while (1) begin
      exp_port.get(get_expect);
      expect_queue.push_back(get_expect);
    end
    //thread2:持续从 act_port（实际 monitor）里取 actual transaction，
    //一旦 expect_queue 里有数据就 pop_front() 比较字段，
    //结果 ok 则 uvm_info，否则 uvm_error 并打印期望/实际的差异；若 queue 为空就报错。
    while (1) begin
      act_port.get(get_actual);
      if (expect_queue.size() > 0) begin
        tmp_tran = expect_queue.pop_front();
        result = 1;
        // &= means result = result & (...)
        result &= (get_actual.control_out == tmp_tran.control_out);
        result &= (get_actual.alu_data == tmp_tran.alu_data);
        result &= (get_actual.memory_data == tmp_tran.memory_data);
        result &= (get_actual.pc_src == tmp_tran.pc_src);
        result &= (get_actual.jalr_target_offset == tmp_tran.jalr_target_offset);
        result &= (get_actual.jalr_flag == tmp_tran.jalr_flag);
        result &= (get_actual.pc_out == tmp_tran.pc_out);
        result &= (get_actual.overflow == tmp_tran.overflow);
        if (result) begin
          `uvm_info(get_type_name(), \"execute_stage comparison passed\", UVM_LOW);
        end else begin
          `uvm_error(get_type_name(), \"execute_stage comparison FAILED\");
          `uvm_info(get_type_name(), $sformatf(\"Expect: control_out=%0h, alu_data=%0d, memory_data=%0d, pc_src=%0b\", tmp_tran.control_out, tmp_tran.alu_data, tmp_tran.memory_data, tmp_tran.pc_src), UVM_LOW);
          `uvm_info(get_type_name(), $sformatf(\"Actual: control_out=%0h, alu_data=%0d, memory_data=%0d, pc_src=%0b\", get_actual.control_out, get_actual.alu_data, get_actual.memory_data, get_actual.pc_src), UVM_LOW);
        end
      end else begin
        `uvm_error(get_type_name(), \"actual transaction received while expect queue empty\");
      end
    end
  join_none
endtask
