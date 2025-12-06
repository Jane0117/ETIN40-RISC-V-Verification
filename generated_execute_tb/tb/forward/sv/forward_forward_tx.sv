// You can insert code here by setting file_header_inc in file execute_common.tpl

//=============================================================================
// Project  : generated_execute_tb
//
// File Name: forward_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Wed Nov 12 21:15:16 2025
//=============================================================================
// Description: Sequence item for forward_sequencer
//=============================================================================

`ifndef FORWARD_SEQ_ITEM_SV
`define FORWARD_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file forward.tpl

class forward_tx extends uvm_sequence_item; 

  `uvm_object_utils(forward_tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file forward.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file forward.tpl

  // 1)Transaction variables
  rand logic [31:0] wb_forward_data;
  rand logic [31:0] mem_forward_data;
  rand forward_type  forward_rs1;
  rand forward_type  forward_rs2;
  // 驱动时对 forward bus 的期望快照，供 scoreboard 做 driver→monitor 比对
  logic [31:0] exp_wb_forward_data;
  logic [31:0] exp_mem_forward_data;
  // ================================
  // 2) Expected forwarding source
  //    scoreboard 的“期望值标签”，不是 DUT 信号
  // ================================
  forward_type exp_src_rs1;
  forward_type exp_src_rs2;
  // 9 条 forwarding path 的枚举，用来标记 hazard/覆盖模式
  typedef enum logic [3:0] {
    PATH_NONE_NONE, // rs1: none, rs2: none
    PATH_MEM_NONE,  // rs1: MEM,  rs2: none
    PATH_EX_NONE,   // rs1: EX,   rs2: none
    PATH_NONE_MEM,  // rs1: none, rs2: MEM
    PATH_MEM_MEM,   // rs1: MEM,  rs2: MEM
    PATH_EX_MEM,    // rs1: EX,   rs2: MEM
    PATH_NONE_EX,   // rs1: none, rs2: EX
    PATH_MEM_EX,    // rs1: MEM,  rs2: EX
    PATH_EX_EX      // rs1: EX,   rs2: EX
  } forward_path_e;
  forward_path_e path_tag;

  //----------------------------------------------------------------------------
  // 3) NEW: Enum validity constraint based on RTL definition
  //----------------------------------------------------------------------------
  constraint c_enum_valid {
      forward_rs1 inside {FORWARD_NONE, FORWARD_FROM_MEM, FORWARD_FROM_EX};
      forward_rs2 inside {FORWARD_NONE, FORWARD_FROM_MEM, FORWARD_FROM_EX};
  }
  extern function new(string name = "");
  extern function void post_randomize();
  extern function void bake_expect();

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file forward.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file forward.tpl

endclass : forward_tx 


function forward_tx::new(string name = "");
  super.new(name);
endfunction : new

//post_randomize()是 SystemVerilog 语言/随机化机制的钩子函数：每次 randomize() 成功后，
//仿真器会自动调用同名的 post_randomize()，无需你手动触发。
function void forward_tx::post_randomize();
  bake_expect();
  `uvm_info(get_type_name(),
            $sformatf("post_randomize: rs1=%0d rs2=%0d wb=0x%0h mem=0x%0h path_tag=%0d",
                      forward_rs1, forward_rs2, wb_forward_data, mem_forward_data, path_tag),
            UVM_HIGH)
endfunction : post_randomize


// 根据 selector 生成期望标签与数据快照，供 coverage/scoreboard 共用
function void forward_tx::bake_expect();
  exp_src_rs1         = forward_rs1;
  exp_src_rs2         = forward_rs2;
  exp_wb_forward_data  = wb_forward_data;
  exp_mem_forward_data = mem_forward_data;

  unique case ({forward_rs1, forward_rs2})
    {FORWARD_NONE,     FORWARD_NONE}: path_tag = PATH_NONE_NONE;
    {FORWARD_FROM_MEM, FORWARD_NONE}: path_tag = PATH_MEM_NONE;
    {FORWARD_FROM_EX,  FORWARD_NONE}: path_tag = PATH_EX_NONE;
    {FORWARD_NONE,     FORWARD_FROM_MEM}: path_tag = PATH_NONE_MEM;
    {FORWARD_FROM_MEM, FORWARD_FROM_MEM}: path_tag = PATH_MEM_MEM;
    {FORWARD_FROM_EX,  FORWARD_FROM_MEM}: path_tag = PATH_EX_MEM;
    {FORWARD_NONE,     FORWARD_FROM_EX}: path_tag = PATH_NONE_EX;
    {FORWARD_FROM_MEM, FORWARD_FROM_EX}: path_tag = PATH_MEM_EX;
    {FORWARD_FROM_EX,  FORWARD_FROM_EX}: path_tag = PATH_EX_EX;
    default: path_tag = PATH_NONE_NONE;
  endcase

  // Debug helper：可通过 UVM verbosities 控制打印
  `uvm_info(get_type_name(),
            $sformatf("bake_expect: rs1=%0d rs2=%0d exp_src_rs1=%0d exp_src_rs2=%0d path_tag=%0d wb=0x%0h mem=0x%0h",
                      forward_rs1, forward_rs2, exp_src_rs1, exp_src_rs2, path_tag,
                      wb_forward_data, mem_forward_data),
            UVM_HIGH)
endfunction : bake_expect


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file forward.tpl
//把另一个 transaction 的字段复制过来（用于 cloning）
function void forward_tx::do_copy(uvm_object rhs);
  forward_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  wb_forward_data  = rhs_.wb_forward_data; 
  mem_forward_data = rhs_.mem_forward_data;
  forward_rs1      = rhs_.forward_rs1;     
  forward_rs2      = rhs_.forward_rs2;     

  exp_wb_forward_data  = rhs_.exp_wb_forward_data;
  exp_mem_forward_data = rhs_.exp_mem_forward_data;
  exp_src_rs1      = rhs_.exp_src_rs1;
  exp_src_rs2      = rhs_.exp_src_rs2;
  path_tag         = rhs_.path_tag;
endfunction : do_copy

//用于 scoreboard/comparer 自动字段比较
function bit forward_tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  forward_tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("wb_forward_data", wb_forward_data,   rhs_.wb_forward_data,  $bits(wb_forward_data));
  result &= comparer.compare_field("mem_forward_data", mem_forward_data, rhs_.mem_forward_data, $bits(mem_forward_data));
  result &= comparer.compare_field("forward_rs1", forward_rs1,           rhs_.forward_rs1,      $bits(forward_rs1));
  result &= comparer.compare_field("forward_rs2", forward_rs2,           rhs_.forward_rs2,      $bits(forward_rs2));
  result &= comparer.compare_field("exp_wb_forward_data", exp_wb_forward_data, rhs_.exp_wb_forward_data, $bits(exp_wb_forward_data));
  result &= comparer.compare_field("exp_mem_forward_data", exp_mem_forward_data, rhs_.exp_mem_forward_data, $bits(exp_mem_forward_data));
  result &= comparer.compare_field("exp_src_rs1", exp_src_rs1, rhs_.exp_src_rs1, $bits(exp_src_rs1));
  result &= comparer.compare_field("exp_src_rs2", exp_src_rs2, rhs_.exp_src_rs2, $bits(exp_src_rs2));
  result &= comparer.compare_field("path_tag", path_tag, rhs_.path_tag, $bits(path_tag));
  return result;
endfunction : do_compare

//控制打印行为
function void forward_tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print

//控制记录到数据库/波形文件的字段
function void forward_tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("wb_forward_data",  wb_forward_data) 
  `uvm_record_field("mem_forward_data", mem_forward_data)
  `uvm_record_field("forward_rs1",      forward_rs1)     
  `uvm_record_field("forward_rs2",      forward_rs2)     
  `uvm_record_field("exp_wb_forward_data",  exp_wb_forward_data)
  `uvm_record_field("exp_mem_forward_data", exp_mem_forward_data)
  `uvm_record_field("exp_src_rs1",      exp_src_rs1)
  `uvm_record_field("exp_src_rs2",      exp_src_rs2)
  `uvm_record_field("path_tag",         path_tag)
endfunction : do_record

//控制打包和解包行为（用于 TLM 传输）
function void forward_tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(wb_forward_data)  
  `uvm_pack_int(mem_forward_data) 
  `uvm_pack_int(forward_rs1)      
  `uvm_pack_int(forward_rs2)
  `uvm_pack_int(exp_wb_forward_data)
  `uvm_pack_int(exp_mem_forward_data)
  `uvm_pack_int(exp_src_rs1)
  `uvm_pack_int(exp_src_rs2)
  `uvm_pack_int(path_tag)
endfunction : do_pack

function void forward_tx::do_unpack(uvm_packer packer);
  int unsigned tmp_rs1;
  int unsigned tmp_rs2;
  int unsigned tmp_exp_rs1;
  int unsigned tmp_exp_rs2;
  int unsigned tmp_path;
  super.do_unpack(packer);
  `uvm_unpack_int(wb_forward_data)  
  `uvm_unpack_int(mem_forward_data) 
  `uvm_unpack_int(tmp_rs1)
  `uvm_unpack_int(tmp_rs2)
  `uvm_unpack_int(exp_wb_forward_data)
  `uvm_unpack_int(exp_mem_forward_data)
  `uvm_unpack_int(tmp_exp_rs1)
  `uvm_unpack_int(tmp_exp_rs2)
  `uvm_unpack_int(tmp_path)
  forward_rs1      = forward_type'(tmp_rs1);
  forward_rs2      = forward_type'(tmp_rs2);
  exp_src_rs1      = forward_type'(tmp_exp_rs1);
  exp_src_rs2      = forward_type'(tmp_exp_rs2);
  path_tag         = forward_path_e'(tmp_path);
  bake_expect();
endfunction : do_unpack

//打印成字符串（日志格式化）
function string forward_tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "wb_forward_data  = 'h%0h  'd%0d\n", 
    "mem_forward_data = 'h%0h  'd%0d\n", 
    "forward_rs1      = 'h%0h  'd%0d\n", 
    "forward_rs2      = 'h%0h  'd%0d\n",
    "exp_wb_forward_data  = 'h%0h  'd%0d\n",
    "exp_mem_forward_data = 'h%0h  'd%0d\n",
    "exp_src_rs1          = %0d\n",
    "exp_src_rs2          = %0d\n",
    "path_tag             = %0d\n"},
    get_full_name(), wb_forward_data, wb_forward_data, mem_forward_data, mem_forward_data, forward_rs1, forward_rs1, forward_rs2, forward_rs2,
    exp_wb_forward_data, exp_wb_forward_data, exp_mem_forward_data, exp_mem_forward_data, exp_src_rs1, exp_src_rs2, path_tag);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file forward.tpl

`endif // FORWARD_SEQ_ITEM_SV
