// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Coverage for agent execute_in
//=============================================================================

`ifndef EXECUTE_IN_COVERAGE_SV
`define EXECUTE_IN_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file execute_in.tpl

class execute_in_coverage extends uvm_subscriber #(execute_tx);

  `uvm_component_utils(execute_in_coverage)

  execute_in_config m_config;    
  bit               m_is_covered;
  execute_tx        m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file execute_in.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file execute_in.tpl

  covergroup m_cov;
    option.per_instance = 1; 


    cp_data1_sign: coverpoint m_item.data1[31] {
      bins pos = {1'b0};
      bins neg = {1'b1};
    }
    cp_data2_sign: coverpoint m_item.data2[31] {
      bins pos = {1'b0};
      bins neg = {1'b1};
    }
    cp_imm_sign_zero: coverpoint {m_item.immediate_data[31], (m_item.immediate_data == 0)} {
      bins zero = {2'b01};
      bins pos  = {2'b00};
      bins neg  = {2'b10};
    }


    cp_pc_align: coverpoint m_item.pc_in[1:0] {
      bins aligned    = {2'b00};
      bins misaligned = default; 
    }


    cp_encoding: coverpoint m_item.control_in.encoding {
      bins none = {NONE_TYPE};
      bins r    = {R_TYPE};
      bins i    = {I_TYPE};
      bins s    = {S_TYPE};
      bins b    = {B_TYPE};
      bins u    = {U_TYPE};
      bins j    = {J_TYPE};
    }


    cp_alu_op: coverpoint m_item.control_in.alu_op {
      bins logic_ops[]  = {ALU_AND, ALU_OR, ALU_XOR};
      bins add_sub[]    = {ALU_ADD, ALU_SUB};
      bins set_ops[]    = {ALU_SLT, ALU_SLTU};
      bins shift_ops[]  = {ALU_SLL, ALU_SRL, ALU_SRA};
      bins lui          = {ALU_LUI};
      bins branch_ops[] = {B_BNE, B_BLT, B_BGE, B_LTU, B_GEU};
    }

    cp_alu_src: coverpoint m_item.control_in.alu_src;
    cp_is_branch: coverpoint m_item.control_in.is_branch;


    cp_mem_dir: coverpoint {m_item.control_in.mem_read, m_item.control_in.mem_write} {
      bins none  = {2'b00};
      bins load  = {2'b10};
      bins store = {2'b01};
      illegal_bins illegal = {2'b11};
    }

    cp_mem_size: coverpoint m_item.control_in.mem_size
      iff (m_item.control_in.mem_read || m_item.control_in.mem_write) {
      bins Byte = {2'b00};
      bins half = {2'b01};
      bins word = {2'b10};
    }

    cp_mem_sign: coverpoint m_item.control_in.mem_sign
      iff (m_item.control_in.mem_read);

    cp_mem_to_reg: coverpoint m_item.control_in.mem_to_reg
      iff (m_item.control_in.mem_read || m_item.control_in.mem_write);

    cp_reg_write: coverpoint m_item.control_in.reg_write;


    cross_encoding_mem:      cross cp_encoding,   cp_mem_dir;
    cross_encoding_alu_src:  cross cp_encoding,   cp_alu_src;
    cross_branch_type:       cross cp_encoding,   cp_is_branch;
    cross_mem_size_and_sign: cross cp_mem_size,   cp_mem_sign;
  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file execute_in.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input execute_tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file execute_in.tpl

endclass : execute_in_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file execute_in.tpl

function execute_in_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void execute_in_coverage::write(input execute_tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void execute_in_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(execute_in_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "execute_in config not found")
endfunction : build_phase


function void execute_in_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file execute_in.tpl

`endif // EXECUTE_IN_COVERAGE_SV
