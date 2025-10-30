// You can insert code here by setting file_header_inc in file .\\common.tpl

//=============================================================================
// Project  : generated_alu_tb
//
// File Name: alu_top_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Thu Oct 30 23:56:52 2025
//=============================================================================
// Description: Sequence for alu_top
//=============================================================================

`ifndef ALU_TOP_SEQ_LIB_SV
`define ALU_TOP_SEQ_LIB_SV

class alu_top_default_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(alu_top_default_seq)

  alu_top_config m_config;
  
  alu_agent      m_alu_agent;

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

endclass : alu_top_default_seq


function alu_top_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task alu_top_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)


  repeat (m_seq_count)
  begin
    fork
      if (m_alu_agent.m_config.is_active == UVM_ACTIVE)
      begin
        alu_default_seq seq;
        seq = alu_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_alu_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_alu_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_alu_agent.m_sequencer, this);
      end
    join
  end

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


task alu_top_default_seq::pre_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null)
    phase.raise_objection(this);
endtask: pre_start


task alu_top_default_seq::post_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null) 
    phase.drop_objection(this);
endtask: post_start


`ifndef UVM_POST_VERSION_1_1
function uvm_phase alu_top_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void alu_top_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting top_seq_inc in file .\\common.tpl

`endif // ALU_TOP_SEQ_LIB_SV

