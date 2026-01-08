# ============================================================
#   QuestaSim UVM Compile Script for execute_top_tb
# ============================================================

quit -sim

set base_dir [file normalize [file dirname [info script]]]
set logs_dir "$base_dir/logs"
set dut_dir  "$base_dir/dut"
set tb_dir   "$base_dir/tb"

file mkdir $logs_dir
catch {file delete -force $logs_dir/uvm_warning.log}
catch {file delete -force $logs_dir/uvm_error.log}
catch {file delete -force $logs_dir/transcript.log}
catch {file delete -force $base_dir/vsim.wlf}
catch {file delete -force $base_dir/wlft*}
catch {file delete -force $base_dir/work/_lock}
transcript file $logs_dir/transcript.log

catch {vdel -lib work -all}
catch {file delete -force $base_dir/work}
vlib work

# ============================================================
# 1. Compile DUT
# ============================================================

vlog -sv $dut_dir/common.sv
vlog -sv $dut_dir/alu.sv
vlog -sv $dut_dir/execute_stage.sv

# ============================================================
# 2. Compile Agents
# ============================================================

set tb_name execute_top
set agent_list { execute_in execute_out }

foreach ele $agent_list {
    set cmd "vlog -sv \
        +incdir+$dut_dir \
        +incdir+$tb_dir/include \
        +incdir+$tb_dir/${ele}/sv \
        $tb_dir/${ele}/sv/${ele}_pkg.sv"
    eval $cmd

    set cmd "vlog -sv \
        +incdir+$dut_dir \
        +incdir+$tb_dir/include \
        +incdir+$tb_dir/${ele}/sv \
        $tb_dir/${ele}/sv/${ele}_if.sv"
    eval $cmd
}

# ============================================================
# 3. Compile ENV
# ============================================================

set cmd "vlog -sv \
        +incdir+$dut_dir \
        +incdir+$tb_dir/include \
        +incdir+$tb_dir/${tb_name}/sv \
        $tb_dir/${tb_name}/sv/${tb_name}_pkg.sv"
eval $cmd

# ============================================================
# 4. Compile TEST
# ============================================================

set cmd "vlog -sv \
        +incdir+$dut_dir \
        +incdir+$tb_dir/include \
        +incdir+$tb_dir/${tb_name}_test/sv \
        $tb_dir/${tb_name}_test/sv/${tb_name}_test_pkg.sv"
eval $cmd

# ============================================================
# 5. Compile TB (th + tb)
# ============================================================

set cmd "vlog -sv -timescale 1ns/1ps \
        +incdir+$dut_dir \
        +incdir+$tb_dir/include \
        +incdir+$tb_dir/${tb_name}_tb/sv \
        $tb_dir/${tb_name}_tb/sv/${tb_name}_th.sv"
eval $cmd

set cmd "vlog -sv -timescale 1ns/1ps \
        +incdir+$dut_dir \
        +incdir+$tb_dir/include \
        +incdir+$tb_dir/${tb_name}_tb/sv \
        $tb_dir/${tb_name}_tb/sv/${tb_name}_tb.sv"
eval $cmd

# ============================================================
# 6. Run Simulation
# ============================================================

vsim -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug \
     work.execute_top_tb \
     +UVM_TESTNAME=execute_top_test \
     +UVM_VERBOSITY=UVM_MEDIUM

run -all

# ============================================================
# 7. Save transcript and extract UVM warnings/errors
# ============================================================

set transcript_src [file normalize $logs_dir/transcript.log]
if {![file exists $transcript_src]} {
    puts "WARN: transcript file not found at $transcript_src"
} else {
    set warn_lines ""
    set err_lines  ""
    catch { set warn_lines [exec grep -n "UVM_WARNING" $transcript_src] }
    catch { set err_lines  [exec grep -n "UVM_ERROR"   $transcript_src] }
    if {$warn_lines eq ""} {
        set fh [open "$logs_dir/uvm_warning.log" "w"]
        puts $fh "no warning"
        close $fh
    } else {
        set fh [open "$logs_dir/uvm_warning.log" "w"]
        puts $fh $warn_lines
        close $fh
    }
    if {$err_lines eq ""} {
        set fh [open "$logs_dir/uvm_error.log" "w"]
        puts $fh "no error"
        close $fh
    } else {
        set fh [open "$logs_dir/uvm_error.log" "w"]
        puts $fh $err_lines
        close $fh
    }
}
coverage report -output $base_dir/coverage_report.txt -details -code bcesf -assert -cvg
