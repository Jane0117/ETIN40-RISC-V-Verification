// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_env.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Environment for decode_top
//=============================================================================

`ifndef DECODE_TOP_ENV_SV
`define DECODE_TOP_ENV_SV

// You can insert code here by setting top_env_inc_before_class in file decode_common.tpl

class decode_top_env extends uvm_env;

  `uvm_component_utils(decode_top_env)

  extern function new(string name, uvm_component parent);


  // Child agents
  decode_in_config     m_decode_in_config;   
  decode_in_agent      m_decode_in_agent;    
  decode_in_coverage   m_decode_in_coverage; 

  decode_wb_config     m_decode_wb_config;   
  decode_wb_agent      m_decode_wb_agent;    
  decode_wb_coverage   m_decode_wb_coverage; 

  decode_out_config    m_decode_out_config;  
  decode_out_agent     m_decode_out_agent;   
  decode_out_coverage  m_decode_out_coverage;

  decode_scoreboard    m_decode_scoreboard;

  decode_top_config    m_config;
            
  // You can remove build/connect/run_phase by setting top_env_generate_methods_inside_class = no in file decode_common.tpl

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task          run_phase(uvm_phase phase);

  // You can insert code here by setting top_env_inc_inside_class in file decode_common.tpl

endclass : decode_top_env 


function decode_top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can remove build/connect/run_phase by setting top_env_generate_methods_after_class = no in file decode_common.tpl

function void decode_top_env::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In build_phase", UVM_HIGH)

  // You can insert code here by setting top_env_prepend_to_build_phase in file decode_common.tpl

  if (!uvm_config_db #(decode_top_config)::get(this, "", "config", m_config)) 
    `uvm_error(get_type_name(), "Unable to get decode_top_config")

  m_decode_in_config                 = new("m_decode_in_config");         
  m_decode_in_config.vif             = m_config.decode_in_vif;            
  m_decode_in_config.is_active       = m_config.is_active_decode_in;      
  m_decode_in_config.checks_enable   = m_config.checks_enable_decode_in;  
  m_decode_in_config.coverage_enable = m_config.coverage_enable_decode_in;

  // You can insert code here by setting agent_copy_config_vars in file decode_in.tpl

  uvm_config_db #(decode_in_config)::set(this, "m_decode_in_agent", "config", m_decode_in_config);
  uvm_config_db #(virtual decode_in_if)::set(this, "m_decode_in_agent.m_driver", "vif", m_decode_in_config.vif);
  uvm_config_db #(virtual decode_in_if)::set(this, "m_decode_in_agent.m_monitor", "vif", m_decode_in_config.vif);
  uvm_config_db #(decode_in_config)::set(this, "m_decode_in_agent.m_driver", "config", m_decode_in_config);
  if (m_decode_in_config.is_active == UVM_ACTIVE )
    uvm_config_db #(decode_in_config)::set(this, "m_decode_in_agent.m_sequencer", "config", m_decode_in_config);
  uvm_config_db #(decode_in_config)::set(this, "m_decode_in_coverage", "config", m_decode_in_config);

  m_decode_wb_config                 = new("m_decode_wb_config");         
  m_decode_wb_config.vif             = m_config.decode_wb_vif;            
  m_decode_wb_config.is_active       = m_config.is_active_decode_wb;      
  m_decode_wb_config.checks_enable   = m_config.checks_enable_decode_wb;  
  m_decode_wb_config.coverage_enable = m_config.coverage_enable_decode_wb;

  // You can insert code here by setting agent_copy_config_vars in file decode_wb.tpl

  uvm_config_db #(decode_wb_config)::set(this, "m_decode_wb_agent", "config", m_decode_wb_config);
  uvm_config_db #(virtual decode_wb_if)::set(this, "m_decode_wb_agent.m_driver", "vif", m_decode_wb_config.vif);
  uvm_config_db #(virtual decode_wb_if)::set(this, "m_decode_wb_agent.m_monitor", "vif", m_decode_wb_config.vif);
  uvm_config_db #(decode_wb_config)::set(this, "m_decode_wb_agent.m_driver", "config", m_decode_wb_config);
  if (m_decode_wb_config.is_active == UVM_ACTIVE )
    uvm_config_db #(decode_wb_config)::set(this, "m_decode_wb_agent.m_sequencer", "config", m_decode_wb_config);
  uvm_config_db #(decode_wb_config)::set(this, "m_decode_wb_coverage", "config", m_decode_wb_config);

  m_decode_out_config                 = new("m_decode_out_config");         
  m_decode_out_config.vif             = m_config.decode_out_vif;            
  m_decode_out_config.is_active       = m_config.is_active_decode_out;      
  m_decode_out_config.checks_enable   = m_config.checks_enable_decode_out;  
  m_decode_out_config.coverage_enable = m_config.coverage_enable_decode_out;

  // You can insert code here by setting agent_copy_config_vars in file decode_out.tpl

  uvm_config_db #(decode_out_config)::set(this, "m_decode_out_agent", "config", m_decode_out_config);
  uvm_config_db #(virtual decode_out_if)::set(this, "m_decode_out_agent.m_monitor", "vif", m_decode_out_config.vif);
  if (m_decode_out_config.is_active == UVM_ACTIVE )
    uvm_config_db #(decode_out_config)::set(this, "m_decode_out_agent.m_sequencer", "config", m_decode_out_config);
  uvm_config_db #(decode_out_config)::set(this, "m_decode_out_coverage", "config", m_decode_out_config);


  m_decode_in_agent     = decode_in_agent    ::type_id::create("m_decode_in_agent", this);
  m_decode_in_coverage  = decode_in_coverage ::type_id::create("m_decode_in_coverage", this);

  m_decode_wb_agent     = decode_wb_agent    ::type_id::create("m_decode_wb_agent", this);
  m_decode_wb_coverage  = decode_wb_coverage ::type_id::create("m_decode_wb_coverage", this);

  m_decode_out_agent    = decode_out_agent   ::type_id::create("m_decode_out_agent", this);
  m_decode_out_coverage = decode_out_coverage::type_id::create("m_decode_out_coverage", this);
  m_decode_scoreboard   = decode_scoreboard  ::type_id::create("m_decode_scoreboard", this);

  // You can insert code here by setting top_env_append_to_build_phase in file decode_common.tpl

endfunction : build_phase


function void decode_top_env::connect_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In connect_phase", UVM_HIGH)

  m_decode_in_agent.analysis_port.connect(m_decode_in_coverage.analysis_export);

  m_decode_wb_agent.analysis_port.connect(m_decode_wb_coverage.analysis_export);

  m_decode_in_agent.analysis_port.connect(m_decode_scoreboard.in_imp);
  m_decode_out_agent.analysis_port.connect(m_decode_scoreboard.out_imp);
  m_decode_wb_agent.analysis_port.connect(m_decode_scoreboard.wb_imp);

  m_decode_out_agent.analysis_port.connect(m_decode_out_coverage.analysis_export);


  // You can insert code here by setting top_env_append_to_connect_phase in file decode_common.tpl

endfunction : connect_phase


// You can remove end_of_elaboration_phase by setting top_env_generate_end_of_elaboration = no in file decode_common.tpl

function void decode_top_env::end_of_elaboration_phase(uvm_phase phase);
  uvm_factory factory = uvm_factory::get();
  `uvm_info(get_type_name(), "Information printed from decode_top_env::end_of_elaboration_phase method", UVM_MEDIUM)
  `uvm_info(get_type_name(), $sformatf("Verbosity threshold is %d", get_report_verbosity_level()), UVM_MEDIUM)
  uvm_top.print_topology();
  factory.print();
endfunction : end_of_elaboration_phase


// You can remove run_phase by setting top_env_generate_run_phase = no in file decode_common.tpl

task decode_top_env::run_phase(uvm_phase phase);
  decode_top_default_seq vseq;
  vseq = decode_top_default_seq::type_id::create("vseq");
  vseq.set_item_context(null, null);
  if ( !vseq.randomize() )
    `uvm_fatal(get_type_name(), "Failed to randomize virtual sequence")
  vseq.m_decode_in_agent  = m_decode_in_agent; 
  vseq.m_decode_wb_agent  = m_decode_wb_agent; 
  vseq.m_decode_out_agent = m_decode_out_agent;
  vseq.m_config           = m_config;          
  vseq.set_starting_phase(phase);
  phase.raise_objection(this);
  vseq.start(null);
  phase.drop_objection(this);

  // You can insert code here by setting top_env_append_to_run_phase in file decode_common.tpl

endtask : run_phase


// You can insert code here by setting top_env_inc_after_class in file decode_common.tpl

`endif // DECODE_TOP_ENV_SV

