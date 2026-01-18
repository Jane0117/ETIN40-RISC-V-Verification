#------------------------------------------------------------
# VC Formal Lab 5 - Traffic Light Controller
#------------------------------------------------------------

# Enable Formal Property Verification mode
set_fml_appmode FPV

# Set top module name
set design traffic

# Read RTL and SVA files
analyze -format sverilog \
   -vcs {-f ../design/filelist +define+INLINE_SVA \
   ../sva/traffic.sva ../sva/bind_traffic.sva}

# Elaborate design (expand hierarchy and bind SVA)
elaborate $design -sva
#Add missing clk and rst

create_clock clk -period 100
create_reset rst -sense high

# Initialize DUT
sim_run -stable
sim_save_reset
