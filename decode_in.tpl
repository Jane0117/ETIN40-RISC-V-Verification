# Decode stage instruction/PC input agent template

agent_name     = decode_in
trans_item     = decode_in_tx
uvm_seqr_class = yes
agent_is_active = UVM_ACTIVE

# Interface ports
if_port = logic clk;
if_port = logic reset_n;
if_clock = clk
if_reset = reset_n
if_port = instruction_type instruction;
if_port = logic [31:0] pc_in;

# Transaction fields
trans_var = rand instruction_type instruction;
trans_var = rand logic [31:0] pc_in;
