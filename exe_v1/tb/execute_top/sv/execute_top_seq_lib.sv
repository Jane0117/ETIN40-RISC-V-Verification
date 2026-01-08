// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_top_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Sequence for execute_top
//=============================================================================

`ifndef EXECUTE_TOP_SEQ_LIB_SV
`define EXECUTE_TOP_SEQ_LIB_SV

class execute_top_default_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(execute_top_default_seq)

  execute_top_config m_config;
          
  execute_in_agent   m_execute_in_agent; 
  execute_out_agent  m_execute_out_agent;

  // Number of times to repeat child sequences
  int m_seq_count = 200;

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
  int iter;
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)

  for (iter = 0; iter < m_seq_count; iter++)
  begin
    `uvm_info(get_type_name(), $sformatf("iteration %0d", iter), UVM_LOW)
    fork
      if (m_execute_in_agent.m_config.is_active == UVM_ACTIVE)
      begin
        execute_in_default_seq seq;
        `uvm_info(get_type_name(), "start one sequence", UVM_LOW)
        seq = execute_in_default_seq::type_id::create("seq");
        seq.set_item_context(this, m_execute_in_agent.m_sequencer);
        if ( !seq.randomize() )
          `uvm_error(get_type_name(), "Failed to randomize sequence")
        seq.m_config = m_execute_in_agent.m_config;
        seq.set_starting_phase( get_starting_phase() );
        seq.start(m_execute_in_agent.m_sequencer, this);
        `uvm_info(get_type_name(), "end one sequence", UVM_LOW)
      end
      // execute_out is passive for DUT outputs, no sequence needed
    join
  end
  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


// task execute_top_default_seq::pre_start();
//   uvm_phase phase = get_starting_phase();
// endtask: pre_start


// task execute_top_default_seq::post_start();
//   #10ns;
// endtask: post_start
task execute_top_default_seq::pre_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null)
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "objection raised", UVM_LOW)
endtask: pre_start


task execute_top_default_seq::post_start();
  uvm_phase phase = get_starting_phase();
  if (phase != null) 
    phase.drop_objection(this);
    `uvm_info(get_type_name(), "objection drop", UVM_LOW)
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

