# QuestaSim UVM compile/run for cpu_tb_top
quit -sim

# Work from current directory to avoid tool defaulting to install path
set base_dir [file normalize [pwd]]
set logs_dir "$base_dir/logs"

# Optional suffix to keep per-test logs separate (set LOG_SUFFIX before invoking)
set log_suffix ""
if {[info exists LOG_SUFFIX]} {
    set log_suffix $LOG_SUFFIX
} elseif {[info exists ::env(LOG_SUFFIX)]} {
    set log_suffix $::env(LOG_SUFFIX)
}
if {$log_suffix ne ""} {
    set log_tag "_$log_suffix"
} else {
    set log_tag ""
}

set sim_log "$logs_dir/sim_run${log_tag}.log"
set transcript_file "$logs_dir/transcript${log_tag}.log"
set warn_log "$logs_dir/uvm_warning${log_tag}.log"
set err_log "$logs_dir/uvm_error${log_tag}.log"

file mkdir $logs_dir
catch {file delete -force $warn_log}
catch {file delete -force $err_log}
catch {file delete -force $transcript_file}
catch {file delete -force $base_dir/vsim.wlf}
catch {file delete -force $base_dir/wlft*}
catch {file delete -force $base_dir/work/_lock}
transcript file $transcript_file

# Select test (can override by `set TESTNAME <name>` or env TESTNAME before sourcing)
set testname "cpu_smoke_test"
if {[info exists TESTNAME]} {
    set testname $TESTNAME
} elseif {[info exists ::env(TESTNAME)]} {
    set testname $::env(TESTNAME)
}

# Optional extra plusargs from env EXTRA_PLUSARGS (e.g., "+MAX_CYCLES=25000")
set extra_plusargs ""
if {[info exists EXTRA_PLUSARGS]} {
    set extra_plusargs $EXTRA_PLUSARGS
} elseif {[info exists ::env(EXTRA_PLUSARGS)]} {
    set extra_plusargs $::env(EXTRA_PLUSARGS)
}

# clean/create work library
catch {vdel -lib work -all}
catch {file delete -force $base_dir/work}
vlib work

# Compile design + TB via filelist
vlog -sv -timescale 1ns/1ps -f $base_dir/filelist.f

# Run simulation (override test with +UVM_TESTNAME=<name>)
vsim -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug \
     -l $sim_log \
     -do "run -all; quit -code 0" \
     work.cpu_tb_top \
     +UVM_TESTNAME=$testname \
     +UVM_VERBOSITY=UVM_MEDIUM \
     $extra_plusargs

# Extract warnings/errors
set transcript_src [file normalize $transcript_file]
set warn_lines ""
set err_lines  ""
if {[file exists $transcript_src]} {
    catch { set warn_lines [exec grep -n "UVM_WARNING" $transcript_src] }
    catch { set err_lines  [exec grep -n "UVM_ERROR"   $transcript_src] }
    if {$warn_lines eq ""} { set warn_lines "no warning" }
    if {$err_lines eq ""}  { set err_lines  "no error"   }
    set fh [open $warn_log "w"]; puts $fh $warn_lines; close $fh
    set fh [open $err_log "w"];   puts $fh $err_lines;  close $fh
} else {
    puts "WARN: transcript file not found at $transcript_src"
}

# Optional coverage report (if coverage is enabled in your license/version)
if {![catch {coverage report -output $base_dir/coverage_report.txt -details -code bcesf -assert -cvg}]} {
    puts "INFO: coverage report written to $base_dir/coverage_report.txt"
} else {
    puts "INFO: coverage report not generated (unsupported or not enabled)"
}
