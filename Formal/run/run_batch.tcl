#------------------------------------------------------------
# VC Formal FPV - decode + execute
#------------------------------------------------------------

# Enable Formal Property Verification mode
set_fml_appmode FPV

# Set top module name
set design decode_execute_top

# Read RTL and SVA files
analyze -format sverilog \
   -vcs {-f ../design/filelist +define+INLINE_SVA \
   ../sva/decode_execute.sva ../sva/bind_decode_execute.sva}

# Elaborate design (expand hierarchy and bind SVA)
elaborate $design -sva

# Add missing clk and rst
create_clock clk -period 10
create_reset reset_n -sense low

# Initialize DUT
sim_run -stable
sim_save_reset

# Save results
check_fv -block
report_fv -list > results.txt

# Save session
save_session -session batch_results
