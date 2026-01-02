# Decode stage output monitor template

agent_name       = decode_out
trans_item       = decode_out_tx
agent_is_active  = UVM_PASSIVE
uvm_seqr_class   = yes

# Interface ports
if_port = logic [4:0]   reg_rd_id;
if_port = logic [31:0]  read_data1;
if_port = logic [31:0]  read_data2;
if_port = logic [31:0]  immediate_data;
if_port = logic [31:0]  pc_out;
if_port = logic         instruction_illegal;
if_port = control_type  control_signals;

# Transaction fields (sampled by monitor)
trans_var = logic [4:0]   reg_rd_id;
trans_var = logic [31:0]  read_data1;
trans_var = logic [31:0]  read_data2;
trans_var = logic [31:0]  immediate_data;
trans_var = logic [31:0]  pc_out;
trans_var = logic         instruction_illegal;
trans_var = control_type  control_signals;
