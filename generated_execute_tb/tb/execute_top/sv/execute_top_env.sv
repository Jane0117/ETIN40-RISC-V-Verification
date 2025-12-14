// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_env.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Environment for execute_top
//=============================================================================

`ifndef EXECUTE_TOP_ENV_SV
`define EXECUTE_TOP_ENV_SV

// You can insert code here by setting top_env_inc_before_class in file execute_common.tpl

class execute_top_env extends uvm_env;

  `uvm_component_utils(execute_top_env)

  extern function new(string name, uvm_component parent);


  // Child agents
  execute_in_config     m_execute_in_config;   
  execute_in_agent      m_execute_in_agent;    
  execute_in_coverage   m_execute_in_coverage; 

  forward_config        m_forward_config;      
  forward_agent         m_forward_agent;       
  forward_coverage      m_forward_coverage;    
  forward_scoreboard    m_forward_scoreboard;

  execute_out_config    m_execute_out_config;  
  execute_out_agent     m_execute_out_agent;   
  execute_out_coverage  m_execute_out_coverage;
  uvm_tlm_analysis_fifo #(execute_out_tx) m_scoreboard_act_fifo;
  uvm_tlm_analysis_fifo #(execute_out_tx) m_scoreboard_exp_fifo;
  execute_stage_scoreboard                m_scoreboard;
  execute_top_virtual_sequencer           m_vseqr;

  uvm_tlm_analysis_fifo #(execute_out_tx)    m_execute_out_fifo; // FIFO connecting monitor to ref model
  execute_stage_ref_model                    m_ref_model;       // Reference model to consume execute_out transactions

  execute_top_config    m_config;
             
  // You can remove build/connect/run_phase by setting top_env_generate_methods_inside_class = no in file execute_common.tpl

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task          run_phase(uvm_phase phase);

  // You can insert code here by setting top_env_inc_inside_class in file execute_common.tpl

endclass : execute_top_env 


function execute_top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can remove build/connect/run_phase by setting top_env_generate_methods_after_class = no in file execute_common.tpl

function void execute_top_env::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In build_phase", UVM_HIGH)

  // You can insert code here by setting top_env_prepend_to_build_phase in file execute_common.tpl

  if (!uvm_config_db #(execute_top_config)::get(this, "", "config", m_config)) 
    `uvm_error(get_type_name(), "Unable to get execute_top_config")

  m_execute_in_config                 = new("m_execute_in_config");         
  m_execute_in_config.vif             = m_config.execute_in_vif;            
  m_execute_in_config.is_active       = m_config.is_active_execute_in;      
  m_execute_in_config.checks_enable   = m_config.checks_enable_execute_in;  
  m_execute_in_config.coverage_enable = m_config.coverage_enable_execute_in;

  // You can insert code here by setting agent_copy_config_vars in file execute_in.tpl

  uvm_config_db #(execute_in_config)::set(this, "m_execute_in_agent", "config", m_execute_in_config);
  uvm_config_db #(virtual execute_in_if)::set(this, "m_execute_in_agent.m_driver", "vif", m_execute_in_config.vif);
  uvm_config_db #(virtual execute_in_if)::set(this, "m_execute_in_agent.m_monitor", "vif", m_execute_in_config.vif);
  if (m_execute_in_config.is_active == UVM_ACTIVE )
    uvm_config_db #(execute_in_config)::set(this, "m_execute_in_agent.m_sequencer", "config", m_execute_in_config);
  uvm_config_db #(execute_in_config)::set(this, "m_execute_in_coverage", "config", m_execute_in_config);

  m_forward_config                 = new("m_forward_config");         
  m_forward_config.vif             = m_config.forward_vif;            
  m_forward_config.is_active       = m_config.is_active_forward;      
  m_forward_config.checks_enable   = m_config.checks_enable_forward;  
  m_forward_config.coverage_enable = m_config.coverage_enable_forward;

  // You can insert code here by setting agent_copy_config_vars in file forward.tpl

  uvm_config_db #(forward_config)::set(this, "m_forward_agent", "config", m_forward_config);
  uvm_config_db #(virtual forward_if)::set(this, "m_forward_agent.m_driver", "vif", m_forward_config.vif);
  uvm_config_db #(virtual forward_if)::set(this, "m_forward_agent.m_monitor", "vif", m_forward_config.vif);
  if (m_forward_config.is_active == UVM_ACTIVE )
    uvm_config_db #(forward_config)::set(this, "m_forward_agent.m_sequencer", "config", m_forward_config);
  uvm_config_db #(forward_config)::set(this, "m_forward_coverage", "config", m_forward_config);

  m_execute_out_config                 = new("m_execute_out_config");         
  m_execute_out_config.vif             = m_config.execute_out_vif;            
  m_execute_out_config.is_active       = m_config.is_active_execute_out;      
  m_execute_out_config.checks_enable   = m_config.checks_enable_execute_out;  
  m_execute_out_config.coverage_enable = m_config.coverage_enable_execute_out;

  // You can insert code here by setting agent_copy_config_vars in file execute_out.tpl

  uvm_config_db #(execute_out_config)::set(this, "m_execute_out_agent", "config", m_execute_out_config);
  if (m_execute_out_config.is_active == UVM_ACTIVE )
    uvm_config_db #(execute_out_config)::set(this, "m_execute_out_agent.m_sequencer", "config", m_execute_out_config);
  uvm_config_db #(execute_out_config)::set(this, "m_execute_out_coverage", "config", m_execute_out_config);
  // Provide virtual interface handles for execute_out agent components
  uvm_config_db #(virtual execute_out_if)::set(this, "m_execute_out_agent.m_monitor", "vif", m_execute_out_config.vif);
  uvm_config_db #(virtual execute_out_if)::set(this, "m_execute_out_agent.m_driver",   "vif", m_execute_out_config.vif);


  m_execute_in_agent     = execute_in_agent    ::type_id::create("m_execute_in_agent", this);
  m_execute_in_coverage  = execute_in_coverage ::type_id::create("m_execute_in_coverage", this);

  m_forward_agent        = forward_agent       ::type_id::create("m_forward_agent", this);
  m_forward_coverage     = forward_coverage    ::type_id::create("m_forward_coverage", this);

  m_execute_out_agent    = execute_out_agent   ::type_id::create("m_execute_out_agent", this);
  m_execute_out_coverage = execute_out_coverage::type_id::create("m_execute_out_coverage", this);
  
  m_execute_out_fifo     = new("m_execute_out_fifo");
  m_ref_model            = execute_stage_ref_model::type_id::create("m_ref_model", this);
  uvm_config_db #(execute_stage_ref_model)::set(this, "m_execute_out_agent", "ref_model", m_ref_model);
  m_scoreboard           = execute_stage_scoreboard::type_id::create("m_scoreboard", this);
  m_scoreboard_act_fifo  = new("m_scoreboard_act_fifo");
  m_scoreboard_exp_fifo  = new("m_scoreboard_exp_fifo");
  m_forward_scoreboard   = forward_scoreboard   ::type_id::create("m_forward_scoreboard", this);
  m_vseqr                = execute_top_virtual_sequencer::type_id::create("m_vseqr", this);

  // You can insert code here by setting top_env_append_to_build_phase in file execute_common.tpl

endfunction : build_phase


function void execute_top_env::connect_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In connect_phase", UVM_HIGH)

  m_execute_in_agent.analysis_port.connect(m_execute_in_coverage.analysis_export);

  m_forward_agent.analysis_port.connect(m_forward_coverage.analysis_export);
  // forward scoreboard connections: driver ap -> exp, monitor -> act
  m_forward_agent.m_driver.ap.connect(m_forward_scoreboard.exp_imp);
  m_forward_agent.m_monitor.analysis_port.connect(m_forward_scoreboard.act_imp);

  m_execute_out_agent.analysis_port.connect(m_execute_out_coverage.analysis_export);
  // FIFO + reference model connections
  m_execute_out_agent.analysis_port.connect(m_execute_out_fifo.analysis_export);
  m_ref_model.port.connect(m_execute_out_fifo.get_peek_export);
  // Scoreboard connections
  m_execute_out_agent.analysis_port.connect(m_scoreboard_act_fifo.analysis_export);
  m_scoreboard.act_port.connect(m_scoreboard_act_fifo.get_peek_export);
  m_ref_model.ref_ap.connect(m_scoreboard_exp_fifo.analysis_export);
  m_scoreboard.exp_port.connect(m_scoreboard_exp_fifo.get_peek_export);

  // 虚拟 sequencer 绑定子 sequencer 句柄
  if (m_vseqr != null) begin
    if (m_execute_in_agent != null)
      m_vseqr.m_execute_in_sqr = m_execute_in_agent.m_sequencer;
    if (m_forward_agent != null)
      m_vseqr.m_forward_sqr    = m_forward_agent.m_sequencer;
  end


  // You can insert code here by setting top_env_append_to_connect_phase in file execute_common.tpl

endfunction : connect_phase


// You can remove end_of_elaboration_phase by setting top_env_generate_end_of_elaboration = no in file execute_common.tpl

function void execute_top_env::end_of_elaboration_phase(uvm_phase phase);
  uvm_factory factory = uvm_factory::get();
  `uvm_info(get_type_name(), "Information printed from execute_top_env::end_of_elaboration_phase method", UVM_MEDIUM)
  `uvm_info(get_type_name(), $sformatf("Verbosity threshold is %d", get_report_verbosity_level()), UVM_MEDIUM)
  uvm_top.print_topology();
  factory.print();
endfunction : end_of_elaboration_phase


// You can remove run_phase by setting top_env_generate_run_phase = no in file execute_common.tpl

task execute_top_env::run_phase(uvm_phase phase);
  execute_top_default_seq vseq;
  vseq = execute_top_default_seq::type_id::create("vseq");
  vseq.m_vsqr   = m_vseqr;
  vseq.m_config = m_config;
  vseq.set_starting_phase(phase);
  if (!vseq.randomize())
    `uvm_fatal(get_type_name(), "Failed to randomize execute_top_default_seq")
  vseq.start(m_vseqr);

  // You can insert code here by setting top_env_append_to_run_phase in file execute_common.tpl

endtask : run_phase


// You can insert code here by setting top_env_inc_after_class in file execute_common.tpl

`endif // EXECUTE_TOP_ENV_SV

