
# ============================================================
#   QuestaSim UVM Compile Script for decode_top_tb (with WARNING extraction)
# ============================================================

quit -sim

# Create logs directory if not exists
file mkdir logs
# Clean previous run artifacts (ignore permission errors)
catch {file delete -force logs/uvm_warning.log}
catch {file delete -force logs/uvm_error.log}
catch {file delete -force logs/transcript.log}
catch {file delete -force vsim.wlf}
catch {file delete -force wlft*}
catch {file delete -force work/_lock}
# Set new transcript path after cleanup
transcript file logs/transcript.log

# Clean work library
catch {vdel -lib work -all}
catch {file delete -force work}
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

set tb_name decode_top
set agent_list { decode_in decode_wb decode_out }

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
     work.decode_top_tb \
     +UVM_TESTNAME=decode_top_test \
     +UVM_VERBOSITY=UVM_MEDIUM

run -all

# ============================================================
# 7. 保存 transcript 并提取 UVM_WARNING
# ============================================================

set transcript_src [file normalize logs/transcript.log]
if {![file exists $transcript_src]} {
    puts "WARN: transcript file not found at $transcript_src"
} else {
    # 抓取 warning/error，若为空则写入占位说明
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
coverage report -output coverage_report.txt -details -code bcesf -assert -cvg
