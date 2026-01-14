# ============================================================
#   QuestaSim UVM Compile Script for joint_top_tb
# ============================================================

quit -sim

file mkdir logs
catch {file delete -force logs/transcript.log}
catch {file delete -force logs/uvm_warning.log}
catch {file delete -force logs/uvm_error.log}
catch {file delete -force vsim.wlf}
catch {file delete -force wlft*}
catch {file delete -force work/_lock}
catch {file delete -force work/@_opt}
catch {file delete -force work}
catch {vdel -lib work -all}
vlib work
transcript file logs/transcript.log

# ============================================================
# 1. Compile DUT (decode from generated_decode_tb, execute from exe_v1)
# ============================================================
# common/ctrl/regfile/decode_stage (use generated_execute_tb versions)
vlog ../../generated_execute_tb/dut/common.sv
vlog -sv ../../generated_execute_tb/dut/control.sv
vlog -sv ../../generated_execute_tb/dut/register_file.sv
vlog -sv ../../generated_execute_tb/dut/decode_stage.sv
# execute_stage and alu from exe_v1
vlog -sv ../../exe_v1/dut/alu.sv
vlog -sv ../../exe_v1/dut/execute_stage.sv

# ============================================================
# 2. Compile Agents
# ============================================================
set agent_list {decode_in decode_wb decode_out}
foreach ele $agent_list {
    set cmd "vlog -sv +incdir+../../generated_decode_tb/dut +incdir+../../generated_decode_tb/tb/include \
        +incdir+../../generated_decode_tb/tb/${ele}/sv \
        ../../generated_decode_tb/tb/${ele}/sv/${ele}_pkg.sv \
        ../../generated_decode_tb/tb/${ele}/sv/${ele}_if.sv"
    eval $cmd
}
# execute_out agent (from exe_v1)
vlog -sv +incdir+../../exe_v1/dut +incdir+../../exe_v1/tb/include \
    +incdir+../../exe_v1/tb/execute_out/sv \
    ../../exe_v1/tb/execute_out/sv/execute_out_pkg.sv \
    ../../exe_v1/tb/execute_out/sv/execute_out_if.sv

# ============================================================
# 3. Compile Joint ENV/TEST/TB
# ============================================================
vlog -sv \
    +incdir+../../generated_joint_tb/tb/include \
    +incdir+../../generated_joint_tb/tb/joint_top/sv \
    ../../generated_joint_tb/tb/joint_top/sv/joint_top_pkg.sv

# th + tb (with timescale)
vlog -sv -timescale 1ns/1ps \
    +incdir+../../generated_joint_tb/tb/include \
    +incdir+../../generated_joint_tb/tb/joint_top/sv \
    ../../generated_joint_tb/tb/joint_top/sv/joint_top_th.sv

vlog -sv -timescale 1ns/1ps \
    +incdir+../../generated_joint_tb/tb/include \
    +incdir+../../generated_joint_tb/tb/joint_top/sv \
    ../../generated_joint_tb/tb/joint_top/sv/joint_top_tb.sv

# ============================================================
# 4. Run Simulation
# ============================================================
vsim -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug \
     work.joint_top_tb \
     +UVM_TESTNAME=joint_top_test \
     +UVM_VERBOSITY=UVM_MEDIUM

run -all

# ============================================================
# 5. 保存 coverage 报告到 log
# ============================================================
set cov_db "logs/coverage.ucdb"
catch {coverage save $cov_db}
catch {vcover report -details -output "logs/coverage_report.txt" $cov_db}

# ============================================================
# 6. 保存 transcript 并提取 UVM_WARNING / UVM_ERROR
# ============================================================
set transcript_src [file normalize logs/transcript.log]
if {![file exists $transcript_src]} {
    puts "WARN: transcript file not found at $transcript_src"
} else {
    set warn_lines ""
    set err_lines  ""
    catch { set warn_lines [exec grep -n "UVM_WARNING" $transcript_src] }
    catch { set err_lines  [exec grep -n "UVM_ERROR"   $transcript_src] }
    if {$warn_lines eq ""} {
        set fh [open "logs/uvm_warning.log" "w"]
        puts $fh "no warning"
        close $fh
    } else {
        set fh [open "logs/uvm_warning.log" "w"]
        puts $fh $warn_lines
        close $fh
    }
    if {$err_lines eq ""} {
        set fh [open "logs/uvm_error.log" "w"]
        puts $fh "no error"
        close $fh
    } else {
        set fh [open "logs/uvm_error.log" "w"]
        puts $fh $err_lines
        close $fh
    }
}
