// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: execute_in_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Sequence for agent execute_in
//=============================================================================

`ifndef EXECUTE_IN_SEQ_LIB_SV
`define EXECUTE_IN_SEQ_LIB_SV

class execute_in_default_seq extends uvm_sequence #(execute_tx);

  `uvm_object_utils(execute_in_default_seq)

  execute_in_config  m_config;

  extern function new(string name = "");
  extern task body();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : execute_in_default_seq


function execute_in_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task execute_in_default_seq::body();
  execute_tx req;
  // Encodings table for coverage-boost sweeps
  encoding_type enc_list_mem_dir[7] = '{NONE_TYPE, R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE};
  encoding_type enc_list_branch[6]  = '{NONE_TYPE, R_TYPE, I_TYPE, S_TYPE, U_TYPE, J_TYPE};

  // Cover a sweep of control/encoding modes to align with coverage goals
  string scenario_names[] = '{
    "r_type",
    "i_type_alu",
    "i_type_load_byte_s",
    "i_type_load_half_u",
    "i_type_load_word",
    "s_type_store_byte",
    "s_type_store_half",
    "s_type_store_word",
    "b_type_branch",
    "u_type_lui",
    "j_type_jump",
    "none_type_idle"
  };

  `uvm_info(get_type_name(), "Default sequence starting (encoding sweep)", UVM_HIGH)

  foreach (scenario_names[i]) begin
    bit ok;
    req = execute_tx::type_id::create($sformatf("req_%0d_%s", i, scenario_names[i]));
    start_item(req);

    case (i)
      // R-type: pure ALU, register operands
      0: ok = req.randomize() with {
           control_in.encoding == R_TYPE;
         };

      // I-type ALU (no memory)
      1: ok = req.randomize() with {
           control_in.encoding == I_TYPE;
           control_in.mem_read  == 1'b0;
         };

      // I-type LOAD variants to hit mem_size/sign bins
      2: ok = req.randomize() with {
           control_in.encoding  == I_TYPE;
           control_in.mem_read  == 1'b1;
           control_in.mem_size  == 2'b00; // byte
           control_in.mem_sign  == 1'b1;  // signed byte
         };

      3: ok = req.randomize() with {
           control_in.encoding  == I_TYPE;
           control_in.mem_read  == 1'b1;
           control_in.mem_size  == 2'b01; // halfword
           control_in.mem_sign  == 1'b0;  // unsigned halfword
         };

      4: ok = req.randomize() with {
           control_in.encoding  == I_TYPE;
           control_in.mem_read  == 1'b1;
           control_in.mem_size  == 2'b10; // word
         };

      // S-type STORE variants
      5: ok = req.randomize() with {
           control_in.encoding  == S_TYPE;
           control_in.mem_size  == 2'b00;
         };

      6: ok = req.randomize() with {
           control_in.encoding  == S_TYPE;
           control_in.mem_size  == 2'b01;
         };

      7: ok = req.randomize() with {
           control_in.encoding  == S_TYPE;
           control_in.mem_size  == 2'b10;
         };

      // Branch, upper-immediate, and jump encodings
      8: ok = req.randomize() with { control_in.encoding == B_TYPE; };
      9: ok = req.randomize() with { control_in.encoding == U_TYPE; };
      10: ok = req.randomize() with { control_in.encoding == J_TYPE; };

      // Explicit NONE_TYPE idle/default transaction
      default: ok = req.randomize() with {
                 control_in.encoding == NONE_TYPE;
                 control_in.mem_read  == 1'b0;
                 control_in.mem_write == 1'b0;
                 control_in.reg_write == 1'b0;
                 control_in.is_branch == 1'b0;
               };
    endcase

    if (!ok)
      `uvm_error(get_type_name(), $sformatf("Failed to randomize transaction %0d (%s)", i, scenario_names[i]))

    `uvm_info(get_type_name(),
              $sformatf("Seq push %0d (%s): enc=%0d mem_rd=%0b mem_wr=%0b size=%0b sign=%0b alu_op=%0d pc=0x%0h",
                        i, scenario_names[i], req.control_in.encoding, req.control_in.mem_read,
                        req.control_in.mem_write, req.control_in.mem_size, req.control_in.mem_sign,
                        req.control_in.alu_op, req.pc_in),
              UVM_HIGH)

    finish_item(req);
  end

  // Coverage boost transactions for hard-to-hit bins

  // imm=0 to hit cp_imm_sign_zero.zero & byte unsigned
  begin
    bit ok;
    req = execute_tx::type_id::create("req_cov_imm_zero_byte_u");
    start_item(req);
    ok = req.randomize() with {
      control_in.encoding  == I_TYPE;
      control_in.mem_read  == 1'b1;
      control_in.mem_size  == 2'b00;
    };
    req.immediate_data      = '0;
    req.control_in.mem_sign = 1'b0; // unsigned byte
    if (!ok) `uvm_error(get_type_name(), "Failed cov req_cov_imm_zero_byte_u")
    finish_item(req);
  end

  // halfword signed load to close cp_mem_size/sign cross
  begin
    bit ok;
    req = execute_tx::type_id::create("req_cov_half_signed");
    start_item(req);
    ok = req.randomize() with {
      control_in.encoding  == I_TYPE;
      control_in.mem_read  == 1'b1;
      control_in.mem_size  == 2'b01;
    };
    req.control_in.mem_sign = 1'b1;
    if (!ok) `uvm_error(get_type_name(), "Failed cov req_cov_half_signed")
    finish_item(req);
  end

  // Force I-type with alu_src=0 (normally 1) to fill cross_encoding_alu_src
  begin
    bit ok;
    req = execute_tx::type_id::create("req_cov_i_alu_src0");
    start_item(req);
    ok = req.randomize() with { control_in.encoding == I_TYPE; control_in.mem_read == 1'b0; };
    req.control_in.alu_src = 1'b0;
    if (!ok) `uvm_error(get_type_name(), "Failed cov req_cov_i_alu_src0")
    finish_item(req);
  end

  // Force S-type with alu_src=0 (normally 1) to fill cross_encoding_alu_src
  begin
    bit ok;
    req = execute_tx::type_id::create("req_cov_s_alu_src0");
    start_item(req);
    ok = req.randomize() with { control_in.encoding == S_TYPE; };
    req.control_in.alu_src = 1'b0;
    if (!ok) `uvm_error(get_type_name(), "Failed cov req_cov_s_alu_src0")
    finish_item(req);
  end

  // R-type with alu_src=1 (non-default) to hit remaining cross
  begin
    bit ok;
    req = execute_tx::type_id::create("req_cov_r_alu_src1");
    start_item(req);
    ok = req.randomize() with { control_in.encoding == R_TYPE; };
    req.control_in.alu_src = 1'b1;
    if (!ok) `uvm_error(get_type_name(), "Failed cov req_cov_r_alu_src1")
    finish_item(req);
  end

  // Cross mem_dir/encoding combinations (including otherwise unreachable) by manual overrides
  foreach (enc_list_mem_dir[idx]) begin
    encoding_type enc = enc_list_mem_dir[idx];

    // Load variant
    req = execute_tx::type_id::create($sformatf("req_cov_load_%0d", idx));
    start_item(req);
    if (!req.randomize() with { control_in.encoding == enc; }) begin
      `uvm_error(get_type_name(), $sformatf("Failed cov load randomize enc=%0d", enc))
    end
    req.control_in.mem_read   = 1'b1;
    req.control_in.mem_write  = 1'b0;
    req.control_in.mem_to_reg = 1'b1;
    req.control_in.mem_size   = 2'b10;
    req.control_in.is_branch  = (enc == B_TYPE) ? req.control_in.is_branch : 1'b0;
    finish_item(req);

    // Store variant
    req = execute_tx::type_id::create($sformatf("req_cov_store_%0d", idx));
    start_item(req);
    if (!req.randomize() with { control_in.encoding == enc; }) begin
      `uvm_error(get_type_name(), $sformatf("Failed cov store randomize enc=%0d", enc))
    end
    req.control_in.mem_read   = 1'b0;
    req.control_in.mem_write  = 1'b1;
    req.control_in.mem_to_reg = 1'b0;
    req.control_in.mem_size   = 2'b10;
    req.control_in.is_branch  = (enc == B_TYPE) ? req.control_in.is_branch : 1'b0;
    finish_item(req);
  end

  // Branch cross fill: toggle is_branch across encodings
  foreach (enc_list_branch[jdx]) begin
    req = execute_tx::type_id::create($sformatf("req_cov_branch_toggle_%0d", jdx));
    start_item(req);
    if (!req.randomize() with { control_in.encoding == enc_list_branch[jdx]; }) begin
      `uvm_error(get_type_name(), $sformatf("Failed cov branch_toggle enc=%0d", enc_list_branch[jdx]))
    end
    req.control_in.is_branch = 1'b1;
    finish_item(req);
  end

  // B-type with is_branch forced low (rare) to close remaining cross
  begin
    bit ok;
    req = execute_tx::type_id::create("req_cov_b_nonbranch");
    start_item(req);
    ok = req.randomize() with { control_in.encoding == B_TYPE; };
    req.control_in.is_branch = 1'b0;
    if (!ok) `uvm_error(get_type_name(), "Failed cov req_cov_b_nonbranch")
    finish_item(req);
  end

  `uvm_info(get_type_name(), "Default sequence completed (encoding sweep)", UVM_HIGH)
endtask : body


`ifndef UVM_POST_VERSION_1_1
function uvm_phase execute_in_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void execute_in_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting agent_seq_inc in file execute_in.tpl

`endif // EXECUTE_IN_SEQ_LIB_SV

