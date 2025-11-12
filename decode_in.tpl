# Decode → Execute agent template

agent_name     = decode_in
trans_item     = decode_tx
uvm_seqr_class = yes
agent_is_active = UVM_ACTIVE

# Interface ports
if_port = logic [31:0] data1;
if_port = logic [31:0] data2;
if_port = logic [31:0] immediate_data;
if_port = logic [31:0] pc_in;
if_port = control_type control_in;

# Transaction fields
trans_var = rand logic [31:0] data1;
trans_var = rand logic [31:0] data2;
trans_var = rand logic [31:0] immediate_data;
trans_var = rand logic [31:0] pc_in;
trans_var = rand control_type  control_in;

