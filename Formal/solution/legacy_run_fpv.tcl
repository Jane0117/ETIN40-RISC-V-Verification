# Minimal FPV script skeleton. Tune commands for your formal tool.

set TOP decode_execute_top

# Read RTL
read_file -format sverilog -f Formal/rtl/filelist.f

# Read assertions/properties
read_file -format sverilog Formal/properties/decode_execute_props.sv

# Set top and elaborate
set_top $TOP
elaborate

# Constraints (clock/reset)
source Formal/constraints/constraints.tcl

# Run proofs
# Common VC Formal flow:
#   reset
#   prove -all
if {[info commands prove] ne ""} {
    prove -all
}
