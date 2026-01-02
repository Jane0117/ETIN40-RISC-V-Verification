# Decode stage register writeback agent template

agent_name      = decode_wb
trans_item      = decode_wb_tx
uvm_seqr_class  = yes
agent_is_active = UVM_ACTIVE

# Interface ports
if_port = logic clk;
if_port = logic reset_n;
if_clock = clk
if_reset = reset_n
if_port = logic        write_en;
if_port = logic [4:0]  write_id;
if_port = logic [31:0] write_data;

# Transaction fields
trans_var = rand logic        write_en;
trans_var = rand logic [4:0]  write_id;
trans_var = rand logic [31:0] write_data;
