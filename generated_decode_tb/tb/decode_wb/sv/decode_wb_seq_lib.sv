// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_wb_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequence for agent decode_wb
//=============================================================================

`ifndef DECODE_WB_SEQ_LIB_SV
`define DECODE_WB_SEQ_LIB_SV

class decode_wb_default_seq extends uvm_sequence #(decode_wb_tx);

  `uvm_object_utils(decode_wb_default_seq)

  decode_wb_config  m_config;
  int unsigned      m_seq_count = 20;

  extern function new(string name = "");
  extern task body();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : decode_wb_default_seq


function decode_wb_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task decode_wb_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)

  for (int unsigned i = 0; i < m_seq_count; i++) begin
    req = decode_wb_tx::type_id::create($sformatf("req_%0d", i));
    start_item(req); 
    // Edge-heavy writeback patterns
    req.write_en   = ($urandom_range(0,9) < 7); // 70% enable
    req.write_id   = $urandom_range(0,31);
    unique case (i % 3)
      0: req.write_data = 32'h0000_0000;
      1: req.write_data = 32'hFFFF_FFFF;
      default: req.write_data = $urandom();
    endcase
    finish_item(req); 
  end

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


`ifndef UVM_POST_VERSION_1_1
function uvm_phase decode_wb_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void decode_wb_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting agent_seq_inc in file decode_wb.tpl

`endif // DECODE_WB_SEQ_LIB_SV

