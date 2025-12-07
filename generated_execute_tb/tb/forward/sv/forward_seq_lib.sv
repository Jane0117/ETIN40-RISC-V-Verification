// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Sequence for agent forward
//=============================================================================

`ifndef FORWARD_SEQ_LIB_SV
`define FORWARD_SEQ_LIB_SV

class forward_default_seq extends uvm_sequence #(forward_tx);

  `uvm_object_utils(forward_default_seq)

  forward_config  m_config;

  extern function new(string name = "");
  extern task body();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : forward_default_seq


function forward_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task forward_default_seq::body();
  // 先声明/初始化查找表，避免在语句后再声明触发编译器报错
  forward_type rs1_lut[9] = '{FORWARD_NONE,     FORWARD_FROM_MEM, FORWARD_FROM_EX,
                             FORWARD_NONE,     FORWARD_FROM_MEM, FORWARD_FROM_EX,
                             FORWARD_NONE,     FORWARD_FROM_MEM, FORWARD_FROM_EX};
  forward_type rs2_lut[9] = '{FORWARD_NONE,     FORWARD_NONE,     FORWARD_NONE,
                             FORWARD_FROM_MEM, FORWARD_FROM_MEM, FORWARD_FROM_MEM,
                             FORWARD_FROM_EX,  FORWARD_FROM_EX,  FORWARD_FROM_EX};

  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)
  // 穷举 9 条 forwarding path 组合，确保覆盖/scoreboard 覆盖到每条路径
  // 2张表内容不同，下面foreach里同一个i实际上对应不同的组合

  foreach (rs1_lut[i]) begin//枚举 rs1_lut 的每个下标，把当前下标放在循环变量 i 里
    //req = forward_tx::type_id::create($sformatf("req_%0d", i), this);
    req = forward_tx::type_id::create($sformatf("req_%0d", i)); // parent 为空，避免类型不匹配
    start_item(req);
    if (!req.randomize() with {forward_rs1 == rs1_lut[i]; forward_rs2 == rs2_lut[i];})
      `uvm_error(get_type_name(), $sformatf("Failed to randomize transaction %0d", i))
    //randomize() 成功后，post_randomize() 会被自动调用
    //req.bake_expect(); // ensure exp/path fields更新，即便后续有手动改动
    `uvm_info(get_type_name(),
              $sformatf("Seq push %0d: rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path_tag=%0d",
                        i, req.forward_rs1, req.forward_rs2,
                        req.wb_forward_data, req.mem_forward_data, req.path_tag),
              UVM_HIGH)
    finish_item(req);
  end

  `uvm_info(get_type_name(), "Default sequence completed (9-path sweep)", UVM_HIGH)
endtask : body


`ifndef UVM_POST_VERSION_1_1
function uvm_phase forward_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void forward_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting agent_seq_inc in file forward.tpl

`endif // FORWARD_SEQ_LIB_SV

