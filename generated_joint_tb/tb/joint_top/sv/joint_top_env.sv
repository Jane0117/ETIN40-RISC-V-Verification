`ifndef JOINT_TOP_ENV_SV
`define JOINT_TOP_ENV_SV

class joint_top_env extends uvm_env;
  `uvm_component_utils(joint_top_env)

  decode_in_agent     m_decode_in_agent;
  decode_wb_agent     m_decode_wb_agent;
  decode_out_agent    m_decode_out_agent;
  execute_out_agent   m_execute_out_agent;
  joint_scoreboard    m_joint_scoreboard;
  joint_ref_model     m_joint_ref_model;
  joint_coverage      m_joint_coverage;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_decode_in_agent   = decode_in_agent    ::type_id::create("m_decode_in_agent",   this);
    m_decode_wb_agent   = decode_wb_agent    ::type_id::create("m_decode_wb_agent",   this);
    m_decode_out_agent  = decode_out_agent   ::type_id::create("m_decode_out_agent",  this);
    m_execute_out_agent = execute_out_agent  ::type_id::create("m_execute_out_agent", this);
    m_joint_scoreboard  = joint_scoreboard   ::type_id::create("m_joint_scoreboard",  this);
    m_joint_ref_model   = joint_ref_model    ::type_id::create("m_joint_ref_model",   this);
    m_joint_coverage    = joint_coverage     ::type_id::create("m_joint_coverage",    this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // decode_out agent set to passive, connect monitor
    m_decode_out_agent.analysis_port.connect(m_joint_scoreboard.dec_imp);
    m_decode_out_agent.analysis_port.connect(m_joint_ref_model.dec_imp);
    m_decode_out_agent.analysis_port.connect(m_joint_coverage.dec_imp);
    // decode_in monitor provides instruction/pc to scoreboard
    m_decode_in_agent.analysis_port.connect(m_joint_scoreboard.dec_in_imp);
    // execute_out agent passive monitor connects to joint scoreboard
    m_execute_out_agent.analysis_port.connect(m_joint_scoreboard.exec_imp);
    m_execute_out_agent.analysis_port.connect(m_joint_coverage.analysis_export);
    // wb agent drives writeback updates
    m_decode_wb_agent.analysis_port.connect(m_joint_scoreboard.wb_imp);
    // ref model expected -> scoreboard
    m_joint_ref_model.exp_ap.connect(m_joint_scoreboard.exp_imp);
  endfunction
endclass

`endif // JOINT_TOP_ENV_SV
