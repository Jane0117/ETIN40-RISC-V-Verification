# QuestaSim UVM compile/run for cpu_tb_top
quit -sim

# Work from current directory to avoid tool defaulting to install path
set base_dir [file normalize [pwd]]
set logs_dir "$base_dir/logs"
file mkdir $logs_dir
catch {file delete -force $logs_dir/uvm_warning.log}
catch {file delete -force $logs_dir/uvm_error.log}
catch {file delete -force $logs_dir/transcript.log}
catch {file delete -force $base_dir/vsim.wlf}
catch {file delete -force $base_dir/wlft*}
catch {file delete -force $base_dir/work/_lock}
transcript file $logs_dir/transcript.log

# clean/create work library
catch {vdel -lib work -all}
catch {file delete -force $base_dir/work}
vlib work

# Compile design + TB via filelist
vlog -sv -timescale 1ns/1ps -f $base_dir/filelist.f

# Run simulation (override test with +UVM_TESTNAME=<name>)
vsim -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug \
     -l $logs_dir/sim_run.log \
     -do "run -all; quit -code 0" \
     work.cpu_tb_top \
     +UVM_TESTNAME=cpu_smoke_test \
     +UVM_VERBOSITY=UVM_MEDIUM

# Extract warnings/errors
set transcript_src [file normalize $logs_dir/transcript.log]
set warn_lines ""
set err_lines  ""
if {[file exists $transcript_src]} {
    catch { set warn_lines [exec grep -n "UVM_WARNING" $transcript_src] }
    catch { set err_lines  [exec grep -n "UVM_ERROR"   $transcript_src] }
    if {$warn_lines eq ""} { set warn_lines "no warning" }
    if {$err_lines eq ""}  { set err_lines  "no error"   }
    set fh [open "$logs_dir/uvm_warning.log" "w"]; puts $fh $warn_lines; close $fh
    set fh [open "$logs_dir/uvm_error.log" "w"];   puts $fh $err_lines;  close $fh
} else {
    puts "WARN: transcript file not found at $transcript_src"
}

# Optional coverage report (if coverage is enabled in your license/version)
if {![catch {coverage report -output $base_dir/coverage_report.txt -details -code bcesf -assert -cvg}]} {
    puts "INFO: coverage report written to $base_dir/coverage_report.txt"
} else {
    puts "INFO: coverage report not generated (unsupported or not enabled)"
}
