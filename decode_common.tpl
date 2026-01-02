# Common template for decode_stage UVM TB generation

# Mandatory
dut_top   = decode_stage

# Paths
# Point to the folder containing decode_stage.sv
dut_source_path = D:/IC-Project/ICP2-Verification/phase-2/easier_uvm_gen-2017-01-19/generated_execute_tb/dut

# Local include dir for any user inserts
inc_path  = include

# Pinlist mapping between interface signals and DUT ports
dut_pfile = decode_pinlist

# Output location (relative to this repo)
project   = generated_decode_tb

# Optional cosmetics
prefix    = decode_top

# Time units (adjust if needed)
timeunit      = 1ns
timeprecision = 1ps

# Keep backups of generated files? (yes/no)
backup = no

# UVM command line options used by provided run scripts
uvm_cmdline = +UVM_VERBOSITY=UVM_MEDIUM
