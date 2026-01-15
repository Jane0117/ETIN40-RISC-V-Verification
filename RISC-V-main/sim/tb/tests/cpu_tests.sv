// cpu_tests.sv
class cpu_base_test extends uvm_test;
  `uvm_component_utils(cpu_base_test)
  cpu_env m_env; virtual uart_if uart_vif; virtual cpu_mon_if mon_vif;
  int unsigned max_cycles = 0; int unsigned drain_cycles = 20; bit timed_out; bit expect_indication = 1;
  bit run_flag_seen; bit run_finished_seen;
  bit append_sentinel = 1'b1;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); m_env = cpu_env::type_id::create("m_env", this); if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) `uvm_fatal(get_type_name(), "uart_vif not found") if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", mon_vif)) `uvm_fatal(get_type_name(), "cpu_mon_vif not found") endfunction
  virtual function void build_program(ref logic [31:0] prog[$]); prog = {}; endfunction
  function automatic bit is_bad_word(input logic [31:0] w);
    return (w == 32'h0000_1111) || (w[15:0] == 16'h1111) || (w[31:16] == 16'h1111);
  endfunction
  task run_phase(uvm_phase phase);
    uart_program_seq seq; logic [31:0] prog[$]; int unsigned max_cycles_arg;
    phase.raise_objection(this);
    wait (uart_vif.reset_n === 1'b1);
    wait (mon_vif.reset_n === 1'b1);
    repeat (5) @(posedge uart_vif.clk);
    build_program(prog);
    if ($value$plusargs("MAX_CYCLES=%d", max_cycles_arg)) max_cycles = max_cycles_arg; else if (max_cycles == 0) max_cycles = prog.size() * 40 + 2000;
    `uvm_info(get_type_name(), $sformatf("Program size: %0d words, max_cycles=%0d", prog.size(), max_cycles), UVM_LOW)
    seq = uart_program_seq::type_id::create("seq"); seq.program_words = prog; seq.append_sentinel = append_sentinel; seq.start(m_env.m_uart_agent.m_sequencer);
    fork
      begin
        wait (mon_vif.run_flag === 1'b1);
        run_flag_seen = 1;
        `uvm_info(get_type_name(), "run_flag asserted (sentinel observed)", UVM_LOW)
        repeat (drain_cycles) @(posedge uart_vif.clk);
      end
      begin
        wait (mon_vif.run_finished === 1'b1);
        run_finished_seen = 1;
        `uvm_info(get_type_name(), "run_finished asserted", UVM_LOW)
        repeat (drain_cycles) @(posedge uart_vif.clk);
      end
      begin
        repeat (max_cycles) @(posedge uart_vif.clk);
        timed_out = 1'b1;
        `uvm_warning(get_type_name(), "Timeout waiting for completion")
      end
    join_any; disable fork;
    if (!expect_indication && mon_vif.indication) `uvm_warning(get_type_name(), "indication asserted unexpectedly")
    if (expect_indication && !mon_vif.indication) `uvm_warning(get_type_name(), "indication not asserted when expected")
    if (!run_finished_seen) `uvm_warning(get_type_name(), "run_finished never toggled (using run_flag/drain to stop)")
    phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
    uvm_report_server rs; int errs; rs = uvm_report_server::get_server(); errs = rs.get_severity_count(UVM_ERROR);
    if (!timed_out && (errs == 0) && m_env.m_scoreboard.is_ok()) `uvm_info(get_type_name(), "TEST PASSED", UVM_NONE)
    else if (timed_out || mon_vif.indication || !m_env.m_scoreboard.is_ok() || errs != 0)
      `uvm_warning(get_type_name(), "TEST FAILED (see warnings/errors above)")
    else
      `uvm_info(get_type_name(), "TEST FAILED", UVM_NONE)
    if (m_env != null && m_env.m_coverage != null) begin
      cpu_coverage cov;
      cov = m_env.m_coverage;
      `uvm_info(get_type_name(),
        $sformatf("Coverage: issue=%0.2f%% wb=%0.2f%% store=%0.2f%% branch=%0.2f%% mem=%0.2f%% pipe=%0.2f%%",
          cov.issue_cg.get_inst_coverage(),
          cov.wb_cg.get_inst_coverage(),
          cov.store_cg.get_inst_coverage(),
          cov.branch_cg.get_inst_coverage(),
          cov.mem_cg.get_inst_coverage(),
          cov.pipe_cg.get_inst_coverage()),
        UVM_LOW)
      `uvm_info(get_type_name(), cov.format_instr_counts(), UVM_LOW)
    end
  endfunction
endclass

class cpu_smoke_test extends cpu_base_test;
  `uvm_component_utils(cpu_smoke_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 5000; endfunction

  virtual function void build_program(ref logic [31:0] prog[$]);
    // 单步验证：仅发送一条简单指令，便于观察 UART 装载是否正确
    prog = {};
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 5)); // addi x1, x0, 5
  endfunction
endclass

class cpu_mem_test extends cpu_base_test;
  `uvm_component_utils(cpu_mem_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 5000; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    int idx;
    prog = {};
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 0));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 8'h7f));
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd1, 5'd2, 0));
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd3, 5'd1, 0));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, -1));
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd1, 5'd2, 1));
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd4, 5'd1, 1));
    prog.push_back(encode_i(7'b0000011, 3'b100, 5'd5, 5'd1, 1));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd6, 5'd0, 12'h1AA));
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd1, 5'd6, 2));
    prog.push_back(encode_i(7'b0000011, 3'b001, 5'd7, 5'd1, 2));
    prog.push_back(encode_i(7'b0000011, 3'b101, 5'd8, 5'd1, 2));
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd1, 5'd6, 4));
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd9, 5'd1, 4));
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd1, 5'd2, 5));
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd10, 5'd1, 5));
  endfunction
endclass

class cpu_branch_test extends cpu_base_test;
  `uvm_component_utils(cpu_branch_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 8000; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    int imm; prog = {};
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 1));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 1));
    imm = calc_offset(2, 4); prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, imm));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd3, 5'd0, 3));
    imm = calc_offset(4, 6); prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, imm));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd4, 5'd0, 4));
    imm = calc_offset(6, 8); prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd2, imm));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 5));
    imm = calc_offset(8,10); prog.push_back(encode_b(7'b1100011, 3'b101, 5'd1, 5'd2, imm));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd6, 5'd0, 6));
    imm = calc_offset(10,12); prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd2, imm));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd7, 5'd0, 7));
    imm = calc_offset(12,14); prog.push_back(encode_b(7'b1100011, 3'b111, 5'd1, 5'd2, imm));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd8, 5'd0, 8));
    imm = calc_offset(14,16); prog.push_back(encode_j(7'b1101111, 5'd9, imm));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10, 5'd0, 10));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd11, 5'd0, 76));
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd11, 0));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd12, 5'd0, 12));
  endfunction
endclass

class cpu_compress_test extends cpu_base_test;
  `uvm_component_utils(cpu_compress_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 6000; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    int idx;
    prog = {};
    prog.push_back(32'h0020_0093);
    prog.push_back(32'h0593_4529);
    prog.push_back(32'h061d_0050);
    prog.push_back(32'h0030_0693);
    prog.push_back(32'h458d_9506);
    prog.push_back(32'h862a_8d0d);
    prog.push_back(32'h8909_8e69);
    prog.push_back(32'h8d35_8e49);
    prog.push_back(32'h0592_6595);
    prog.push_back(32'h0713_8591);
    prog.push_back(32'h8311_fff0);
    prog.push_back(32'h42d0_c2cc);
  endfunction
endclass

class cpu_hazard_test extends cpu_base_test;
  `uvm_component_utils(cpu_hazard_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 6000; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    prog = {};
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 5));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 8));
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd3, 5'd1, 5'd2));
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd4, 5'd3, 5'd1));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd7, 5'd0, 16'h55));
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd7, 0));
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd5, 5'd0, 0));
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd6, 5'd5, 5'd1));
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd8, 5'd6, 5'd2));
  endfunction
endclass

class cpu_random_alu_test extends cpu_base_test;
  `uvm_component_utils(cpu_random_alu_test)
  int instr_count = 50;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); int arg; super.build_phase(phase); if ($value$plusargs("RAND_COUNT=%d", arg)) instr_count = arg; max_cycles = 10000; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    int op; int rd, rs1, rs2; int imm; prog = {};
    for (int i = 0; i < instr_count; i++) begin
      op = $urandom_range(0, 5); rd = $urandom_range(1, 7); rs1 = $urandom_range(1, 7); rs2 = $urandom_range(1, 7);
      case (op)
        0: begin imm = $urandom_range(-16, 16); prog.push_back(encode_i(7'b0010011, 3'b000, rd[4:0], rs1[4:0], imm)); end
        1: prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
        2: prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, rd[4:0], rs1[4:0], rs2[4:0]));
        3: prog.push_back(encode_r(7'b0110011, 3'b100, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
        4: prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
        5: prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
        default: prog.push_back(encode_i(7'b0010011, 3'b000, rd[4:0], rs1[4:0], 0));
      endcase
    end
  endfunction
endclass

// Directed sweep to hit all RV32I opcode/funct3/funct7 combos and store/branch alignments
class cpu_opcode_sweep_test extends cpu_base_test;
  `uvm_component_utils(cpu_opcode_sweep_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 40000; expect_indication = 0; endfunction

  virtual function void build_program(ref logic [31:0] prog[$]);
    int idx;
    prog = {};

    // Base pointers and init data
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 4));   // x1=4
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 32));  // x2=0x20 base
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd3, 5'd0, 8));   // x3=8
    prog.push_back(encode_u(7'b0110111, 5'd4, 20'h12345));         // LUI
    prog.push_back(encode_u(7'b0010111, 5'd5, 20'h2));             // AUIPC

    // R-type (all funct3/funct7 combos)
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd6, 5'd1, 5'd2)); // add
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd7, 5'd6, 5'd1)); // sub
    prog.push_back(encode_r(7'b0110011, 3'b001, 7'b0000000, 5'd8, 5'd2, 5'd1)); // sll
    prog.push_back(encode_r(7'b0110011, 3'b010, 7'b0000000, 5'd9, 5'd4, 5'd3)); // slt
    prog.push_back(encode_r(7'b0110011, 3'b011, 7'b0000000, 5'd10,5'd4, 5'd3)); // sltu
    prog.push_back(encode_r(7'b0110011, 3'b100, 7'b0000000, 5'd11,5'd4, 5'd5)); // xor
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0000000, 5'd12,5'd4, 5'd1)); // srl
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0100000, 5'd13,5'd4, 5'd1)); // sra
    prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd14,5'd4, 5'd1)); // or
    prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd15,5'd4, 5'd1)); // and

    // I-type ALU (funct3 coverage + shift imm)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd16,5'd1, 5));        // addi
    prog.push_back(encode_i(7'b0010011, 3'b010, 5'd17,5'd3, 3));        // slti
    prog.push_back(encode_i(7'b0010011, 3'b011, 5'd18,5'd3, 1));        // sltiu
    prog.push_back(encode_i(7'b0010011, 3'b100, 5'd19,5'd4, 8'h55));    // xori
    prog.push_back(encode_i(7'b0010011, 3'b110, 5'd20,5'd1, 8'h2A));    // ori
    prog.push_back(encode_i(7'b0010011, 3'b111, 5'd21,5'd3, 8'h33));    // andi
    prog.push_back(encode_i(7'b0010011, 3'b001, 5'd22,5'd1, shift_imm(2,0))); // slli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd23,5'd4, shift_imm(3,0))); // srli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd24,5'd4, shift_imm(3,1))); // srai

    // Store patterns (alignments/sizes) writing to base 0x20
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd2, 5'd16, 0)); // sb base+0
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd2, 5'd17, 1)); // sb base+1
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd2, 5'd18, 3)); // sb base+3
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd2, 5'd19, 2)); // sh base+2
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd2, 5'd20, 4)); // sw base+4

    // Loads from initialized region
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd25,5'd2, 0)); // lb
    prog.push_back(encode_i(7'b0000011, 3'b100, 5'd26,5'd2, 0)); // lbu
    prog.push_back(encode_i(7'b0000011, 3'b001, 5'd27,5'd2, 2)); // lh
    prog.push_back(encode_i(7'b0000011, 3'b101, 5'd28,5'd2, 2)); // lhu
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd29,5'd2, 4)); // lw

    // Branches: taken/not-taken coverage for all funct3
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd1, calc_offset(idx, idx+2))); // beq taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd30,5'd0, 7));                        // skipped
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, 4));                        // bne not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd3, calc_offset(idx, idx+2)));  // blt taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd31,5'd0, 6));                        // skipped
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd3, 5'd1, 4));                        // bge not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd3, calc_offset(idx, idx+2)));  // bltu taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 5));                         // skipped
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd3, 5'd1, 4));                        // bgeu not taken

    // Jumps within program bounds
    idx = prog.size();
    prog.push_back(encode_j(7'b1101111, 5'd6, calc_offset(idx, idx+2))); // jal -> skip next
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd7, 5'd0, 3));         // skipped
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd2, 0));         // jalr x0, x2, 0

    // Pipe stress: dep and load-use
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd8, 5'd6, 1)); // dep chain
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd9, 5'd8, 0)); // load-use
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd10,5'd9,5'd8)); // add forwarding

    // Sentinel to stop (last word)
    prog.push_back(32'h00001111);
    for (int k = 0; k < prog.size() - 1; k++) begin
      if (is_bad_word(prog[k]))
        prog[k] = 32'h0000_0013;
    end
  endfunction
endclass

// ALU/Load/Store only (no branches/jumps) to isolate mismatches
class cpu_alu_mem_sweep_test extends cpu_base_test;
  `uvm_component_utils(cpu_alu_mem_sweep_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 20000; expect_indication = 0; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    prog = {};
    // Init base/data
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 4));   // x1=4
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 32));  // base=0x20
    prog.push_back(encode_u(7'b0110111, 5'd3, 20'h12345));         // lui
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd4, 5'd0, -1));  // x4=-1

    // R-type
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd5, 5'd1, 5'd2)); // add
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd6, 5'd5, 5'd1)); // sub
    prog.push_back(encode_r(7'b0110011, 3'b001, 7'b0000000, 5'd7, 5'd2, 5'd1)); // sll
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0000000, 5'd8, 5'd3, 5'd1)); // srl
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0100000, 5'd9, 5'd3, 5'd1)); // sra
    prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd10,5'd3, 5'd1)); // or
    prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd11,5'd3, 5'd1)); // and

    // I-type ALU
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd12,5'd1, 5));    // addi
    prog.push_back(encode_i(7'b0010011, 3'b100, 5'd13,5'd3, 8'h55));// xori
    prog.push_back(encode_i(7'b0010011, 3'b110, 5'd14,5'd1, 8'h2A));// ori
    prog.push_back(encode_i(7'b0010011, 3'b111, 5'd15,5'd4, 8'h33));// andi
    prog.push_back(encode_i(7'b0010011, 3'b001, 5'd16,5'd1, shift_imm(2,0))); // slli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd17,5'd3, shift_imm(3,0))); // srli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd18,5'd3, shift_imm(3,1))); // srai

    // Stores to base region (exercise all alignments for each size)
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd2, 5'd12, 0)); // sb offset0
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd2, 5'd13, 1)); // sb offset1
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd2, 5'd14, 2)); // sb offset2
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd2, 5'd15, 3)); // sb offset3
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd2, 5'd16, 0)); // sh offset0
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd2, 5'd17, 1)); // sh offset1
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd2, 5'd18, 2)); // sh offset2
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd2, 5'd12, 3)); // sh offset3
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd2, 5'd13, 0)); // sw offset0
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd2, 5'd14, 1)); // sw offset1
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd2, 5'd15, 2)); // sw offset2
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd2, 5'd16, 3)); // sw offset3

    // Loads from same region
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd19,5'd2, 0)); // lb
    prog.push_back(encode_i(7'b0000011, 3'b100, 5'd20,5'd2, 0)); // lbu
    prog.push_back(encode_i(7'b0000011, 3'b001, 5'd21,5'd2, 2)); // lh
    prog.push_back(encode_i(7'b0000011, 3'b101, 5'd22,5'd2, 2)); // lhu
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd23,5'd2, 4)); // lw

    // Sentinel
    prog.push_back(32'h00001111);
  endfunction
endclass

// Branch/JAL/JALR only
class cpu_branch_sweep_test extends cpu_base_test;
  `uvm_component_utils(cpu_branch_sweep_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 20000; expect_indication = 0; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    int idx;
    prog = {};
    // Init regs
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 1));   // x1=1
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 2));   // x2=2
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd3, 5'd0, -1));  // x3=-1
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd4, 5'd0, 3));   // x4=3
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 0));   // scratch

    // BEQ taken & not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd1, calc_offset(idx, idx+2))); // taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 1)); // skipped when taken
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, 8));  // not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 2));

    // BNE taken & not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, calc_offset(idx, idx+2))); // taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 3));
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd1, 8));  // not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 4));

    // BLT taken & not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd3, 5'd1, calc_offset(idx, idx+2))); // -1 < 1 => taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 5));
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd2, 5'd1, 8)); // 2 < 1 => not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 6));

    // BGE taken & not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd2, 5'd1, calc_offset(idx, idx+2))); // 2 >=1 => taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 7));
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd1, 5'd2, 8)); // 1>=2 => not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 8));

    // BLTU taken & not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd4, calc_offset(idx, idx+2))); // 1 < 3 unsigned => taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 9));
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd4, 5'd1, 8)); // 3 < 1 => not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 10));

    // BGEU taken & not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd4, 5'd1, calc_offset(idx, idx+2))); // 3 >=1 unsigned => taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 11));
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd1, 5'd4, 8)); // 1>=3 => not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd5, 12));

    // JAL within bounds, skip one
    prog.push_back(encode_j(7'b1101111, 5'd6, 8));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd7, 5'd0, 3)); // skipped

    // JALR to x1 base (0x0) within program
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd1, 0)); // jalr x0, x1, 0

    // Padding NOP-like (addi x0,x0,0) and sentinel
    prog.push_back(32'h00000013);
    prog.push_back(32'h00001111);
  endfunction
endclass

// Supported compressed subset sweep (only instr_decompressor-implemented C)
class cpu_compress_subset_test extends cpu_base_test;
  `uvm_component_utils(cpu_compress_subset_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 20000; expect_indication = 0; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    prog = {};
    // Encode compressed words directly (already 32-bit after decompress mapping in ref_model)
    // Use only supported C instructions: c.lw, c.sw, c.addi, c.jal, c.li, c.lui, c.srli, c.srai, c.andi,
    // c.sub/xor/or/and (CR), c.j, c.beqz, c.bnez, c.slli, c.jr, c.jalr, c.mv, c.add.

    // c.addi x8, +1
    prog.push_back(32'h00000013); // pre-nop for alignment
    prog.push_back(32'h00410013); // addi x2, x2, 4 (representing a compressed addi)
    // c.lw x9, 0(x8)  (maps to lw x9, offset on x8)
    prog.push_back(32'h00012483);
    // c.sw x9, 4(x8)
    prog.push_back(32'h00912023);
    // c.srli x9, x9, 1
    prog.push_back(32'h0014d493);
    // c.srai x9, x9, 1
    prog.push_back(32'h4014d493);
    // c.andi x9, 0x7
    prog.push_back(32'h0074e493);
    // c.sub x10, x9, x2
    prog.push_back(32'h4024c533);
    // c.xor x11, x9, x2
    prog.push_back(32'h0024c5b3);
    // c.or x12, x9, x2
    prog.push_back(32'h0024c633);
    // c.and x13, x9, x2
    prog.push_back(32'h0024c6b3);
    // c.j (jump forward)
    prog.push_back(encode_j(7'b1101111, 5'd0, 8)); // jal x0, +8
    // filler
    prog.push_back(32'h00000013);
    // c.beqz (x9 == 0? not taken)
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd9, 5'd0, 4));
    // c.bnez (x9 !=0? taken)
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd9, 5'd0, 4));
    // c.slli x9, x9, 1
    prog.push_back(32'h00149493);
    // c.jr x9 (to next)
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd9, 0));
    // c.jalr x9 (x1 gets return)
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd1, 5'd9, 0));
    // c.mv x10, x9
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd10,5'd0,5'd9));
    // c.add x10, x10, x2
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd10,5'd10,5'd2));

    // Sentinel
    prog.push_back(32'h00001111);
  endfunction
endclass

// Unified sweep over supported RV32I instructions (no unsupported compressed), aiming high coverage
class cpu_supported_full_test extends cpu_base_test;
  `uvm_component_utils(cpu_supported_full_test)
  bit skip_auipc = 0;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    int arg;
    super.build_phase(phase);
    max_cycles = 50000; expect_indication = 0;
    if ($value$plusargs("SKIP_AUIPC=%d", arg)) skip_auipc = arg;
  endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    int idx;
    prog = {};
    // Init regs
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 1));    // x1=1
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 2));    // x2=2
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd3, 5'd0, 3));    // x3=3
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd4, 5'd0, -1));   // x4=-1
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 32));   // x5=0x20 base
    prog.push_back(encode_u(7'b0110111, 5'd6, 20'h12345));          // x6 upper (positive)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd6, 5'd6, 12'h067)); // x6 final = 0x12345067

    // R-type
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd7, 5'd1, 5'd2)); // add
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd8, 5'd7, 5'd1)); // sub
    prog.push_back(encode_r(7'b0110011, 3'b001, 7'b0000000, 5'd9, 5'd2, 5'd1)); // sll
    prog.push_back(encode_r(7'b0110011, 3'b010, 7'b0000000, 5'd10,5'd3, 5'd4)); // slt
    prog.push_back(encode_r(7'b0110011, 3'b011, 7'b0000000, 5'd11,5'd3, 5'd2)); // sltu
    prog.push_back(encode_r(7'b0110011, 3'b100, 7'b0000000, 5'd12,5'd4, 5'd2)); // xor
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0000000, 5'd13,5'd6, 5'd1)); // srl
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0100000, 5'd14,5'd6, 5'd1)); // sra
    prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd15,5'd6, 5'd2)); // or
    prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd16,5'd6, 5'd3)); // and

    // I-type ALU
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd17,5'd1, 5));      // addi
    prog.push_back(encode_i(7'b0010011, 3'b010, 5'd18,5'd3, 2));      // slti
    prog.push_back(encode_i(7'b0010011, 3'b011, 5'd19,5'd3, 1));      // sltiu
    prog.push_back(encode_i(7'b0010011, 3'b100, 5'd20,5'd6, 8'h3C));  // xori
    prog.push_back(encode_i(7'b0010011, 3'b110, 5'd21,5'd6, 8'h0F));  // ori
    prog.push_back(encode_i(7'b0010011, 3'b111, 5'd22,5'd6, 8'hF0));  // andi
    prog.push_back(encode_i(7'b0010011, 3'b001, 5'd23,5'd6, shift_imm(3,0))); // slli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd24,5'd6, shift_imm(2,0))); // srli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd25,5'd6, shift_imm(2,1))); // srai

    // Stores to base region
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd5, 5'd6, 0)); // sb
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd5, 5'd6, 2)); // sh
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd5, 5'd6, 4)); // sw

    // Loads from same region
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd28,5'd5, 0)); // lb
    prog.push_back(encode_i(7'b0000011, 3'b100, 5'd29,5'd5, 0)); // lbu
    prog.push_back(encode_i(7'b0000011, 3'b001, 5'd30,5'd5, 2)); // lh
    prog.push_back(encode_i(7'b0000011, 3'b101, 5'd31,5'd5, 2)); // lhu
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd10,5'd5, 4)); // lw

    // Branches: taken/not-taken for all funct3
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd1, calc_offset(idx, idx+2))); // beq taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd11,5'd0, 7)); // skipped
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, 4)); // bne not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd4, 5'd1, calc_offset(idx, idx+2))); // blt taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd12,5'd0, 6)); // skipped
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd2, 5'd1, 4)); // bge not taken
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd3, calc_offset(idx, idx+2))); // bltu taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd13,5'd0, 5)); // skipped
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd3, 5'd1, 4)); // bgeu not taken

    // JAL / JALR within bounds
    idx = prog.size();
    prog.push_back(encode_j(7'b1101111, 5'd14, calc_offset(idx, idx+2))); // jal
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd15,5'd0, 3));         // skipped
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd5, 0));         // jalr x0, x5, 0

    // Padding and sentinel
    prog.push_back(32'h00000013);
    prog.push_back(32'h00001111);
  endfunction
endclass

// Random RV32I program generator (supported instr set), constrained for safe addresses
class cpu_rand_instr_test extends cpu_base_test;
  `uvm_component_utils(cpu_rand_instr_test)
  int rand_count = 50;
  int seed = 1;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    int arg;
    super.build_phase(phase);
    append_sentinel = 1'b0; // 随机用例自行添加结束标记，避免自动提前结束
    max_cycles = 60000; expect_indication = 0;
    if ($value$plusargs("RAND_COUNT=%d", arg)) rand_count = arg;
    if (rand_count > 150) rand_count = 150; // 限制随机指令条数，防止程序溢出
    if ($value$plusargs("SEED=%d", arg)) seed = arg;
  endfunction

  virtual function void build_program(ref logic [31:0] prog[$]);
    prog = {};
    // Init deterministic regs/base
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 1));   // x1=1
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 2));   // x2=2
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd3, 5'd0, 3));   // x3=3
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd4, 5'd0, -1));  // x4=-1
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 32));  // base=0x20
    prog.push_back(encode_u(7'b0110111, 5'd6, 20'h11111));         // pattern

    void'($urandom(seed));
    for (int i = 0; i < rand_count; i++) begin
      int op = $urandom_range(0,6);
      int rd = $urandom_range(1, 10);
      int rs1 = $urandom_range(1, 10);
      int rs2 = $urandom_range(1, 10);
      int imm12 = $urandom_range(-16, 16);
      int offset;

      case (op)
        0: begin // R-type ALU
          int f3 = $urandom_range(0,7);
          int f7 = (f3 == 3'b000 || f3 == 3'b101) ? $urandom_range(0,1) : 0;
          logic [6:0] funct7 = (f3==3'b000 && f7) ? 7'b0100000 :
                               (f3==3'b101 && f7) ? 7'b0100000 : 7'b0000000;
          prog.push_back(encode_r(7'b0110011, f3[2:0], funct7, rd[4:0], rs1[4:0], rs2[4:0]));
        end
        1: begin // I-type ALU
          int f3 = $urandom_range(0,7);
          if (f3 == 3'b101) imm12 = shift_imm($urandom_range(1,3), $urandom_range(0,1));
          if (f3 == 3'b001) imm12 = shift_imm($urandom_range(1,3), 0);
          prog.push_back(encode_i(7'b0010011, f3[2:0], rd[4:0], rs1[4:0], imm12));
        end
        2: begin // Load
          int load_lut [5] = '{0,1,2,4,5}; // lb/lh/lw/lbu/lhu
          int f3 = load_lut[$urandom_range(0,4)];
          offset = $urandom_range(0, 15); // cover all alignments
          prog.push_back(encode_i(7'b0000011, f3[2:0], rd[4:0], 5'd5, offset));
        end
        3: begin // Store
          int store_lut [3] = '{0,1,2};   // sb/sh/sw
          int f3 = store_lut[$urandom_range(0,2)];
          offset = $urandom_range(0, 15);
          prog.push_back(encode_s(7'b0100011, f3[2:0], 5'd5, rs2[4:0], offset));
        end
        4: begin // Branch (forward small offset)
          int branch_lut [6] = '{3'b000,3'b001,3'b100,3'b101,3'b110,3'b111};
          int f3 = branch_lut[$urandom_range(0,5)]; // beq/bne/blt/bge/bltu/bgeu
          int br_off = 8; // jump over two instr at most
          prog.push_back(encode_b(7'b1100011, f3[2:0], rs1[4:0], rs2[4:0], br_off));
        end
        5: begin // JAL forward (保证在存储深度内)
          prog.push_back(encode_j(7'b1101111, rd[4:0], 8));
        end
        6: begin // JALR
          prog.push_back(encode_i(7'b1100111, 3'b000, rd[4:0], 5'd5, 0));
        end
      endcase
    end

    // Sentinel to stop
    prog.push_back(32'h00001111);
    for (int k = 0; k < prog.size() - 1; k++) begin
      if (is_bad_word(prog[k]))
        prog[k] = 32'h0000_0013;
    end

    // 打印前几条随机生成的指令，便于确认发送内容
    for (int k = 0; k < prog.size() && k < 8; k++) begin
      `uvm_info(get_type_name(), $sformatf("prog[%0d]=0x%08h", k, prog[k]), UVM_LOW)
    end
  endfunction
endclass

// Full coverage-oriented test: mixes all instruction classes, optional compressed
class cpu_full_cov_test extends cpu_base_test;
  `uvm_component_utils(cpu_full_cov_test)
  int include_compress = 0; // default关闭压缩，单独用压缩用例验证
  bit skip_auipc = 0;

  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    int arg;
    super.build_phase(phase);
    max_cycles = 20000;
    if ($value$plusargs("INCLUDE_COMPRESS=%d", arg)) include_compress = arg;
    if ($value$plusargs("SKIP_AUIPC=%d", arg)) skip_auipc = arg;
  endfunction

  virtual function void build_program(ref logic [31:0] prog[$]);
    int idx;
    prog = {};

    // R-type ALU sweep
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd1, 5'd2, 5'd3)); // add
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd4, 5'd3, 5'd2)); // sub
    prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd5, 5'd4, 5'd3)); // and
    prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd6, 5'd4, 5'd3)); // or
    prog.push_back(encode_r(7'b0110011, 3'b100, 7'b0000000, 5'd7, 5'd4, 5'd3)); // xor
    prog.push_back(encode_r(7'b0110011, 3'b010, 7'b0000000, 5'd8, 5'd4, 5'd3)); // slt
    prog.push_back(encode_r(7'b0110011, 3'b011, 7'b0000000, 5'd9, 5'd3, 5'd4)); // sltu
    prog.push_back(encode_r(7'b0110011, 3'b001, 7'b0000000, 5'd10, 5'd4, 5'd3)); // sll
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0000000, 5'd11, 5'd4, 5'd3)); // srl
    prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0100000, 5'd12, 5'd4, 5'd3)); // sra

    // I-type ALU and shifts
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd13, 5'd0, 13));    // addi
    prog.push_back(encode_i(7'b0010011, 3'b100, 5'd14, 5'd13, 7));    // xori
    prog.push_back(encode_i(7'b0010011, 3'b110, 5'd15, 5'd13, 5));    // ori
    prog.push_back(encode_i(7'b0010011, 3'b111, 5'd16, 5'd13, 3));    // andi
    prog.push_back(encode_i(7'b0010011, 3'b001, 5'd17, 5'd13, shift_imm(1,0))); // slli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd18, 5'd13, shift_imm(1,0))); // srli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd19, 5'd13, shift_imm(1,1))); // srai

    // Stores known patterns first to avoid X from uninitialized data_mem, then load back
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd20, 5'd0, 8'h11));   // x20 = 0x11
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd21, 5'd0, 12'h223)); // x21 = 0x223
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd22, 5'd0, 12'h445)); // x22 = 0x445
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd20, 0));       // sb x20, 0(x0)
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd0, 5'd21, 2));       // sh x21, 2(x0)
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd22, 4));       // sw x22, 4(x0)
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd23, 5'd0, 0));       // lb  x23,0(x0)
    prog.push_back(encode_i(7'b0000011, 3'b001, 5'd24, 5'd0, 2));       // lh  x24,2(x0)
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd25, 5'd0, 4));       // lw  x25,4(x0)
    prog.push_back(encode_i(7'b0000011, 3'b100, 5'd26, 5'd0, 0));       // lbu x26,0(x0)
    prog.push_back(encode_i(7'b0000011, 3'b101, 5'd27, 5'd0, 2));       // lhu x27,2(x0)

    // Extra store alignment coverage on base x5
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd5, 5'd20, 1)); // sb misalign +1
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd5, 5'd21, 3)); // sb misalign +3
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd5, 5'd22, 1)); // sh misalign +1
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd5, 5'd23, 3)); // sh misalign +3
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd5, 5'd24, 1)); // sw misalign +1
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd5, 5'd25, 3)); // sw misalign +3

    // Branches (taken/not taken mix)
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // beq skip
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd25, 5'd0, 1));     // fall-through if not taken
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // bne taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd26, 5'd0, 2));     // skipped when taken

    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // blt
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd2, 5'd1, calc_offset( prog.size()+1, prog.size()+3 ))); // bge
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // bltu
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd2, 5'd1, calc_offset( prog.size()+1, prog.size()+3 ))); // bgeu

    // Branch supplement to cover taken/not for each funct3
    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd1, calc_offset(idx, idx+2))); // beq taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 9));
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, 8)); // beq not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 10));

    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, calc_offset(idx, idx+2))); // bne taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 11));
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd1, 8)); // bne not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 12));

    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd4, 5'd1, calc_offset(idx, idx+2))); // blt taken (-1 < 1)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 13));
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd2, 5'd1, 8)); // blt not taken (2 !< 1)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 14));

    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd2, 5'd1, calc_offset(idx, idx+2))); // bge taken (2>=1)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 15));
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd1, 5'd2, 8)); // bge not taken (1>=2 false)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 16));

    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd2, calc_offset(idx, idx+2))); // bltu taken (1<2)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 17));
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd2, 5'd1, 8)); // bltu not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 18));

    idx = prog.size();
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd2, 5'd1, calc_offset(idx, idx+2))); // bgeu taken (2>=1)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 19));
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd1, 5'd2, 8)); // bgeu not taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10,5'd0, 20));

    // Jumps
    prog.push_back(encode_j(7'b1101111, 5'd27, calc_offset(prog.size()+1, prog.size()+3))); // jal
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd27, 0)); // jalr to rd
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd28, 5'd0, 0)); // padding

    // U-type
    prog.push_back(encode_u(7'b0110111, 5'd29, 20'h1_2345)); // lui
    if (!skip_auipc)
      prog.push_back(encode_u(7'b0010111, 5'd30, 20'h0_0001)); // auipc

    // Optional compressed patterns (raw words); expectation: may raise indication if decompressor has issues
    if (include_compress) begin
      prog.push_back(32'h4593_4529); // example mixed comp/non-comp word
      prog.push_back(32'h42d0_c2cc); // example c.sw/c.lw pattern
    end
  endfunction

  function void report_phase(uvm_phase phase);
    cpu_coverage cov;
    super.report_phase(phase);
    cov = m_env.m_coverage;
    if (cov != null) begin
      `uvm_info(get_type_name(),
        $sformatf("Coverage: issue=%0.2f%% wb=%0.2f%% store=%0.2f%% branch=%0.2f%% mem=%0.2f%% pipe=%0.2f%%",
          cov.issue_cg.get_inst_coverage(),
          cov.wb_cg.get_inst_coverage(),
          cov.store_cg.get_inst_coverage(),
          cov.branch_cg.get_inst_coverage(),
          cov.mem_cg.get_inst_coverage(),
          cov.pipe_cg.get_inst_coverage()), UVM_LOW)
    end
  endfunction
endclass

// Convenience wrappers to separate压缩/非压缩用例，便于独立观察打印与覆盖率
class cpu_full_cov_nocompress_test extends cpu_full_cov_test;
  `uvm_component_utils(cpu_full_cov_nocompress_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    include_compress = 0;
    expect_indication = 1; // sentinel/非法指令可能拉高
  endfunction
endclass

class cpu_full_cov_compress_test extends cpu_full_cov_test;
  `uvm_component_utils(cpu_full_cov_compress_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    include_compress = 1;
    expect_indication = 1;
  endfunction
endclass
