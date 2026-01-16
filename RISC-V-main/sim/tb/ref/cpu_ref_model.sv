// cpu_ref_model.sv: sequential reference model
class cpu_ref_model extends uvm_component;
  `uvm_component_utils(cpu_ref_model)

  virtual cpu_mon_if vif;
  uvm_get_port #(issue_tx) issue_port;
  uvm_analysis_port #(issue_tx) exp_issue_ap;
  uvm_analysis_port #(wb_tx) exp_wb_ap;
  uvm_analysis_port #(store_tx) exp_store_ap;
  uvm_analysis_port #(branch_tx) exp_branch_ap;
  uvm_analysis_port #(mem_tx) exp_mem_ap;

  logic [31:0] regs [0:31];
  byte unsigned mem [0:1023];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    issue_port = new("issue_port", this);
    exp_issue_ap = new("exp_issue_ap", this);
    exp_wb_ap = new("exp_wb_ap", this);
    exp_store_ap = new("exp_store_ap", this);
    exp_branch_ap = new("exp_branch_ap", this);
    exp_mem_ap = new("exp_mem_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif))
      `uvm_fatal(get_type_name(), "cpu_mon_if not found")
  endfunction

  function void reset_state();
    for (int i = 0; i < 32; i++) regs[i] = 32'b0;
    for (int j = 0; j < 1024; j++) mem[j] = 8'b0;
  endfunction

  function automatic int unsigned mask_addr(input logic [31:0] addr);
    return addr[9:0];
  endfunction

  function automatic logic [31:0] mem_read(input logic [31:0] addr,
                                           input logic [1:0] mem_size,
                                           input logic mem_sign);
    int unsigned base;
    logic [7:0] b0, b1, b2, b3; logic [15:0] h; logic [31:0] w;
    base = mask_addr(addr);
    b0 = mem[(base + 0) & 10'h3FF];
    b1 = mem[(base + 1) & 10'h3FF];
    b2 = mem[(base + 2) & 10'h3FF];
    b3 = mem[(base + 3) & 10'h3FF];
    case (mem_size)
      2'b00: mem_read = mem_sign ? {{24{b0[7]}}, b0} : {24'b0, b0};
      2'b01: begin h = {b1, b0}; mem_read = mem_sign ? {{16{h[15]}}, h} : {16'b0, h}; end
      2'b10: begin w = {b3, b2, b1, b0}; mem_read = w; end
      default: mem_read = {b3, b2, b1, b0};
    endcase
  endfunction

  task mem_write(input logic [31:0] addr, input logic [1:0] mem_size, input logic [31:0] data);
    int unsigned base; base = mask_addr(addr);
    case (mem_size)
      2'b00: mem[base] = data[7:0];
      2'b01: begin mem[base] = data[7:0]; mem[(base + 1) & 10'h3FF] = data[15:8]; end
      2'b10: begin mem[base] = data[7:0]; mem[(base + 1) & 10'h3FF] = data[15:8]; mem[(base + 2) & 10'h3FF] = data[23:16]; mem[(base + 3) & 10'h3FF] = data[31:24]; end
      default: mem[base] = data[7:0];
    endcase
  endtask

  function automatic encoding_type decode_encoding(input instruction_type instr);
    case (instr.opcode)
      7'b0110011: decode_encoding = R_TYPE;
      7'b0010011: decode_encoding = I_TYPE;
      7'b0000011: decode_encoding = I_TYPE;
      7'b0100011: decode_encoding = S_TYPE;
      7'b1100011: decode_encoding = B_TYPE;
      7'b1101111: decode_encoding = J_TYPE;
      7'b1100111: decode_encoding = I_TYPE;
      7'b0110111: decode_encoding = U_TYPE;
      7'b0010111: decode_encoding = U_TYPE;
      default: decode_encoding = NONE_TYPE;
    endcase
  endfunction

  task execute_one(issue_tx tx);
    instruction_type instr; logic [31:0] rs1_val; logic [31:0] rs2_val; logic [31:0] imm;
    logic [31:0] result; logic [31:0] addr; logic [31:0] word; encoding_type enc;
    wb_tx wb; store_tx st; branch_tx br; mem_tx mt;
    issue_tx itx;

    instr = tx.instr; word = instr_to_word(instr);
    // 非法/空指令直接丢弃，不计入期望 issue
    if (word == 32'h0000_0000 || word == 32'h0000_1111) return;

    // 期望 issue 事务下发（与实际 issue 对齐，仅对有效指令）
    itx = issue_tx::type_id::create("itx", this);
    itx.instr = instr;
    itx.pc    = tx.pc;
    exp_issue_ap.write(itx);

    enc = decode_encoding(instr);
    rs1_val = regs[instr.rs1];
    rs2_val = regs[instr.rs2];
    imm = immediate_extension(instr, enc);

    case (instr.opcode)
      7'b0110011: begin // R-type ALU ops (add/sub/sll/slt/sltu/xor/srl/sra/or/and)
        case (instr.funct3)
          3'b000: result = (instr.funct7[5]) ? (rs1_val - rs2_val) : (rs1_val + rs2_val);
          3'b001: result = rs1_val << rs2_val[4:0];
          3'b010: result = ($signed(rs1_val) < $signed(rs2_val)) ? 32'd1 : 32'd0;
          3'b011: result = (rs1_val < rs2_val) ? 32'd1 : 32'd0;
          3'b100: result = rs1_val ^ rs2_val;
          3'b101: result = (instr.funct7[5]) ? ($signed(rs1_val) >>> rs2_val[4:0]) : (rs1_val >> rs2_val[4:0]);
          3'b110: result = rs1_val | rs2_val;
          3'b111: result = rs1_val & rs2_val;
          default: result = 32'b0;
        endcase
        if (instr.rd != 0) begin
          regs[instr.rd] = result;
          wb = wb_tx::type_id::create("wb"); wb.pc = tx.pc; wb.rd = instr.rd; wb.data = result; wb.is_load = 0; wb.mem_size = 2'b10; wb.mem_sign = 1'b0; exp_wb_ap.write(wb);
        end
      end

      7'b0010011: begin // I-type ALU ops with immediate
        case (instr.funct3)
          3'b000: result = rs1_val + imm;
          3'b001: result = rs1_val << instr.rs2;
          3'b010: result = ($signed(rs1_val) < $signed(imm)) ? 32'd1 : 32'd0;
          3'b011: result = (rs1_val < imm) ? 32'd1 : 32'd0;
          3'b100: result = rs1_val ^ imm;
          3'b101: result = (instr.funct7[5]) ? ($signed(rs1_val) >>> instr.rs2) : (rs1_val >> instr.rs2);
          3'b110: result = rs1_val | imm;
          3'b111: result = rs1_val & imm;
          default: result = 32'b0;
        endcase
        if (instr.rd != 0) begin
          regs[instr.rd] = result;
          wb = wb_tx::type_id::create("wb"); wb.pc = tx.pc; wb.rd = instr.rd; wb.data = result; wb.is_load = 0; wb.mem_size = 2'b10; wb.mem_sign = 1'b0; exp_wb_ap.write(wb);
        end
      end

      7'b0000011: begin // LOAD: LB/LH/LW/LBU/LHU
        addr = rs1_val + imm;
        case (instr.funct3)
          3'b000: result = mem_read(addr, 2'b00, 1'b1);
          3'b001: result = mem_read(addr, 2'b01, 1'b1);
          3'b010: result = mem_read(addr, 2'b10, 1'b1);
          3'b100: result = mem_read(addr, 2'b00, 1'b0);
          3'b101: result = mem_read(addr, 2'b01, 1'b0);
          default: result = 32'b0;
        endcase
        mt = mem_tx::type_id::create("mt_load", this);
        mt.addr = addr;
        mt.is_read = 1'b1;
        mt.is_write = 1'b0;
        mt.mem_size = (instr.funct3[1:0] == 2'b00) ? 2'b00 : (instr.funct3[1:0] == 2'b01) ? 2'b01 : 2'b10;
        mt.mem_sign = (instr.funct3[2] == 1'b0);
        exp_mem_ap.write(mt);
        if (instr.rd != 0) begin
          regs[instr.rd] = result;
          wb = wb_tx::type_id::create("wb"); wb.pc = tx.pc; wb.rd = instr.rd; wb.data = result; wb.is_load = 1; wb.mem_size = (instr.funct3[1:0] == 2'b00) ? 2'b00 : (instr.funct3[1:0] == 2'b01) ? 2'b01 : 2'b10; wb.mem_sign = (instr.funct3[2] == 1'b0); exp_wb_ap.write(wb);
        end
      end

      7'b0100011: begin // STORE: SB/SH/SW
        addr = rs1_val + imm;
        case (instr.funct3)
          3'b000: mem_write(addr, 2'b00, rs2_val);
          3'b001: mem_write(addr, 2'b01, rs2_val);
          3'b010: mem_write(addr, 2'b10, rs2_val);
          default: mem_write(addr, 2'b00, rs2_val);
        endcase
        mt = mem_tx::type_id::create("mt_store", this);
        mt.addr = addr;
        mt.is_read = 1'b0;
        mt.is_write = 1'b1;
        mt.mem_size = (instr.funct3 == 3'b000) ? 2'b00 : (instr.funct3 == 3'b001) ? 2'b01 : 2'b10;
        mt.mem_sign = 1'b0;
        exp_mem_ap.write(mt);
        st = store_tx::type_id::create("st"); st.pc = tx.pc; st.addr = addr; st.data = rs2_val; st.mem_size = (instr.funct3 == 3'b000) ? 2'b00 : (instr.funct3 == 3'b001) ? 2'b01 : 2'b10; exp_store_ap.write(st);
      end

      7'b1100011: begin // BRANCH: BEQ/BNE/BLT/BGE/BLTU/BGEU
        bit taken;
        case (instr.funct3)
          3'b000: taken = (rs1_val == rs2_val);
          3'b001: taken = (rs1_val != rs2_val);
          3'b100: taken = ($signed(rs1_val) < $signed(rs2_val));
          3'b101: taken = ($signed(rs1_val) >= $signed(rs2_val));
          3'b110: taken = (rs1_val < rs2_val);
          3'b111: taken = (rs1_val >= rs2_val);
          default: taken = 1'b0;
        endcase
        br = branch_tx::type_id::create("br"); br.pc = tx.pc; br.taken = taken; br.funct3 = instr.funct3; exp_branch_ap.write(br);
      end

      7'b1101111: begin // JAL: write return addr (pc+4) to rd
        result = tx.pc + 32'd4;
        if (instr.rd != 0) begin regs[instr.rd] = result; wb = wb_tx::type_id::create("wb"); wb.pc = tx.pc; wb.rd = instr.rd; wb.data = result; wb.is_load = 0; wb.mem_size = 2'b10; wb.mem_sign = 1'b0; exp_wb_ap.write(wb); end
      end

      7'b1100111: begin // JALR: write return addr (pc+4) to rd
        result = tx.pc + 32'd4;
        if (instr.rd != 0) begin regs[instr.rd] = result; wb = wb_tx::type_id::create("wb"); wb.pc = tx.pc; wb.rd = instr.rd; wb.data = result; wb.is_load = 0; wb.mem_size = 2'b10; wb.mem_sign = 1'b0; exp_wb_ap.write(wb); end
      end

      7'b0110111: begin // LUI: load upper immediate to rd
        result = imm;
        if (instr.rd != 0) begin regs[instr.rd] = result; wb = wb_tx::type_id::create("wb"); wb.pc = tx.pc; wb.rd = instr.rd; wb.data = result; wb.is_load = 0; wb.mem_size = 2'b10; wb.mem_sign = 1'b0; exp_wb_ap.write(wb); end
      end

      7'b0010111: begin // AUIPC: rd = pc + imm
        result = tx.pc + imm;
        if (instr.rd != 0) begin regs[instr.rd] = result; wb = wb_tx::type_id::create("wb"); wb.pc = tx.pc; wb.rd = instr.rd; wb.data = result; wb.is_load = 0; wb.mem_size = 2'b10; wb.mem_sign = 1'b0; exp_wb_ap.write(wb); end
      end
      default: ;
    endcase
  endtask

  task run_phase(uvm_phase phase);
    issue_tx tx; reset_state();
    forever begin
      issue_port.get(tx);
      if (vif.reset_n === 1'b0) begin reset_state(); continue; end
      execute_one(tx);
    end
  endtask
endclass
