# Execute stage output monitor template

agent_name       = execute_out
trans_item       = execute_out_tx
agent_is_active  = UVM_PASSIVE
uvm_seqr_class   = yes
agent_append_to_connect_phase = my_exec_scoreboard_connect.sv inline

# Interface ports
if_port = control_type control_out;
if_port = logic [31:0] alu_data;
if_port = logic [31:0] memory_data;
if_port = logic        pc_src;
if_port = logic [31:0] jalr_target_offset;
if_port = logic        jalr_flag;
if_port = logic [31:0] pc_out;
if_port = logic        overflow;

# Transaction fields (sampled by monitor)
trans_var = control_type control_out;
trans_var = logic [31:0] alu_data;
trans_var = logic [31:0] memory_data;
trans_var = logic       pc_src;
trans_var = logic [31:0] jalr_target_offset;
trans_var = logic       jalr_flag;
trans_var = logic [31:0] pc_out;
trans_var = logic       overflow;
