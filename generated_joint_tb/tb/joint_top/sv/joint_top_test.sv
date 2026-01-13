`ifndef JOINT_TOP_TEST_SV
`define JOINT_TOP_TEST_SV

class joint_top_test extends uvm_test;
  `uvm_component_utils(joint_top_test)

  joint_top_env m_env;

  function new(string name = "joint_top_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // agent activity
    uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.m_decode_in_agent",   "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.m_decode_wb_agent",   "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.m_decode_out_agent",  "is_active", UVM_PASSIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.m_execute_out_agent", "is_active", UVM_PASSIVE);

    // 默认序列
    uvm_config_db#(uvm_object_wrapper)::set(this,
      "m_env.m_decode_in_agent.m_sequencer.run_phase",
      "default_sequence", decode_in_default_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,
      "m_env.m_decode_wb_agent.m_sequencer.run_phase",
      "default_sequence", decode_wb_default_seq::type_id::get());

    m_env = joint_top_env::type_id::create("m_env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "joint_top_test run");
    // 运行足够长时间以覆盖默认序列
    #5000ns;
    phase.drop_objection(this, "joint_top_test run done");
  endtask
endclass

`endif // JOINT_TOP_TEST_SV
