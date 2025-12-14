// 虚拟 sequencer：挂载各子 agent 的 sequencer 句柄，供虚拟 sequence 统一调度
`ifndef EXECUTE_TOP_VIRTUAL_SEQUENCER_SV
`define EXECUTE_TOP_VIRTUAL_SEQUENCER_SV

class execute_top_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

  `uvm_component_utils(execute_top_virtual_sequencer)

  execute_in_sequencer   m_execute_in_sqr;
  forward_sequencer_t    m_forward_sqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : execute_top_virtual_sequencer

`endif // EXECUTE_TOP_VIRTUAL_SEQUENCER_SV
