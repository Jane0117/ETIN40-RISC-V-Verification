// cpu_coverage.sv
class cpu_coverage extends uvm_component;
  `uvm_component_utils(cpu_coverage)

  virtual cpu_mon_if vif;
  uvm_analysis_imp_issue #(issue_tx, cpu_coverage) issue_imp;
  uvm_analysis_imp_wb #(wb_tx, cpu_coverage) wb_imp;
  uvm_analysis_imp_store #(store_tx, cpu_coverage) store_imp;
  uvm_analysis_imp_branch #(branch_tx, cpu_coverage) branch_imp;
  uvm_analysis_imp_mem #(mem_tx, cpu_coverage) mem_imp;

  // Track executed instruction names for detailed reporting
  string instr_list[$];
  int unsigned instr_counts[string];
  int unsigned instr_total;

  covergroup issue_cg with function sample(issue_tx t);
    option.per_instance = 1;
    cp_opcode: coverpoint t.instr.opcode {
      bins r_type  = {7'b0110011};
      bins i_alu   = {7'b0010011};
      bins i_load  = {7'b0000011};
      bins s_type  = {7'b0100011};
      bins b_type  = {7'b1100011};
      bins j_type  = {7'b1101111};
      bins i_jalr  = {7'b1100111};
      bins u_lui   = {7'b0110111};
      bins u_auipc = {7'b0010111};
      bins other   = default;
    }
    cp_funct3: coverpoint t.instr.funct3 { bins all[] = {[0:7]}; }
    cp_funct7b5: coverpoint t.instr.funct7[5] { bins zero = {0}; bins one = {1}; }
    // Cross of opcode x funct3 creates impossible combinations for some opcodes,
    // which depresses coverage for unsupported instructions. Skip it to focus on supported bins.
  endgroup

  covergroup wb_cg with function sample(wb_tx t);
    option.per_instance = 1;
    cp_load: coverpoint t.is_load { bins load = {1}; bins alu = {0}; }
    cp_mem_size: coverpoint t.mem_size { bins bin_byte = {2'b00}; bins bin_half = {2'b01}; bins bin_word = {2'b10}; }
    load_size_cross: cross cp_load, cp_mem_size;
  endgroup

  covergroup store_cg with function sample(store_tx t);
    option.per_instance = 1;
    cp_store_size: coverpoint t.mem_size { bins bin_byte = {2'b00}; bins bin_half = {2'b01}; bins bin_word = {2'b10}; }
    cp_addr_align: coverpoint t.addr[1:0] { bins b0 = {2'b00}; bins b1 = {2'b01}; bins b2 = {2'b10}; bins b3 = {2'b11}; }
    store_cross: cross cp_store_size, cp_addr_align;
  endgroup

  covergroup branch_cg with function sample(branch_tx t);
    option.per_instance = 1;
    cp_taken: coverpoint t.taken { bins taken = {1}; bins not_taken = {0}; }
    cp_f3: coverpoint t.funct3 {
      bins beq  = {3'b000};
      bins bne  = {3'b001};
      bins blt  = {3'b100};
      bins bge  = {3'b101};
      bins bltu = {3'b110};
      bins bgeu = {3'b111};
    }
    branch_cross: cross cp_f3, cp_taken;
  endgroup

  covergroup mem_cg with function sample(mem_tx t);
    option.per_instance = 1;
    cp_is_read: coverpoint t.is_read;
    cp_is_write: coverpoint t.is_write;
    cp_mem_size: coverpoint t.mem_size { bins bin_byte = {2'b00}; bins bin_half = {2'b01}; bins bin_word = {2'b10}; }
    cp_sign: coverpoint t.mem_sign;
  endgroup

  covergroup pipe_cg;
    option.per_instance = 1;
    cp_fwdA: coverpoint vif.forwardA { bins none = {2'b00}; bins ex = {2'b01}; bins mem = {2'b10}; }
    cp_fwdB: coverpoint vif.forwardB { bins none = {2'b00}; bins ex = {2'b01}; bins mem = {2'b10}; }
    cp_flush: coverpoint {vif.if_id_flush, vif.id_ex_flush, vif.ex_mem_flush} { bins none = {3'b000}; bins any = {[1:7]}; }
    cp_stall: coverpoint (vif.pc_write == 1'b0) { bins stall = {1}; bins run = {0}; }
    cp_pred: coverpoint vif.fetch_prediction { bins taken = {1}; bins not_taken = {0}; }
    cp_mispredict: coverpoint (vif.pc_src ^ vif.fetch_prediction) { bins miss = {1}; bins hit = {0}; }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    issue_imp = new("issue_imp", this);
    wb_imp = new("wb_imp", this);
    store_imp = new("store_imp", this);
    branch_imp = new("branch_imp", this);
    mem_imp = new("mem_imp", this);
    issue_cg = new(); wb_cg = new(); store_cg = new(); branch_cg = new(); mem_cg = new();
    pipe_cg = new();

    // Ordered list for reporting
    instr_list = '{
      "LUI", "AUIPC",
      "JAL", "JALR",
      "BEQ", "BNE", "BLT", "BGE", "BLTU", "BGEU",
      "LB", "LH", "LW", "LBU", "LHU",
      "SB", "SH", "SW",
      "ADDI", "SLTI", "SLTIU", "XORI", "ORI", "ANDI", "SLLI", "SRLI", "SRAI",
      "ADD", "SUB", "SLL", "SLT", "SLTU", "XOR", "SRL", "SRA", "OR", "AND"
    };
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif))
      `uvm_fatal(get_type_name(), "cpu_mon_if not found")
  endfunction

  // Decode a human-friendly instruction name from opcode/funct fields
  function string decode_instr(instruction_type instr);
    string name;
    case (instr.opcode)
      7'b0110111: name = "LUI";
      7'b0010111: name = "AUIPC";
      7'b1101111: name = "JAL";
      7'b1100111: name = "JALR";
      7'b1100011: begin
        case (instr.funct3)
          3'b000: name = "BEQ";
          3'b001: name = "BNE";
          3'b100: name = "BLT";
          3'b101: name = "BGE";
          3'b110: name = "BLTU";
          3'b111: name = "BGEU";
          default: name = "BR_UNKNOWN";
        endcase
      end
      7'b0000011: begin
        case (instr.funct3)
          3'b000: name = "LB";
          3'b001: name = "LH";
          3'b010: name = "LW";
          3'b100: name = "LBU";
          3'b101: name = "LHU";
          default: name = "LOAD_UNKNOWN";
        endcase
      end
      7'b0100011: begin
        case (instr.funct3)
          3'b000: name = "SB";
          3'b001: name = "SH";
          3'b010: name = "SW";
          default: name = "STORE_UNKNOWN";
        endcase
      end
      7'b0010011: begin
        case (instr.funct3)
          3'b000: name = "ADDI";
          3'b010: name = "SLTI";
          3'b011: name = "SLTIU";
          3'b100: name = "XORI";
          3'b110: name = "ORI";
          3'b111: name = "ANDI";
          3'b001: name = "SLLI";
          3'b101: name = instr.funct7[5] ? "SRAI" : "SRLI";
          default: name = "I_UNKNOWN";
        endcase
      end
      7'b0110011: begin
        case (instr.funct3)
          3'b000: name = instr.funct7[5] ? "SUB" : "ADD";
          3'b001: name = "SLL";
          3'b010: name = "SLT";
          3'b011: name = "SLTU";
          3'b100: name = "XOR";
          3'b101: name = instr.funct7[5] ? "SRA" : "SRL";
          3'b110: name = "OR";
          3'b111: name = "AND";
          default: name = "R_UNKNOWN";
        endcase
      end
      default: name = $sformatf("OP0x%02h", instr.opcode);
    endcase
    return name;
  endfunction

  function void write_issue(issue_tx t);
    string name;
    issue_cg.sample(t);
    // Skip obvious bubbles/NOP-fill (all-zero instruction), which would otherwise dominate counts
    if (t.instr.opcode == 7'b0 && t.instr.funct3 == 3'b0 && t.instr.rs1 == 0 && t.instr.rs2 == 0 &&
        t.instr.funct7 == 7'b0 && t.instr.rd == 0)
      return;
    name = decode_instr(t.instr);
    if (instr_counts.exists(name))
      instr_counts[name]++;
    else
      instr_counts[name] = 1;
    instr_total++;
  endfunction
  function void write_wb(wb_tx t); wb_cg.sample(t); endfunction
  function void write_store(store_tx t); store_cg.sample(t); endfunction
  function void write_branch(branch_tx t); branch_cg.sample(t); endfunction
  function void write_mem(mem_tx t); mem_cg.sample(t); endfunction

  task run_phase(uvm_phase phase);
    forever begin @(posedge vif.clk); if (vif.reset_n === 1'b0) continue; pipe_cg.sample(); end
  endtask

  // Return a compact string of counts for all known instructions, followed by any unknowns encountered
  function string format_instr_counts();
    string line;
    string name;
    line = $sformatf("Instruction counts (total=%0d):", instr_total);
    foreach (instr_list[idx]) begin
      name = instr_list[idx];
      if (instr_counts.exists(name))
        line = {line, " ", name, "=", $sformatf("%0d", instr_counts[name])};
      else
        line = {line, " ", name, "=0"};
    end
    foreach (instr_counts[key]) begin
      bit is_known = 0;
      foreach (instr_list[i]) if (instr_list[i] == key) is_known = 1;
      if (!is_known) line = {line, " ", key, "=", $sformatf("%0d", instr_counts[key])};
    end
    return line;
  endfunction
endclass
