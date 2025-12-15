# Common template for execute_stage UVM TB generation

# Mandatory
dut_top   = execute_stage

# Paths
# Point to the folder containing execute_stage.sv
dut_source_path = D:/IC-Project/ICP2-Verification/phase-2/RISC-V-main/RISC-V-main/SystemVerilog/Design

# Local include dir for any user inserts
inc_path  = include

# Pinlist mapping between interface signals and DUT ports
dut_pfile = execute_pinlist

# Output location (relative to this repo)
project   = generated_execute_tb

# Optional cosmetics
prefix    = execute_top

# Time units (adjust if needed)
timeunit      = 1ns
timeprecision = 1ps

# Keep backups of generated files? (yes/no)
backup = no

# UVM command line options used by provided run scripts
uvm_cmdline = +UVM_VERBOSITY=UVM_MEDIUM
