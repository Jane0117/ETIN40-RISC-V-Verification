// cpu_coverage.sv
class cpu_coverage extends uvm_component;
  `uvm_component_utils(cpu_coverage)

  virtual cpu_mon_if vif;
  uvm_analysis_imp_issue #(issue_tx, cpu_coverage) issue_imp;
  uvm_analysis_imp_wb #(wb_tx, cpu_coverage) wb_imp;
  uvm_analysis_imp_store #(store_tx, cpu_coverage) store_imp;
  uvm_analysis_imp_branch #(branch_tx, cpu_coverage) branch_imp;
  uvm_analysis_imp_mem #(mem_tx, cpu_coverage) mem_imp;

  covergroup issue_cg with function sample(issue_tx t);
    option.per_instance = 1;
    // 仅对支持的 opcode 采样，过滤 default 避免不可达 bin
    cp_opcode: coverpoint t.instr.opcode
      iff (t.instr.opcode inside {7'b0110011, // R
                                  7'b0010011, // I-ALU
                                  7'b0000011, // LOAD
                                  7'b0100011, // STORE
                                  7'b1100011, // BRANCH
                                  7'b1101111, // JAL
                                  7'b1100111, // JALR
                                  7'b0110111, // LUI
                                  7'b0010111  // AUIPC
                                 }) {
      bins r_type  = {7'b0110011};
      bins i_alu   = {7'b0010011};
      bins i_load  = {7'b0000011};
      bins s_type  = {7'b0100011};
      bins b_type  = {7'b1100011};
      bins j_type  = {7'b1101111};
      bins i_jalr  = {7'b1100111};
      bins u_lui   = {7'b0110111};
      bins u_auipc = {7'b0010111};
    }
    // funct3 仅关注合法 0-7，非法组合由 ignore_bins 过滤
    cp_funct3: coverpoint t.instr.funct3 { bins legal[] = {[0:7]}; }
    cp_funct7b5: coverpoint t.instr.funct7[5] { bins zero = {0}; bins one = {1}; }
    // 过滤非法 opcode/funct3 组合，减少不可达 bin
    opc_f3_cross: cross cp_opcode, cp_funct3 {
      ignore_bins j_like    = binsof(cp_opcode) intersect {7'b1101111, 7'b1100111, 7'b0110111, 7'b0010111};
      ignore_bins load_inv  = binsof(cp_opcode) intersect {7'b0000011} && binsof(cp_funct3) intersect {3,6,7};
      ignore_bins store_inv = binsof(cp_opcode) intersect {7'b0100011} && binsof(cp_funct3) intersect {[3:7]};
      ignore_bins branch_inv= binsof(cp_opcode) intersect {7'b1100011} && binsof(cp_funct3) intersect {3'b010,3'b011};
    }
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
    cp_f3: coverpoint t.funct3 { bins all[] = {[0:7]}; }
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

  // 压缩指令覆盖：当前取到的半字是否压缩，以及解压是否失败
  covergroup compress_cg;
    option.per_instance = 1;
    cp_is_compressed: coverpoint (vif.program_mem_read_data[1:0] != 2'b11)
      iff (vif.reset_n && vif.pc_write) {
      bins compressed = {1'b1};
      bins normal     = {1'b0};
    }
    cp_decomp_fail: coverpoint vif.fetch_decompress_failed
      iff (vif.reset_n && vif.pc_write) { bins ok = {0}; bins fail = {1}; }
    iscomp_x_fail: cross cp_is_compressed, cp_decomp_fail;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    issue_imp = new("issue_imp", this);
    wb_imp = new("wb_imp", this);
    store_imp = new("store_imp", this);
    branch_imp = new("branch_imp", this);
    mem_imp = new("mem_imp", this);
    issue_cg = new(); wb_cg = new(); store_cg = new(); branch_cg = new(); mem_cg = new();
    pipe_cg = new(); compress_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif))
      `uvm_fatal(get_type_name(), "cpu_mon_if not found")
  endfunction

  function void write_issue(issue_tx t); issue_cg.sample(t); endfunction
  function void write_wb(wb_tx t); wb_cg.sample(t); endfunction
  function void write_store(store_tx t); store_cg.sample(t); endfunction
  function void write_branch(branch_tx t); branch_cg.sample(t); endfunction
  function void write_mem(mem_tx t); mem_cg.sample(t); endfunction

  task run_phase(uvm_phase phase);
    forever begin @(posedge vif.clk);
      if (vif.reset_n === 1'b0) continue;
      pipe_cg.sample();
      compress_cg.sample();
    end
  endtask
endclass
