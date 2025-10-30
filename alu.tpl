# ALU agent/interface template for Easier UVM

agent_name = alu
trans_item = alu_seq_item
uvm_seqr_class = yes

# Interface ports (match DUT ports and widths)
if_port = logic [3:0]   control;
if_port = logic [31:0]  left_operand;
if_port = logic [31:0]  right_operand;
if_port = logic         zero_flag;
if_port = logic [31:0]  result;
if_port = logic         overflow;

# If your ALU is purely combinational, omit clock/reset.
# If there is a clock, uncomment and set appropriately:
# if_port = logic clk;
# if_clock = clk

# Transaction fields (what driver/monitor will send/observe)
trans_var = rand logic [3:0]   control;
trans_var = rand logic [31:0]  left_operand;
trans_var = rand logic [31:0]  right_operand;
trans_var =      logic         zero_flag;
trans_var =      logic [31:0]  result;
trans_var =      logic         overflow;

