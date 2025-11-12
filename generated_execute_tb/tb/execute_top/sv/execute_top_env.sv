// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_env.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
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
  decode_in_config      m_decode_in_config;    
  decode_in_agent       m_decode_in_agent;     
  decode_in_coverage    m_decode_in_coverage;  

  forward_config        m_forward_config;      
  forward_agent         m_forward_agent;       
  forward_coverage      m_forward_coverage;    

  execute_out_config    m_execute_out_config;  
  execute_out_agent     m_execute_out_agent;   
  execute_out_coverage  m_execute_out_coverage;

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

  m_decode_in_config                 = new("m_decode_in_config");         
  m_decode_in_config.vif             = m_config.decode_in_vif;            
  m_decode_in_config.is_active       = m_config.is_active_decode_in;      
  m_decode_in_config.checks_enable   = m_config.checks_enable_decode_in;  
  m_decode_in_config.coverage_enable = m_config.coverage_enable_decode_in;

  // You can insert code here by setting agent_copy_config_vars in file decode_in.tpl

  uvm_config_db #(decode_in_config)::set(this, "m_decode_in_agent", "config", m_decode_in_config);
  if (m_decode_in_config.is_active == UVM_ACTIVE )
    uvm_config_db #(decode_in_config)::set(this, "m_decode_in_agent.m_sequencer", "config", m_decode_in_config);
  uvm_config_db #(decode_in_config)::set(this, "m_decode_in_coverage", "config", m_decode_in_config);

  m_forward_config                 = new("m_forward_config");         
  m_forward_config.vif             = m_config.forward_vif;            
  m_forward_config.is_active       = m_config.is_active_forward;      
  m_forward_config.checks_enable   = m_config.checks_enable_forward;  
  m_forward_config.coverage_enable = m_config.coverage_enable_forward;

  // You can insert code here by setting agent_copy_config_vars in file forward.tpl

  uvm_config_db #(forward_config)::set(this, "m_forward_agent", "config", m_forward_config);
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


  m_decode_in_agent      = decode_in_agent     ::type_id::create("m_decode_in_agent", this);
  m_decode_in_coverage   = decode_in_coverage  ::type_id::create("m_decode_in_coverage", this);

  m_forward_agent        = forward_agent       ::type_id::create("m_forward_agent", this);
  m_forward_coverage     = forward_coverage    ::type_id::create("m_forward_coverage", this);

  m_execute_out_agent    = execute_out_agent   ::type_id::create("m_execute_out_agent", this);
  m_execute_out_coverage = execute_out_coverage::type_id::create("m_execute_out_coverage", this);

  // You can insert code here by setting top_env_append_to_build_phase in file execute_common.tpl

endfunction : build_phase


function void execute_top_env::connect_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In connect_phase", UVM_HIGH)

  m_decode_in_agent.analysis_port.connect(m_decode_in_coverage.analysis_export);

  m_forward_agent.analysis_port.connect(m_forward_coverage.analysis_export);

  m_execute_out_agent.analysis_port.connect(m_execute_out_coverage.analysis_export);


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
  vseq.set_item_context(null, null);
  if ( !vseq.randomize() )
    `uvm_fatal(get_type_name(), "Failed to randomize virtual sequence")
  vseq.m_decode_in_agent   = m_decode_in_agent;  
  vseq.m_forward_agent     = m_forward_agent;    
  vseq.m_execute_out_agent = m_execute_out_agent;
  vseq.m_config            = m_config;           
  vseq.set_starting_phase(phase);
  vseq.start(null);

  // You can insert code here by setting top_env_append_to_run_phase in file execute_common.tpl

endtask : run_phase


// You can insert code here by setting top_env_inc_after_class in file execute_common.tpl

`endif // EXECUTE_TOP_ENV_SV

