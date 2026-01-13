// You can insert code here by setting file_header_inc in file decode_common.tpl

//=============================================================================
// Project  : generated_decode_tb
//
// File Name: decode_in_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Fri Jan  2 22:06:23 2026
//=============================================================================
// Description: Sequence for agent decode_in
//=============================================================================

`ifndef DECODE_IN_SEQ_LIB_SV
`define DECODE_IN_SEQ_LIB_SV

class decode_in_default_seq extends uvm_sequence #(decode_in_tx);

  `uvm_object_utils(decode_in_default_seq)

  // 本地定义 opcode / funct 常量，匹配 control.sv
  localparam logic [6:0] OPC_RTYPE = 7'b0110011;
  localparam logic [6:0] OPC_ITYPE = 7'b0010011;
  localparam logic [6:0] OPC_LOAD  = 7'b0000011;
  localparam logic [6:0] OPC_STORE = 7'b0100011;
  localparam logic [6:0] OPC_BRANCH= 7'b1100011;
  localparam logic [6:0] OPC_JAL   = 7'b1101111;
  localparam logic [6:0] OPC_JALR  = 7'b1100111;
  localparam logic [6:0] OPC_LUI   = 7'b0110111;
  localparam logic [6:0] OPC_AUIPC = 7'b0010111;
  localparam logic [6:0] FUNCT7_ADD = 7'b0000000;
  localparam logic [6:0] FUNCT7_SUB = 7'b0100000;
  localparam logic [6:0] FUNCT7_SRA = 7'b0100000;
  localparam logic [2:0] FUNCT3_ADD = 3'b000;
  localparam logic [2:0] FUNCT3_SUB = 3'b000;
  localparam logic [2:0] FUNCT3_SRA = 3'b101;
  localparam logic [2:0] FUNCT3_SLT = 3'b010;
  localparam logic [2:0] FUNCT3_SLTU= 3'b011;
  localparam logic [2:0] FUNCT3_XOR = 3'b100;
  localparam logic [2:0] FUNCT3_OR  = 3'b110;
  localparam logic [2:0] FUNCT3_AND = 3'b111;
  localparam logic [2:0] FUNCT3_BEQ = 3'b000;
  localparam logic [2:0] FUNCT3_BNE = 3'b001;
  localparam logic [2:0] FUNCT3_BLT = 3'b100;
  localparam logic [2:0] FUNCT3_BGE = 3'b101;
  localparam logic [2:0] FUNCT3_BLTU= 3'b110;
  localparam logic [2:0] FUNCT3_BGEU= 3'b111;
  localparam logic [2:0] FUNCT3_LHU = 3'b101;
  localparam logic [2:0] FUNCT3_LBU = 3'b100;
  localparam logic [2:0] FUNCT3_SW  = 3'b010;
  localparam logic [2:0] FUNCT3_SB  = 3'b000;
  localparam logic [2:0] FUNCT3_SH  = 3'b001;

  decode_in_config  m_config;
  int unsigned      m_seq_count = 1000; // more transactions per run to hit coverage

  extern function new(string name = "");
  extern task body();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : decode_in_default_seq


function decode_in_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task decode_in_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)

  // 打印当前 m_seq_count，便于观察激励长度
  `uvm_info(get_type_name(),
            $sformatf("decode_in_default_seq m_seq_count=%0d", m_seq_count),
            UVM_MEDIUM)

  for (int unsigned i = 0; i < m_seq_count; i++) begin
    `uvm_info(get_type_name(),
              $sformatf("seq item %0d / total %0d", i, m_seq_count),
              UVM_MEDIUM)
    req = decode_in_tx::type_id::create($sformatf("req_%0d", i));
    start_item(req);
    req.instruction = '0;
    // 特殊/非法样本：覆盖 cp_special
    if (i == 0) begin
      req.instruction = 32'h0000_0000; // NOP
      req.pc_in       = $urandom_range(0, 1024);
      finish_item(req);
      continue;
    end
    if (i == 1) begin
      req.instruction = 32'h0000_0111; // 特殊固定值
      req.pc_in       = $urandom_range(0, 1024);
      finish_item(req);
      continue;
    end
    if (i == 2) begin
      req.instruction = {7'h7f, 5'h1f, 3'h7, 5'h1f, 12'hfff}; // 明显非法 opcode
      req.pc_in       = $urandom_range(0, 1024);
      finish_item(req);
      continue;
    end

    // 覆盖 opcode/funct 的定向随机组合
    unique case (i % 18)
  0: req.instruction = {25'h0, $urandom_range(0,7), 5'h1, $urandom_range(0,31), OPC_RTYPE};          // 随机 R
  1: req.instruction = {20'h0, $urandom_range(0,7), $urandom_range(0,31), $urandom_range(0,31), OPC_ITYPE}; // 随机 I
  2: begin // 随机 load，覆盖 mem_size sign
    logic [2:0] f3;
    case (i % 5)
      0: f3 = 3'b000; // LB
      1: f3 = FUNCT3_LHU; // LHU
      2: f3 = FUNCT3_LBU; // LBU
      3: f3 = 3'b001; // LH
      default: f3 = 3'b010; // LW
    endcase
    req.instruction = {12'h0, $urandom_range(0,31), f3, $urandom_range(0,31), OPC_LOAD};
  end
  3: begin // 随机 store，覆盖 mem_size
    logic [2:0] f3;
    case (i % 3)
      0: f3 = FUNCT3_SB; // SB
      1: f3 = FUNCT3_SH; // SH
      default: f3 = FUNCT3_SW; // SW
    endcase
    req.instruction = {7'h0, $urandom_range(0,31), $urandom_range(0,31), f3, $urandom_range(0,31), OPC_STORE};
  end
  4: req.instruction = {$urandom_range(0,7),5'h0,$urandom_range(0,31),$urandom_range(0,7),5'h0,$urandom_range(0,31),OPC_BRANCH}; // 随机 branch
  5: req.instruction = {$urandom_range(0,1),$urandom_range(0,7),$urandom_range(0,1),$urandom_range(0,1),$urandom_range(0,1023),$urandom_range(0,1),$urandom_range(0,31),OPC_JAL};
  6: req.instruction = {20'h0,$urandom_range(0,7),$urandom_range(0,31),$urandom_range(0,31),OPC_JALR};
  7: req.instruction = {$urandom,$urandom_range(0,31),OPC_LUI};
  8: req.instruction = {$urandom,$urandom_range(0,31),OPC_AUIPC};
  9: req.instruction = {FUNCT7_ADD,5'h01,5'h02,FUNCT3_ADD,5'h03,OPC_RTYPE}; // ADD
  10: req.instruction = {FUNCT7_SUB,5'h04,5'h05,FUNCT3_SUB,5'h06,OPC_RTYPE}; // SUB
  11: begin // 移位类 SLL/SRL/SRA
    case (i % 3)
      0: req.instruction = {FUNCT7_ADD,5'h07,5'h08,3'b001,5'h09,OPC_RTYPE}; // SLL
      1: req.instruction = {FUNCT7_ADD,5'h07,5'h08,3'b101,5'h09,OPC_RTYPE}; // SRL
      default: req.instruction = {FUNCT7_SRA,5'h07,5'h08,FUNCT3_SRA,5'h09,OPC_RTYPE}; // SRA
    endcase
  end
  12: begin // SLT/SLTU/XOR/OR/AND 轮换
    case (i % 5)
      0: req.instruction = {FUNCT7_ADD,5'h0a,5'h0b,FUNCT3_SLT, 5'h0c,OPC_RTYPE};
      1: req.instruction = {FUNCT7_ADD,5'h0d,5'h0e,FUNCT3_SLTU,5'h0f,OPC_RTYPE};
      2: req.instruction = {FUNCT7_ADD,5'h10,5'h11,FUNCT3_XOR, 5'h12,OPC_RTYPE};
      3: req.instruction = {FUNCT7_ADD,5'h13,5'h14,FUNCT3_OR,  5'h15,OPC_RTYPE};
      default: req.instruction = {FUNCT7_ADD,5'h16,5'h17,FUNCT3_AND, 5'h18,OPC_RTYPE};
    endcase
  end
  13: begin // BEQ/BNE
    req.instruction = {7'h0,5'h19,5'h1a,FUNCT3_BEQ,5'h1b,OPC_BRANCH};
    if (i[0]) req.instruction[14:12] = FUNCT3_BNE;
  end
  14: begin // BLT/BGE
    req.instruction = {7'h0,5'h1c,5'h1d,FUNCT3_BLT,5'h1e,OPC_BRANCH};
    if (i[0]) req.instruction[14:12] = FUNCT3_BGE;
  end
  15: begin // BLTU/BGEU
    req.instruction = {7'h0,5'h1f,5'h00,FUNCT3_BLTU,5'h01,OPC_BRANCH};
    if (i[0]) req.instruction[14:12] = FUNCT3_BGEU;
  end
  16: begin // Load 尺寸/符号位
    req.instruction = {12'h000,5'h02,FUNCT3_LHU,5'h03,OPC_LOAD}; // LHU
    if (i[0]) req.instruction[14:12] = FUNCT3_LBU;               // LBU
  end
  17: begin // Store 尺寸
    req.instruction = {7'h0,5'h04,5'h05,FUNCT3_SW,5'h06,OPC_STORE}; // SW
    if (i[0]) req.instruction[14:12] = FUNCT3_SB;                    // SB
  end
  default: req.instruction = $urandom; // 非法指令，打非法覆盖
endcase

    // // Inject special patterns explicitly for coverage
    // if (i == 0) begin
    //   req.instruction = 32'h0000_0000; // NOP
    //   req.pc_in       = $urandom_range(0, 1024);
    //   finish_item(req);
    //   continue;
    // end
    // if (i == 1) begin
    //   req.instruction = 32'h0000_1111; // special
    //   req.pc_in       = $urandom_range(0, 1024);
    //   finish_item(req);
    //   continue;
    // end

    // // Build directed-random mixes to cover opcode/funct ranges
    // unique case (i % 10)
    //   0: begin // R-type
    //     req.instruction.opcode = 7'b0110011;
    //     req.instruction.funct3 = $urandom_range(0,7);
    //     req.instruction.funct7 = { $urandom_range(0,1), 6'b0 }; // bit5 toggles add/sub类
    //     req.instruction.rd     = $urandom_range(1,31);
    //     req.instruction.rs1    = $urandom_range(0,31);
    //     req.instruction.rs2    = $urandom_range(0,31);
    //   end
    //   1: begin // I-type arithmetic
    //     req.instruction.opcode = 7'b0010011;
    //     req.instruction.funct3 = $urandom_range(0,7);
    //     req.instruction.funct7 = { $urandom_range(0,1), 6'b0 };
    //     req.instruction.rd     = $urandom_range(1,31);
    //     req.instruction.rs1    = $urandom_range(0,31);
    //     req.instruction.rs2    = $urandom_range(0,31); // immediate bits piggyback
    //   end
    //   2: begin // Loads
    //     req.instruction.opcode = 7'b0000011;
    //     req.instruction.funct3 = $urandom_range(0,5); // 000/001/010/100/101
    //     req.instruction.funct7 = { $urandom_range(0,1), 6'b0 };
    //     req.instruction.rd     = $urandom_range(1,31);
    //     req.instruction.rs1    = $urandom_range(0,31);
    //   end
    //   3: begin // JALR
    //     req.instruction.opcode = 7'b1100111;
    //     req.instruction.funct3 = 3'b000;
    //     req.instruction.funct7 = 7'h0;
    //     req.instruction.rd     = $urandom_range(0,31); // rd可为x0
    //     req.instruction.rs1    = $urandom_range(0,31);
    //   end
    //   4: begin // Store
    //     req.instruction.opcode = 7'b0100011;
    //     req.instruction.funct3 = $urandom_range(0,2);
    //     req.instruction.funct7 = $urandom_range(0,127);
    //     req.instruction.rs1    = $urandom_range(0,31);
    //     req.instruction.rs2    = $urandom_range(0,31);
    //     req.instruction.rd     = req.instruction.funct7[4:0]; // imm[4:0] reuse rd field
    //   end
    //   5: begin // Branches
    //     req.instruction.opcode = 7'b1100011;
    //     req.instruction.funct3 = $urandom_range(0,7);
    //     req.instruction.funct7 = $urandom_range(0,127);
    //     req.instruction.rs1    = $urandom_range(0,31);
    //     req.instruction.rs2    = $urandom_range(0,31);
    //     req.instruction.rd     = req.instruction.funct7[4:0];
    //   end
    //   6: begin // LUI
    //     req.instruction.opcode = 7'b0110111;
    //     req.instruction.funct3 = 3'b000;
    //     req.instruction.funct7 = $urandom_range(0,127);
    //     req.instruction.rd     = $urandom_range(1,31);
    //   end
    //   7: begin // AUIPC
    //     req.instruction.opcode = 7'b0010111;
    //     req.instruction.funct3 = 3'b000;
    //     req.instruction.funct7 = $urandom_range(0,127);
    //     req.instruction.rd     = $urandom_range(1,31);
    //   end
    //   8: begin // JAL
    //     req.instruction.opcode = 7'b1101111;
    //     req.instruction.funct3 = 3'b000;
    //     req.instruction.funct7 = $urandom_range(0,127);
    //     req.instruction.rd     = $urandom_range(1,31);
    //     req.instruction.rs1    = 5'd0;
    //     req.instruction.rs2    = 5'd0;
    //   end
    //   default: begin // Illegal / special
    //     req.instruction.opcode = 7'h7f; // reserved
    //     req.instruction.funct3 = $urandom_range(0,7);
    //     req.instruction.funct7 = $urandom_range(0,127);
    //     req.instruction.rd     = 5'd0;
    //     req.instruction.rs1    = 5'd31; // out of range will trigger illegal
    //     req.instruction.rs2    = 5'd31;
    //   end
    // endcase

    // Randomize remaining bits and pc_in spread
    req.pc_in = $urandom_range(0, 1024);
    finish_item(req);
  end

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


`ifndef UVM_POST_VERSION_1_1
function uvm_phase decode_in_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void decode_in_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting agent_seq_inc in file decode_in.tpl

`endif // DECODE_IN_SEQ_LIB_SV
