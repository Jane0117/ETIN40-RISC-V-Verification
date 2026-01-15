// // cpu_tests.sv
// class cpu_base_test extends uvm_test;
//   `uvm_component_utils(cpu_base_test)
//   cpu_env m_env; virtual uart_if uart_vif; virtual cpu_mon_if mon_vif;
//   int unsigned max_cycles = 0; int unsigned drain_cycles = 20; bit timed_out; bit expect_indication = 1;
//   bit run_flag_seen; bit run_finished_seen;
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); m_env = cpu_env::type_id::create("m_env", this); if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) `uvm_fatal(get_type_name(), "uart_vif not found") if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", mon_vif)) `uvm_fatal(get_type_name(), "cpu_mon_vif not found") endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]); prog = {}; endfunction
//   task run_phase(uvm_phase phase);
//     uart_program_seq seq; logic [31:0] prog[$]; int unsigned max_cycles_arg;
//     phase.raise_objection(this);
//     wait (uart_vif.reset_n === 1'b1); repeat (5) @(posedge uart_vif.clk);
//     build_program(prog);
//     if ($value$plusargs("MAX_CYCLES=%d", max_cycles_arg)) max_cycles = max_cycles_arg; else if (max_cycles == 0) max_cycles = prog.size() * 40 + 2000;
//     `uvm_info(get_type_name(), $sformatf("Program size: %0d words, max_cycles=%0d", prog.size(), max_cycles), UVM_LOW)
//     seq = uart_program_seq::type_id::create("seq"); seq.program_words = prog; seq.append_sentinel = 1'b1; seq.start(m_env.m_uart_agent.m_sequencer);
//     fork
//       begin
//         wait (mon_vif.run_flag === 1'b1);
//         run_flag_seen = 1;
//         `uvm_info(get_type_name(), "run_flag asserted (sentinel observed)", UVM_LOW)
//         repeat (drain_cycles) @(posedge uart_vif.clk);
//       end
//       begin
//         wait (mon_vif.run_finished === 1'b1);
//         run_finished_seen = 1;
//         `uvm_info(get_type_name(), "run_finished asserted", UVM_LOW)
//         repeat (drain_cycles) @(posedge uart_vif.clk);
//       end
//       begin
//         repeat (max_cycles) @(posedge uart_vif.clk);
//         timed_out = 1'b1;
//         `uvm_warning(get_type_name(), "Timeout waiting for completion")
//       end
//     join_any; disable fork;
//     if (!expect_indication && mon_vif.indication) `uvm_warning(get_type_name(), "indication asserted unexpectedly")
//     if (expect_indication && !mon_vif.indication) `uvm_warning(get_type_name(), "indication not asserted when expected")
//     if (!run_finished_seen) `uvm_warning(get_type_name(), "run_finished never toggled (using run_flag/drain to stop)")
//     phase.drop_objection(this);
//   endtask
//   function void report_phase(uvm_phase phase);
//     uvm_report_server rs; int errs; rs = uvm_report_server::get_server(); errs = rs.get_severity_count(UVM_ERROR);
//     if (!timed_out && (errs == 0) && m_env.m_scoreboard.is_ok()) `uvm_info(get_type_name(), "TEST PASSED", UVM_NONE)
//     else if (timed_out || mon_vif.indication || !m_env.m_scoreboard.is_ok() || errs != 0)
//       `uvm_warning(get_type_name(), "TEST FAILED (see warnings/errors above)")
//     else
//       `uvm_info(get_type_name(), "TEST FAILED", UVM_NONE)
//   endfunction
// endclass

// class cpu_smoke_test extends cpu_base_test;
//   `uvm_component_utils(cpu_smoke_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 5000; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     // 单步验证：仅发送一条简单指令，便于观察 UART 装载是否正确
//     prog = {};
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 5)); // addi x1, x0, 5
//   endfunction
// endclass

// class cpu_mem_test extends cpu_base_test;
//   `uvm_component_utils(cpu_mem_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 5000; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     prog = {};
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 0));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 8'h7f));
//     prog.push_back(encode_s(7'b0100011, 3'b000, 5'd1, 5'd2, 0));
//     prog.push_back(encode_i(7'b0000011, 3'b000, 5'd3, 5'd1, 0));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, -1));
//     prog.push_back(encode_s(7'b0100011, 3'b000, 5'd1, 5'd2, 1));
//     prog.push_back(encode_i(7'b0000011, 3'b000, 5'd4, 5'd1, 1));
//     prog.push_back(encode_i(7'b0000011, 3'b100, 5'd5, 5'd1, 1));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd6, 5'd0, 12'h1AA));
//     prog.push_back(encode_s(7'b0100011, 3'b001, 5'd1, 5'd6, 2));
//     prog.push_back(encode_i(7'b0000011, 3'b001, 5'd7, 5'd1, 2));
//     prog.push_back(encode_i(7'b0000011, 3'b101, 5'd8, 5'd1, 2));
//     prog.push_back(encode_s(7'b0100011, 3'b010, 5'd1, 5'd6, 4));
//     prog.push_back(encode_i(7'b0000011, 3'b010, 5'd9, 5'd1, 4));
//     prog.push_back(encode_s(7'b0100011, 3'b010, 5'd1, 5'd2, 5));
//     prog.push_back(encode_i(7'b0000011, 3'b010, 5'd10, 5'd1, 5));
//   endfunction
// endclass

// class cpu_branch_test extends cpu_base_test;
//   `uvm_component_utils(cpu_branch_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 8000; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     int imm; prog = {};
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 1));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 1));
//     imm = calc_offset(2, 4); prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, imm));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd3, 5'd0, 3));
//     imm = calc_offset(4, 6); prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, imm));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd4, 5'd0, 4));
//     imm = calc_offset(6, 8); prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd2, imm));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 5));
//     imm = calc_offset(8,10); prog.push_back(encode_b(7'b1100011, 3'b101, 5'd1, 5'd2, imm));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd6, 5'd0, 6));
//     imm = calc_offset(10,12); prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd2, imm));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd7, 5'd0, 7));
//     imm = calc_offset(12,14); prog.push_back(encode_b(7'b1100011, 3'b111, 5'd1, 5'd2, imm));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd8, 5'd0, 8));
//     imm = calc_offset(14,16); prog.push_back(encode_j(7'b1101111, 5'd9, imm));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10, 5'd0, 10));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd11, 5'd0, 76));
//     prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd11, 0));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd12, 5'd0, 12));
//   endfunction
// endclass

// class cpu_compress_test extends cpu_base_test;
//   `uvm_component_utils(cpu_compress_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 6000; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     prog = {};
//     prog.push_back(32'h0020_0093);
//     prog.push_back(32'h0593_4529);
//     prog.push_back(32'h061d_0050);
//     prog.push_back(32'h0030_0693);
//     prog.push_back(32'h458d_9506);
//     prog.push_back(32'h862a_8d0d);
//     prog.push_back(32'h8909_8e69);
//     prog.push_back(32'h8d35_8e49);
//     prog.push_back(32'h0592_6595);
//     prog.push_back(32'h0713_8591);
//     prog.push_back(32'h8311_fff0);
//     prog.push_back(32'h42d0_c2cc);
//   endfunction
// endclass

// class cpu_hazard_test extends cpu_base_test;
//   `uvm_component_utils(cpu_hazard_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 6000; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     prog = {};
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 5));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 8));
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd3, 5'd1, 5'd2));
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd4, 5'd3, 5'd1));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd7, 5'd0, 16'h55));
//     prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd7, 0));
//     prog.push_back(encode_i(7'b0000011, 3'b010, 5'd5, 5'd0, 0));
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd6, 5'd5, 5'd1));
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd8, 5'd6, 5'd2));
//   endfunction
// endclass

// class cpu_random_alu_test extends cpu_base_test;
//   `uvm_component_utils(cpu_random_alu_test)
//   int instr_count = 50;
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); int arg; super.build_phase(phase); if ($value$plusargs("RAND_COUNT=%d", arg)) instr_count = arg; max_cycles = 10000; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     int op; int rd, rs1, rs2; int imm; prog = {};
//     for (int i = 0; i < instr_count; i++) begin
//       op = $urandom_range(0, 5); rd = $urandom_range(1, 7); rs1 = $urandom_range(1, 7); rs2 = $urandom_range(1, 7);
//       case (op)
//         0: begin imm = $urandom_range(-16, 16); prog.push_back(encode_i(7'b0010011, 3'b000, rd[4:0], rs1[4:0], imm)); end
//         1: prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
//         2: prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, rd[4:0], rs1[4:0], rs2[4:0]));
//         3: prog.push_back(encode_r(7'b0110011, 3'b100, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
//         4: prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
//         5: prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, rd[4:0], rs1[4:0], rs2[4:0]));
//         default: prog.push_back(encode_i(7'b0010011, 3'b000, rd[4:0], rs1[4:0], 0));
//       endcase
//     end
//   endfunction
// endclass

// // Full coverage-oriented test: mixes all instruction classes, optional compressed
// class cpu_full_cov_test extends cpu_base_test;
//   `uvm_component_utils(cpu_full_cov_test)
//   int include_compress = 0; // default关闭压缩，单独用压缩用例验证

//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase);
//     int arg;
//     super.build_phase(phase);
//     max_cycles = 20000;
//     if ($value$plusargs("INCLUDE_COMPRESS=%d", arg)) include_compress = arg;
//   endfunction

//   virtual function void build_program(ref logic [31:0] prog[$]);
//     prog = {};

//     // R-type ALU sweep
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd1, 5'd2, 5'd3)); // add
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd4, 5'd3, 5'd2)); // sub
//     prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd5, 5'd4, 5'd3)); // and
//     prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd6, 5'd4, 5'd3)); // or
//     prog.push_back(encode_r(7'b0110011, 3'b100, 7'b0000000, 5'd7, 5'd4, 5'd3)); // xor
//     prog.push_back(encode_r(7'b0110011, 3'b010, 7'b0000000, 5'd8, 5'd4, 5'd3)); // slt
//     prog.push_back(encode_r(7'b0110011, 3'b011, 7'b0000000, 5'd9, 5'd3, 5'd4)); // sltu
//     prog.push_back(encode_r(7'b0110011, 3'b001, 7'b0000000, 5'd10, 5'd4, 5'd3)); // sll
//     prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0000000, 5'd11, 5'd4, 5'd3)); // srl
//     prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0100000, 5'd12, 5'd4, 5'd3)); // sra

//     // I-type ALU and shifts
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd13, 5'd0, 13));    // addi
//     prog.push_back(encode_i(7'b0010011, 3'b100, 5'd14, 5'd13, 7));    // xori
//     prog.push_back(encode_i(7'b0010011, 3'b110, 5'd15, 5'd13, 5));    // ori
//     prog.push_back(encode_i(7'b0010011, 3'b111, 5'd16, 5'd13, 3));    // andi
//     prog.push_back(encode_i(7'b0010011, 3'b001, 5'd17, 5'd13, shift_imm(1,0))); // slli
//     prog.push_back(encode_i(7'b0010011, 3'b101, 5'd18, 5'd13, shift_imm(1,0))); // srli
//     prog.push_back(encode_i(7'b0010011, 3'b101, 5'd19, 5'd13, shift_imm(1,1))); // srai

//     // Stores known patterns first to avoid X from uninitialized data_mem, then load back
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd20, 5'd0, 8'h11));   // x20 = 0x11
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd21, 5'd0, 12'h223)); // x21 = 0x223
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd22, 5'd0, 12'h445)); // x22 = 0x445
//     prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd20, 0));       // sb x20, 0(x0)
//     prog.push_back(encode_s(7'b0100011, 3'b001, 5'd0, 5'd21, 2));       // sh x21, 2(x0)
//     prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd22, 4));       // sw x22, 4(x0)
//     prog.push_back(encode_i(7'b0000011, 3'b000, 5'd23, 5'd0, 0));       // lb  x23,0(x0)
//     prog.push_back(encode_i(7'b0000011, 3'b001, 5'd24, 5'd0, 2));       // lh  x24,2(x0)
//     prog.push_back(encode_i(7'b0000011, 3'b010, 5'd25, 5'd0, 4));       // lw  x25,4(x0)
//     prog.push_back(encode_i(7'b0000011, 3'b100, 5'd26, 5'd0, 0));       // lbu x26,0(x0)
//     prog.push_back(encode_i(7'b0000011, 3'b101, 5'd27, 5'd0, 2));       // lhu x27,2(x0)

//     // Branches (taken/not taken mix)
//     prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // beq skip
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd25, 5'd0, 1));     // fall-through if not taken
//     prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // bne taken
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd26, 5'd0, 2));     // skipped when taken

//     prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // blt
//     prog.push_back(encode_b(7'b1100011, 3'b101, 5'd2, 5'd1, calc_offset( prog.size()+1, prog.size()+3 ))); // bge
//     prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd2, calc_offset( prog.size()+1, prog.size()+3 ))); // bltu
//     prog.push_back(encode_b(7'b1100011, 3'b111, 5'd2, 5'd1, calc_offset( prog.size()+1, prog.size()+3 ))); // bgeu

//     // Jumps
//     prog.push_back(encode_j(7'b1101111, 5'd27, calc_offset(prog.size()+1, prog.size()))); // jal去掉了+3
//     prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd27, 0)); // jalr to rd
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd28, 5'd0, 0)); // padding

//     // U-type
//     prog.push_back(encode_u(7'b0110111, 5'd29, 20'h1_2345)); // lui
//     prog.push_back(encode_u(7'b0010111, 5'd30, 20'h0_0001)); // auipc

//     // Optional compressed patterns (raw words); expectation: may raise indication if decompressor has issues
//     if (include_compress) begin
//       // 早期确保压缩取到：两条压缩半字
//       prog.push_back(32'h0001_0001); // c.nop | c.nop
//       prog.push_back(32'h0002_0002); // 压缩半字
//       // 合法压缩/非压缩混合
//       prog.push_back(32'h4593_4529); // example mixed comp/non-comp word
//       prog.push_back(32'h42d0_c2cc); // example c.sw/c.lw pattern
//       // 压缩+正常、压缩+压缩组合
//       prog.push_back(32'hE003_6101); // low: compressed, high: normal
//       prog.push_back(32'h8000_6101); // low: compressed, high: compressed
//       // 非法压缩半字，触发解压失败
//       prog.push_back(32'h0000_0000);
//     end
//   endfunction

//   function void report_phase(uvm_phase phase);
//     cpu_coverage cov;
//     super.report_phase(phase);
//     cov = m_env.m_coverage;
//     if (cov != null) begin
//       `uvm_info(get_type_name(),
//         $sformatf("Coverage: issue=%0.2f%% wb=%0.2f%% store=%0.2f%% branch=%0.2f%% mem=%0.2f%% pipe=%0.2f%%",
//           cov.issue_cg.get_inst_coverage(),
//           cov.wb_cg.get_inst_coverage(),
//           cov.store_cg.get_inst_coverage(),
//           cov.branch_cg.get_inst_coverage(),
//           cov.mem_cg.get_inst_coverage(),
//           cov.pipe_cg.get_inst_coverage()), UVM_LOW)
//     end
//   endfunction
// endclass

// // Convenience wrappers to separate压缩/非压缩用例，便于独立观察打印与覆盖率
// class cpu_full_cov_nocompress_test extends cpu_full_cov_test;
//   `uvm_component_utils(cpu_full_cov_nocompress_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     include_compress = 0;
//     expect_indication = 1; // sentinel/非法指令可能拉高
//   endfunction
// endclass

// class cpu_full_cov_compress_test extends cpu_full_cov_test;
//   `uvm_component_utils(cpu_full_cov_compress_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     include_compress = 1;
//     expect_indication = 1;
//   endfunction
// endclass

// // 补齐 opcode 空洞：J/JALR/LUI/AUIPC/非法压缩标志
// class cpu_opcode_gap_test extends cpu_base_test;
//   `uvm_component_utils(cpu_opcode_gap_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 8000; expect_indication = 0; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     prog = {};
//     prog.push_back(encode_u(7'b0110111, 5'd1, 20'h00100));     // LUI
//     prog.push_back(encode_u(7'b0010111, 5'd2, 20'h00010));     // AUIPC
//     prog.push_back(encode_j(7'b1101111, 5'd3, 4));             // JAL (fall-through still samples)
//     prog.push_back(encode_i(7'b1100111, 3'b000, 5'd4, 5'd3, 0));// JALR
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 1));// ADDI padding
//     prog.push_back(32'h0000_0000);                             // 非法压缩半字，触发解压失败覆盖
//   endfunction
// endclass

// // 补全未覆盖 opcode/funct3/funct7/load/forward 分支的定向用例
// class cpu_cov_gap2_test extends cpu_base_test;
//   `uvm_component_utils(cpu_cov_gap2_test)
//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 12000; expect_indication = 0; endfunction
//   virtual function void build_program(ref logic [31:0] prog[$]);
//     prog = {};
//     // U type
//     prog.push_back(encode_u(7'b0110111, 5'd1, 20'h1_0000)); // LUI
//     prog.push_back(encode_u(7'b0010111, 5'd2, 20'h0_0008)); // AUIPC
//     // Jumps
//     prog.push_back(encode_j(7'b1101111, 5'd3, 8));          // JAL (skip next)
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // padding
//     prog.push_back(encode_i(7'b1100111, 3'b000, 5'd4, 5'd3, 0)); // JALR
//     // R-type with funct7[5]=1 to hit cp_funct7b5.one
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd5, 5'd1, 5'd2)); // SUB
//     prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd6, 5'd1, 5'd2)); // OR  (funct3=6)
//     prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd7, 5'd1, 5'd2)); // AND (funct3=7)
//     // I-ALU
//     prog.push_back(encode_i(7'b0010011, 3'b100, 5'd8, 5'd1, 5)); // XORI
//     // Loads of different sizes -> cp_load/load_size_cross
//     prog.push_back(encode_i(7'b0000011, 3'b000, 5'd9, 5'd0, 0));  // LB
//     prog.push_back(encode_i(7'b0000011, 3'b001, 5'd10,5'd0, 2));  // LH
//     prog.push_back(encode_i(7'b0000011, 3'b010, 5'd11,5'd0, 4));  // LW
//     // Stores (align variations already in other tests)
//     prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd9, 6));  // SB
//     // Branch taken/not taken to exercise predictor/mispredict
//     prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd1, 8));  // BEQ taken
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd12,5'd0, 0));  // nop (skipped)
//     prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, -8)); // BNE not taken
//     // Forwarding chain: EX and MEM hazards
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd13,5'd0, 5));   // x13 = 5
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd14,5'd13,5'd1)); // add -> forward EX
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd15,5'd14,5'd2)); // add -> forward MEM
//   endfunction
// endclass
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
// class cpu_full_cov_test extends cpu_base_test;
//   `uvm_component_utils(cpu_full_cov_test)
//   int include_compress = 0; // default关闭压缩，单独用压缩用例验证

//   function new(string name, uvm_component parent); super.new(name, parent); endfunction
//   function void build_phase(uvm_phase phase);
//     int arg;
//     super.build_phase(phase);
//     max_cycles = 20000;
//     if ($value$plusargs("INCLUDE_COMPRESS=%d", arg)) include_compress = arg;
//   endfunction

//  virtual function void build_program(ref logic [31:0] prog[$]);
//     prog = {};

//     // ==========================================
//     // 1. R-type ALU sweep
//     // ==========================================
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd1, 5'd2, 5'd3)); // add
//     prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd4, 5'd3, 5'd2)); // sub
//     prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd5, 5'd4, 5'd3)); // and
//     prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd6, 5'd4, 5'd3)); // or
//     prog.push_back(encode_r(7'b0110011, 3'b100, 7'b0000000, 5'd7, 5'd4, 5'd3)); // xor
//     prog.push_back(encode_r(7'b0110011, 3'b010, 7'b0000000, 5'd8, 5'd4, 5'd3)); // slt
//     prog.push_back(encode_r(7'b0110011, 3'b011, 7'b0000000, 5'd9, 5'd3, 5'd4)); // sltu
//     prog.push_back(encode_r(7'b0110011, 3'b001, 7'b0000000, 5'd10, 5'd4, 5'd3)); // sll
//     prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0000000, 5'd11, 5'd4, 5'd3)); // srl
//     prog.push_back(encode_r(7'b0110011, 3'b101, 7'b0100000, 5'd12, 5'd4, 5'd3)); // sra

//     // ==========================================
//     // 2. I-type ALU and shifts (关键修复区域)
//     // ==========================================
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd13, 5'd0, 13));    // addi
//     prog.push_back(encode_i(7'b0010011, 3'b100, 5'd14, 5'd13, 7));    // xori
//     prog.push_back(encode_i(7'b0010011, 3'b110, 5'd15, 5'd13, 5));    // ori
//     prog.push_back(encode_i(7'b0010011, 3'b111, 5'd16, 5'd13, 3));    // andi

//     // [修复1] 显式添加 SLLI (funct3=001) -> 覆盖 <alu, bin_half>
//     // 手动硬编码 immediate，不依赖 shift_imm 函数，确保万无一失
//     prog.push_back(encode_i(7'b0010011, 3'b001, 5'd17, 5'd13, 1));    // SLLI x17, x13, 1

//     // [修复2] 显式添加 SLTI (funct3=010) -> 覆盖 <alu, bin_word>
//     prog.push_back(encode_i(7'b0010011, 3'b010, 5'd20, 5'd13, 15));   // SLTI x20, x13, 15

//     // [修复3] 显式添加 SLTIU (funct3=011) -> 补全覆盖率
//     prog.push_back(encode_i(7'b0010011, 3'b011, 5'd21, 5'd13, 10));   // SLTIU x21, x13, 10

//     prog.push_back(encode_i(7'b0010011, 3'b101, 5'd18, 5'd13, shift_imm(1,0))); // srli
//     prog.push_back(encode_i(7'b0010011, 3'b101, 5'd19, 5'd13, shift_imm(1,1))); // srai

//     // ==========================================
//     // 3. Stores & Loads
//     // ==========================================
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd20, 5'd0, 8'h11));   // x20 = 0x11
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd21, 5'd0, 12'h223)); // x21 = 0x223
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd22, 5'd0, 12'h445)); // x22 = 0x445
//     prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd20, 0));       // sb
//     prog.push_back(encode_s(7'b0100011, 3'b001, 5'd0, 5'd21, 2));       // sh
//     prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd22, 4));       // sw
//     prog.push_back(encode_i(7'b0000011, 3'b000, 5'd23, 5'd0, 0));       // lb
//     prog.push_back(encode_i(7'b0000011, 3'b001, 5'd24, 5'd0, 2));       // lh
//     prog.push_back(encode_i(7'b0000011, 3'b010, 5'd25, 5'd0, 4));       // lw
//     prog.push_back(encode_i(7'b0000011, 3'b100, 5'd26, 5'd0, 0));       // lbu
//     prog.push_back(encode_i(7'b0000011, 3'b101, 5'd27, 5'd0, 2));       // lhu

//     // ==========================================
//     // 4. Branches (偏移量修复版)
//     // ==========================================
//     // 初始化比较寄存器
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 1)); // x1 = 1
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 2)); // x2 = 2

//     // BEQ (Not Taken) -> calc_offset(current, target) -> 正数偏移
//     prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, calc_offset( prog.size(), prog.size()+2 ))); 
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

//     // BNE (Taken)
//     prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, calc_offset( prog.size(), prog.size()+2 ))); 
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

//     // BLT (Taken)
//     prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd2, calc_offset( prog.size(), prog.size()+2 )));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

//     // BGE (Not Taken)
//     prog.push_back(encode_b(7'b1100011, 3'b101, 5'd1, 5'd2, calc_offset( prog.size(), prog.size()+2 )));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

//     // BLTU (Taken)
//     prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd2, calc_offset( prog.size(), prog.size()+2 )));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

//     // BGEU (Not Taken)
//     prog.push_back(encode_b(7'b1100011, 3'b111, 5'd1, 5'd2, calc_offset( prog.size(), prog.size()+2 )));
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding


//     // ==========================================
//     // 5. Jumps (JALR死循环修复版)
//     // ==========================================
    
//     // JAL x27, offset
//     prog.push_back(encode_j(7'b1101111, 5'd27, calc_offset(prog.size(), prog.size()+2))); 
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

//     // 关键修正：ADDI x27, x27, 12
//     // JALR 将跳到 (x27 + 12) 的位置，即跳过 JALR 自己
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd27, 5'd27, 12)); 

//     // JALR x0, 0(x27)
//     prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd27, 0)); 
    
//     // Target Padding (Landed here)
//     prog.push_back(encode_i(7'b0010011, 3'b000, 5'd28, 5'd0, 0)); 

//     // ==========================================
//     // 6. U-type
//     // ==========================================
//     prog.push_back(encode_u(7'b0110111, 5'd29, 20'h1_2345)); // lui
//     prog.push_back(encode_u(7'b0010111, 5'd30, 20'h0_0001)); // auipc

//     // Optional Compressed
//     if (include_compress) begin
//       prog.push_back(32'h0001_0001); // c.nop
//       prog.push_back(32'h0002_0002);
//       prog.push_back(32'h4593_4529);
//       prog.push_back(32'h42d0_c2cc);
//       prog.push_back(32'hE003_6101);
//       prog.push_back(32'h8000_6101);
//       prog.push_back(32'h0000_0000); // illegal
//     end
//   endfunction

//   function void report_phase(uvm_phase phase);
//     cpu_coverage cov;
//     super.report_phase(phase);
//     cov = m_env.m_coverage;
//     if (cov != null) begin
//       `uvm_info(get_type_name(),
//         $sformatf("Coverage: issue=%0.2f%% wb=%0.2f%% store=%0.2f%% branch=%0.2f%% mem=%0.2f%% pipe=%0.2f%%",
//           cov.issue_cg.get_inst_coverage(),
//           cov.wb_cg.get_inst_coverage(),
//           cov.store_cg.get_inst_coverage(),
//           cov.branch_cg.get_inst_coverage(),
//           cov.mem_cg.get_inst_coverage(),
//           cov.pipe_cg.get_inst_coverage()), UVM_LOW)
//     end
//   endfunction
// endclass
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

    // ==========================================
    // 1. R-type ALU sweep
    // ==========================================
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

    // ==========================================
    // 2. I-type ALU and shifts
    // ==========================================
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd13, 5'd0, 13));    // addi
    prog.push_back(encode_i(7'b0010011, 3'b100, 5'd14, 5'd13, 7));    // xori
    prog.push_back(encode_i(7'b0010011, 3'b110, 5'd15, 5'd13, 5));    // ori
    prog.push_back(encode_i(7'b0010011, 3'b111, 5'd16, 5'd13, 3));    // andi

    // [修复1] 显式添加 SLLI (funct3=001)
    prog.push_back(encode_i(7'b0010011, 3'b001, 5'd17, 5'd13, 1));    // SLLI x17, x13, 1

    // [修复2] 显式添加 SLTI (funct3=010)
    prog.push_back(encode_i(7'b0010011, 3'b010, 5'd20, 5'd13, 15));   // SLTI x20, x13, 15

    // [修复3] 显式添加 SLTIU (funct3=011)
    prog.push_back(encode_i(7'b0010011, 3'b011, 5'd21, 5'd13, 10));   // SLTIU x21, x13, 10

    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd18, 5'd13, shift_imm(1,0))); // srli
    prog.push_back(encode_i(7'b0010011, 3'b101, 5'd19, 5'd13, shift_imm(1,1))); // srai

    // ==========================================
    // 3. Stores & Loads (关键修复区域：全覆盖版)
    // ==========================================
    // 初始化数据
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd20, 5'd0, 8'h11));   // x20 = 0x11
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd21, 5'd0, 12'h223)); // x21 = 0x223
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd22, 5'd0, 12'h445)); // x22 = 0x445

    // [SB] Store Byte: 必须覆盖所有地址偏移 (00, 01, 10, 11)
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd20, 0)); // SB @ 0 (b0)
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd20, 1)); // SB @ 1 (b1) -> [新增] 覆盖 <bin_byte, b1>
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd20, 2)); // SB @ 2 (b2) -> [新增] 覆盖 <bin_byte, b2>
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd20, 3)); // SB @ 3 (b3) -> [新增] 覆盖 <bin_byte, b3>

    // [SH] Store Half: 尝试对齐和非对齐
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd0, 5'd21, 0)); // SH @ 0 (b0) -> [新增]
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd0, 5'd21, 1)); // SH @ 1 (b1) -> [新增] 覆盖 <bin_half, b1>
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd0, 5'd21, 2)); // SH @ 2 (b2) -> 已有
    prog.push_back(encode_s(7'b0100011, 3'b001, 5'd0, 5'd21, 3)); // SH @ 3 (b3) -> [新增] 覆盖 <bin_half, b3>

    // [SW] Store Word: 尝试对齐和非对齐
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd22, 0)); // SW @ 0 (b0) -> [新增]
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd22, 1)); // SW @ 1 (b1) -> [新增] 覆盖 <bin_word, b1>
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd22, 2)); // SW @ 2 (b2) -> [新增] 覆盖 <bin_word, b2>
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd22, 3)); // SW @ 3 (b3) -> [新增] 覆盖 <bin_word, b3>

    // Loads (Load指令通常不测非对齐异常，维持原样即可)
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd23, 5'd0, 0));       // lb
    prog.push_back(encode_i(7'b0000011, 3'b001, 5'd24, 5'd0, 2));       // lh
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd25, 5'd0, 4));       // lw
    prog.push_back(encode_i(7'b0000011, 3'b100, 5'd26, 5'd0, 0));       // lbu
    prog.push_back(encode_i(7'b0000011, 3'b101, 5'd27, 5'd0, 2));       // lhu

    // ==========================================
    // 4. Branches (全面覆盖修复版)
    // ==========================================
    
    // ------------------------------------------
    // [Group 1] 测试 "Taken" (跳转)
    // ------------------------------------------
    // 准备数据：让比较条件成立
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd1, 5'd0, 10)); // x1 = 10
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd2, 5'd0, 10)); // x2 = 10 (相等)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd3, 5'd0, 20)); // x3 = 20 (更大)

    // BEQ (Equal): 10 == 10 -> Taken
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd2, calc_offset(prog.size(), prog.size()+2))); 
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

    // BNE (Not Equal): 10 != 20 -> Taken
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd3, calc_offset(prog.size(), prog.size()+2))); 
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

    // BLT (Less Than): 10 < 20 -> Taken
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd1, 5'd3, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

    // BGE (Greater/Equal): 10 >= 10 -> Taken
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd1, 5'd2, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

    // BLTU (Less Unsigned): 10 < 20 -> Taken
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd1, 5'd3, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

    // BGEU (Greater/Equal Unsigned): 10 >= 10 -> Taken
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd1, 5'd2, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)


    // ------------------------------------------
    // [Group 2] 测试 "Not Taken" (不跳转)
    // ------------------------------------------
    // BEQ (Equal): 10 == 20 ? False -> Not Taken
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd3, calc_offset(prog.size(), prog.size()+2))); 
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Executed!)

    // BNE (Not Equal): 10 != 10 ? False -> Not Taken
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, calc_offset(prog.size(), prog.size()+2))); 
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Executed!)

    // BLT (Less Than): 20 < 10 ? False -> Not Taken
    prog.push_back(encode_b(7'b1100011, 3'b100, 5'd3, 5'd1, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

    // BGE (Greater/Equal): 10 >= 20 ? False -> Not Taken
    prog.push_back(encode_b(7'b1100011, 3'b101, 5'd1, 5'd3, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

    // BLTU (Less Unsigned): 20 < 10 ? False -> Not Taken
    prog.push_back(encode_b(7'b1100011, 3'b110, 5'd3, 5'd1, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

    // BGEU (Greater/Equal Unsigned): 10 >= 20 ? False -> Not Taken
    prog.push_back(encode_b(7'b1100011, 3'b111, 5'd1, 5'd3, calc_offset(prog.size(), prog.size()+2)));
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding


    // ------------------------------------------
    // [Group 3] 覆盖非法 Funct3 (2 和 3)
    // ------------------------------------------
    // 为了让 bins[2] 和 bins[3] 变绿。
    // 我们假设 DUT 会忽略这些指令或将其视为不跳转。
    
    // // Illegal Branch (funct3 = 010)
    // prog.push_back(encode_b(7'b1100011, 3'b010, 5'd0, 5'd0, calc_offset(prog.size(), prog.size()+2)));
    // prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding
    
    // // Illegal Branch (funct3 = 011)
    // prog.push_back(encode_b(7'b1100011, 3'b011, 5'd0, 5'd0, calc_offset(prog.size(), prog.size()+2)));
    // prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding

    // ==========================================
    // 5. Jumps
    // ==========================================
    
    // JAL x27, offset
    prog.push_back(encode_j(7'b1101111, 5'd27, calc_offset(prog.size(), prog.size()+2))); 
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // Padding (Skipped)

    // 关键修正：ADDI x27, x27, 12
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd27, 5'd27, 12)); 

    // JALR x0, 0(x27)
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd0, 5'd27, 0)); 
    
    // Target Padding (Landed here)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd28, 5'd0, 0)); 

    // ==========================================
    // 6. U-type
    // ==========================================
    prog.push_back(encode_u(7'b0110111, 5'd29, 20'h1_2345)); // lui
    prog.push_back(encode_u(7'b0010111, 5'd30, 20'h0_0001)); // auipc

    // ==========================================
// ==========================================
    // 7. Pipeline Forwarding (终极修复版)
    // ==========================================
    // 我们需要覆盖 cp_fwdB -> bin mem (Hits: 0)
    // 这意味着 rs2 需要用到前一条指令(MEM阶段)的数据。
    
    // ------------------------------------------
    // 场景 A: ALU-to-ALU Forwarding (间隔 1 条指令)
    // ------------------------------------------
    // 1. Producer: x10 = 0xAA
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd10, 5'd0, 8'hAA)); 
    
    // 2. Gap: 插入一条真实的无关指令 (写 x12)，防止 NOP 被优化
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd12, 5'd0, 8'hBB)); 
    
    // 3. Consumer: ADD x11, x0, x10 (rs2 = x10)
    // 此时 x10 刚好在 WB 阶段，需要从 MEM/WB 流水线寄存器前瞻
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd11, 5'd0, 5'd10)); 

    // ------------------------------------------
    // 场景 B: Load-to-ALU Forwarding (间隔 1 条指令)
    // ------------------------------------------
    // 很多设计把 Load 前瞻专门归类为 MEM Forwarding
    
    // 1. Setup: 先往地址 0 写点东西 (用 SW)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd20, 5'd0, 8'hCC)); // x20 = 0xCC
    prog.push_back(encode_s(7'b0100011, 3'b010, 5'd0, 5'd20, 0));     // SW x20 -> Mem[0]
    
    // 2. Load: LW x21 <- Mem[0]
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd21, 5'd0, 0));     // LW x21, 0(x0)
    
    // 3. Gap: NOP (Load-Use 通常需要 1 cycle 气泡，这里手动给一个)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0));      // ADDI x0, x0, 0
    
    // 4. Consumer: ADD x22, x0, x21 (rs2 = x21)
    // 这里的 x21 数据来自 MEM 阶段的 Load 结果
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd22, 5'd0, 5'd21));
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
    expect_indication = 1; // 避免未触发 indication 的警告
  endfunction
endclass

// 补齐 opcode 空洞：J/JALR/LUI/AUIPC/非法压缩标志
class cpu_opcode_gap_test extends cpu_base_test;
  `uvm_component_utils(cpu_opcode_gap_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 8000; expect_indication = 0; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    prog = {};
    prog.push_back(encode_u(7'b0110111, 5'd1, 20'h00100));     // LUI
    prog.push_back(encode_u(7'b0010111, 5'd2, 20'h00010));     // AUIPC
    prog.push_back(encode_j(7'b1101111, 5'd3, 4));             // JAL (fall-through still samples)
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd4, 5'd3, 0));// JALR
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd5, 5'd0, 1));// ADDI padding
    prog.push_back(32'h0000_0000);                             // 非法压缩半字，触发解压失败覆盖
  endfunction
endclass

// 补全未覆盖 opcode/funct3/funct7/load/forward 分支的定向用例
class cpu_cov_gap2_test extends cpu_base_test;
  `uvm_component_utils(cpu_cov_gap2_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); max_cycles = 12000; expect_indication = 0; endfunction
  virtual function void build_program(ref logic [31:0] prog[$]);
    prog = {};
    // U type
    prog.push_back(encode_u(7'b0110111, 5'd1, 20'h1_0000)); // LUI
    prog.push_back(encode_u(7'b0010111, 5'd2, 20'h0_0008)); // AUIPC
    // Jumps
    prog.push_back(encode_j(7'b1101111, 5'd3, 8));          // JAL (skip next)
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd0, 5'd0, 0)); // padding
    prog.push_back(encode_i(7'b1100111, 3'b000, 5'd4, 5'd3, 0)); // JALR
    // R-type with funct7[5]=1 to hit cp_funct7b5.one
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0100000, 5'd5, 5'd1, 5'd2)); // SUB
    prog.push_back(encode_r(7'b0110011, 3'b110, 7'b0000000, 5'd6, 5'd1, 5'd2)); // OR  (funct3=6)
    prog.push_back(encode_r(7'b0110011, 3'b111, 7'b0000000, 5'd7, 5'd1, 5'd2)); // AND (funct3=7)
    // I-ALU
    prog.push_back(encode_i(7'b0010011, 3'b100, 5'd8, 5'd1, 5)); // XORI
    // Loads of different sizes -> cp_load/load_size_cross
    prog.push_back(encode_i(7'b0000011, 3'b000, 5'd9, 5'd0, 0));  // LB
    prog.push_back(encode_i(7'b0000011, 3'b001, 5'd10,5'd0, 2));  // LH
    prog.push_back(encode_i(7'b0000011, 3'b010, 5'd11,5'd0, 4));  // LW
    // Stores (align variations already in other tests)
    prog.push_back(encode_s(7'b0100011, 3'b000, 5'd0, 5'd9, 6));  // SB
    // Branch taken/not taken to exercise predictor/mispredict
    prog.push_back(encode_b(7'b1100011, 3'b000, 5'd1, 5'd1, 8));  // BEQ taken
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd12,5'd0, 0));  // nop (skipped)
    prog.push_back(encode_b(7'b1100011, 3'b001, 5'd1, 5'd2, -8)); // BNE not taken
    // Forwarding chain: EX and MEM hazards
    prog.push_back(encode_i(7'b0010011, 3'b000, 5'd13,5'd0, 5));   // x13 = 5
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd14,5'd13,5'd1)); // add -> forward EX
    prog.push_back(encode_r(7'b0110011, 3'b000, 7'b0000000, 5'd15,5'd14,5'd2)); // add -> forward MEM
  endfunction
endclass
