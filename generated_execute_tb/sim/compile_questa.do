# ============================================================
#   QuestaSim UVM Compile Script for execute_top_tb (with WARNING extraction)
# ============================================================

quit -sim

# Create logs directory if not exists
file mkdir logs

# Clean work library
file delete -force work
vlib work

# ============================================================
# 1. Compile DUT
# ============================================================

vlog ../dut/common.sv

set cmd "vlog -sv -F ../dut/files.f"
eval $cmd

# ============================================================
# 2. Compile Agents
# ============================================================

set tb_name execute_top
set agent_list { execute_in forward execute_out }

foreach ele $agent_list {
    set cmd "vlog -sv \
        +incdir+../dut \
        +incdir+../tb/include \
        +incdir+../tb/${ele}/sv \
        ../tb/${ele}/sv/${ele}_pkg.sv \
        ../tb/${ele}/sv/${ele}_if.sv"
    eval $cmd
}

# ============================================================
# 3. Compile ENV
# ============================================================

set cmd "vlog -sv \
        +incdir+../dut \
        +incdir+../tb/include \
        +incdir+../tb/${tb_name}/sv \
        ../tb/${tb_name}/sv/${tb_name}_pkg.sv"
eval $cmd

# ============================================================
# 4. Compile TEST
# ============================================================

set cmd "vlog -sv \
        +incdir+../dut \
        +incdir+../tb/include \
        +incdir+../tb/${tb_name}_test/sv \
        ../tb/${tb_name}_test/sv/${tb_name}_test_pkg.sv"
eval $cmd

# ============================================================
# 5. Compile TB (th + tb)
# ============================================================

set cmd "vlog -sv -timescale 1ns/1ps \
        +incdir+../dut \
        +incdir+../tb/include \
        +incdir+../tb/${tb_name}_tb/sv \
        ../tb/${tb_name}_tb/sv/${tb_name}_th.sv"
eval $cmd

set cmd "vlog -sv -timescale 1ns/1ps \
        +incdir+../dut \
        +incdir+../tb/include \
        +incdir+../tb/${tb_name}_tb/sv \
        ../tb/${tb_name}_tb/sv/${tb_name}_tb.sv"
eval $cmd

# ============================================================
# 6. Run Simulation (using Questa built-in UVM)
# ============================================================

vsim -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug \
     work.execute_top_tb \
     +UVM_TESTNAME=execute_top_test \
     +UVM_VERBOSITY=UVM_MEDIUM

run -all

# ============================================================
# 7. Extract all UVM_WARNING from transcript
# ============================================================

exec grep "UVM_WARNING" transcript > logs/uvm_warning.log
