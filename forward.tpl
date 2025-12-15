# Forwarding network agent template

agent_name      = forward
trans_item      = forward_tx
uvm_seqr_class  = yes
agent_is_active = UVM_ACTIVE

# Interface ports
if_port = logic [31:0] wb_forward_data;
if_port = logic [31:0] mem_forward_data;
if_port = forward_type forward_rs1;
if_port = forward_type forward_rs2;

# Transaction fields
trans_var = rand logic [31:0] wb_forward_data;
trans_var = rand logic [31:0] mem_forward_data;
trans_var = rand forward_type  forward_rs1;
trans_var = rand forward_type  forward_rs2;

