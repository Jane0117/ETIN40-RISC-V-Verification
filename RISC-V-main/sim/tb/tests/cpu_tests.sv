// cpu_tests.sv
class cpu_base_test extends uvm_test;
  `uvm_component_utils(cpu_base_test)
  cpu_env m_env; virtual uart_if uart_vif; virtual cpu_mon_if mon_vif;
  int unsigned max_cycles = 0; int unsigned drain_cycles = 20; bit timed_out; bit expect_indication = 1;
  bit run_flag_seen; bit run_finished_seen;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); m_env = cpu_env::type_id::create("m_env", this); if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) `uvm_fatal(get_type_name(), "uart_vif not found") if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", mon_vif)) `uvm_fatal(get_type_name(), "cpu_mon_vif not found") endfunction
  virtual function void build_program(ref logic [31:0] prog[$]); prog = {}; endfunction
  task run_phase(uvm_phase phase);
    uart_program_seq seq; logic [31:0] prog[$]; int unsigned max_cycles_arg;
    phase.raise_objection(this);
    wait (uart_vif.reset_n === 1'b1); repeat (5) @(posedge uart_vif.clk);
    build_program(prog);
    if ($value$plusargs("MAX_CYCLES=%d", max_cycles_arg)) max_cycles = max_cycles_arg; else if (max_cycles == 0) max_cycles = prog.size() * 40 + 2000;
    `uvm_info(get_type_name(), $sformatf("Program size: %0d words, max_cycles=%0d", prog.size(), max_cycles), UVM_LOW)
    seq = uart_program_seq::type_id::create("seq"); seq.program_words = prog; seq.append_sentinel = 1'b1; seq.start(m_env.m_uart_agent.m_sequencer);
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

// Full coverage-oriented test: mixes all instruction classes, optional compressed
class cpu_full_cov_test extends cpu_base_test;
  `uvm_component_utils(cpu_full_cov_test)
  int include_compress = 0; // default关闭压缩，单独用压缩用例验证

  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    int arg;
    super.build_phase(phase);
    max_cycles = 20000;
    if ($value$plusargs("INCLUDE_COMPRESS=%d", arg)) include_compress = arg;
  endfunction

  virtual function void build_program(ref logic [31:0] prog[$]);
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

    // Branches (taken/not taken mix)
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // beq skip
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd25, 5'd0, 1));     // fall-through if not taken
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // bne taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd26, 5'd0, 2));     // skipped when taken

    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // blt
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd2, 5'd1, calc_offset( prog.size()+1, prog.size()+3 ))); // bge
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // bltu
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd2, 5'd1, calc_offset( prog.size()+1, prog.size()+3 ))); // bgeu

    // Jumps
    prog.push_back(encode_j(7'b1101111, 5'd27, calc_offset(prog.size()+1, prog.size()+3))); // jal
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd27, 0)); // jalr to rd
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd28, 5'd0, 0)); // padding

    // U-type
    prog.push_back(encode_u(7'b0110111, 5'd29, 20'h1_2345)); // lui
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
