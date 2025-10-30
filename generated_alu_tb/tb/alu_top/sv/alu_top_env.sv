// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_top_env.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Environment for alu_top
//=============================================================================

`ifndef ALU_TOP_ENV_SV
`define ALU_TOP_ENV_SV

// You can insert code here by setting top_env_inc_before_class in file .\\common.tpl

class alu_top_env extends uvm_env;

  `uvm_component_utils(alu_top_env)

  extern function new(string name, uvm_component parent);


  // Child agents
  alu_config     m_alu_config;  
  alu_agent      m_alu_agent;   
  alu_coverage   m_alu_coverage;

  alu_top_config m_config;
     
  // You can remove build/connect/run_phase by setting top_env_generate_methods_inside_class = no in file .\\common.tpl

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task          run_phase(uvm_phase phase);

  // You can insert code here by setting top_env_inc_inside_class in file .\\common.tpl

endclass : alu_top_env 


function alu_top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can remove build/connect/run_phase by setting top_env_generate_methods_after_class = no in file .\\common.tpl

function void alu_top_env::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In build_phase", UVM_HIGH)

  // You can insert code here by setting top_env_prepend_to_build_phase in file .\\common.tpl

  if (!uvm_config_db #(alu_top_config)::get(this, "", "config", m_config)) 
    `uvm_error(get_type_name(), "Unable to get alu_top_config")

  m_alu_config                 = new("m_alu_config");         
  m_alu_config.vif             = m_config.alu_vif;            
  m_alu_config.is_active       = m_config.is_active_alu;      
  m_alu_config.checks_enable   = m_config.checks_enable_alu;  
  m_alu_config.coverage_enable = m_config.coverage_enable_alu;

  // You can insert code here by setting agent_copy_config_vars in file .\\alu.tpl

  uvm_config_db #(alu_config)::set(this, "m_alu_agent", "config", m_alu_config);
  if (m_alu_config.is_active == UVM_ACTIVE )
    uvm_config_db #(alu_config)::set(this, "m_alu_agent.m_sequencer", "config", m_alu_config);
  uvm_config_db #(alu_config)::set(this, "m_alu_coverage", "config", m_alu_config);


  m_alu_agent    = alu_agent   ::type_id::create("m_alu_agent", this);
  m_alu_coverage = alu_coverage::type_id::create("m_alu_coverage", this);

  // You can insert code here by setting top_env_append_to_build_phase in file .\\common.tpl

endfunction : build_phase


function void alu_top_env::connect_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In connect_phase", UVM_HIGH)

  m_alu_agent.analysis_port.connect(m_alu_coverage.analysis_export);


  // You can insert code here by setting top_env_append_to_connect_phase in file .\\common.tpl

endfunction : connect_phase


// You can remove end_of_elaboration_phase by setting top_env_generate_end_of_elaboration = no in file .\\common.tpl

function void alu_top_env::end_of_elaboration_phase(uvm_phase phase);
  uvm_factory factory = uvm_factory::get();
  `uvm_info(get_type_name(), "Information printed from alu_top_env::end_of_elaboration_phase method", UVM_MEDIUM)
  `uvm_info(get_type_name(), $sformatf("Verbosity threshold is %d", get_report_verbosity_level()), UVM_MEDIUM)
  uvm_top.print_topology();
  factory.print();
endfunction : end_of_elaboration_phase


// You can remove run_phase by setting top_env_generate_run_phase = no in file .\\common.tpl

task alu_top_env::run_phase(uvm_phase phase);
  alu_top_default_seq vseq;
  vseq = alu_top_default_seq::type_id::create("vseq");
  vseq.set_item_context(null, null);
  if ( !vseq.randomize() )
    `uvm_fatal(get_type_name(), "Failed to randomize virtual sequence")
  vseq.m_alu_agent = m_alu_agent;
  vseq.m_config    = m_config;   
  vseq.set_starting_phase(phase);
  vseq.start(null);

  // You can insert code here by setting top_env_append_to_run_phase in file .\\common.tpl

endtask : run_phase


// You can insert code here by setting top_env_inc_after_class in file .\\common.tpl

`endif // ALU_TOP_ENV_SV

