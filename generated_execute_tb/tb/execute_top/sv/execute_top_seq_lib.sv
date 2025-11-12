// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 19:32:24 2025
//=============================================================================
// Description: Sequence for execute_top
//=============================================================================

`ifndef EXECUTE_TOP_SEQ_LIB_SV
`define EXECUTE_TOP_SEQ_LIB_SV

class execute_top_default_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(execute_top_default_seq)

  execute_top_config m_config;
          
  decode_in_agent    m_decode_in_agent;  
  forward_agent      m_forward_agent;    
  execute_out_agent  m_execute_out_agent;

  // Number of times to repeat child sequences
  int m_seq_count = 1;

  extern function new(string name = "");
  extern task body();
  extern task pre_start();
  extern task post_start();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : execute_top_default_seq


function execute_top_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task execute_top_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)


  repeat (m_seq_count)
  begin
    fork
      if (m_decode_in_agent.m_config.is_active == UVM_ACTIVE)
      begin
        decode_in_default_seq seq;
        seq = decode_in_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_decode_in_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_decode_in_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_decode_in_agent.m_sequencer, this);
      end
      if (m_forward_agent.m_config.is_active == UVM_ACTIVE)
      begin
        forward_default_seq seq;
        seq = forward_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_forward_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_forward_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_forward_agent.m_sequencer, this);
      end
      if (m_execute_out_agent.m_config.is_active == UVM_ACTIVE)
      begin
        execute_out_default_seq seq;
        seq = execute_out_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_execute_out_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_execute_out_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_execute_out_agent.m_sequencer, this);
      end
    join
  end

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


task execute_top_default_seq::pre_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null)
    phase.raise_objection(this);
endtask: pre_start


task execute_top_default_seq::post_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null) 
    phase.drop_objection(this);
endtask: post_start


`ifndef UVM_POST_VERSION_1_1
function uvm_phase execute_top_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void execute_top_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting top_seq_inc in file execute_common.tpl

`endif // EXECUTE_TOP_SEQ_LIB_SV

