# Common template for ALU UVM TB generation

# Mandatory
dut_top   = alu

# Paths
# Point to the folder containing alu.sv
dut_source_path = D:/RISC-V/ICP-rv/code/RISC-V-main/RISC-V-main/SystemVerilog/Design

# Local include dir for any user inserts
inc_path  = include

# Pinlist mapping between interface signals and DUT ports
dut_pfile = alu_pinlist

# Output location (relative to this repo)
project   = generated_alu_tb

# Optional cosmetics
prefix    = alu_top

# Time units (adjust if needed)
timeunit      = 1ns
timeprecision = 1ps

# Keep backups of generated files? (yes/no)
backup = no

# UVM command line options used by provided run scripts
uvm_cmdline = +UVM_VERBOSITY=UVM_MEDIUM

