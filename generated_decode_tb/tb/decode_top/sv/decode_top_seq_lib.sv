// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_top_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequence for decode_top
//=============================================================================

`ifndef DECODE_TOP_SEQ_LIB_SV
`define DECODE_TOP_SEQ_LIB_SV

class decode_top_default_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(decode_top_default_seq)

  decode_top_config m_config;
         
  decode_in_agent   m_decode_in_agent; 
  decode_wb_agent   m_decode_wb_agent; 
  decode_out_agent  m_decode_out_agent;

  // Number of times to repeat child sequences
  int m_seq_count = 5;

  extern function new(string name = "");
  extern task body();
  extern task pre_start();
  extern task post_start();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : decode_top_default_seq


function decode_top_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task decode_top_default_seq::body();
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
      if (m_decode_wb_agent.m_config.is_active == UVM_ACTIVE)
      begin
        decode_wb_default_seq seq;
        seq = decode_wb_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_decode_wb_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_decode_wb_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_decode_wb_agent.m_sequencer, this);
      end
      if (m_decode_out_agent.m_config.is_active == UVM_ACTIVE)
      begin
        decode_out_default_seq seq;
        seq = decode_out_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_decode_out_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_decode_out_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_decode_out_agent.m_sequencer, this);
      end
    join
  end

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


task decode_top_default_seq::pre_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null)
    phase.raise_objection(this);
endtask: pre_start


task decode_top_default_seq::post_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null) 
    phase.drop_objection(this);
endtask: post_start


`ifndef UVM_POST_VERSION_1_1
function uvm_phase decode_top_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void decode_top_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting top_seq_inc in file decode_common.tpl

`endif // DECODE_TOP_SEQ_LIB_SV

