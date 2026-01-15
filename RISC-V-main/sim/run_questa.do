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

# Compile design + TB via filelist (enable coverage)
vlog -cover bcesf -sv -timescale 1ns/1ps -f $base_dir/filelist.f

# Env overrides:
#   RUN_ALL=1              -> run regression list below (batch)
#   UVM_TESTNAME=<name>    -> single test name (default: cpu_full_cov_nocompress_test)
#   UVM_VERBOSITY=<lvl>    -> verbosity (default: UVM_MEDIUM)
#   KEEP_VSIM_OPEN=0       -> single run batch exit; else GUI stays open
set run_all   [expr {[info exists ::env(RUN_ALL)]       ? $::env(RUN_ALL)       : 0}]
set testname  [expr {[info exists ::env(UVM_TESTNAME)]  ? $::env(UVM_TESTNAME)  : "cpu_full_cov_nocompress_test"}]
set verbosity [expr {[info exists ::env(UVM_VERBOSITY)] ? $::env(UVM_VERBOSITY) : "UVM_MEDIUM"}]
set keep_open [expr {[info exists ::env(KEEP_VSIM_OPEN)]? $::env(KEEP_VSIM_OPEN): 1}]

# Regression list (可根据需要增减)
set test_list {cpu_full_cov_nocompress_test cpu_full_cov_compress_test cpu_opcode_gap_test cpu_cov_gap2_test}

proc run_one {test verbosity logs_dir} {
    set log_file "$logs_dir/run_$test.log"
    set ucdb_file "$logs_dir/coverage_$test.ucdb"
    puts "=== Running $test ==="
    eval vsim -coverage -c -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug \
         -l $log_file \
         -do \"run -all; coverage save $ucdb_file; quit -code 0\" \
         work.cpu_tb_top \
         +UVM_TESTNAME=$test \
         +UVM_VERBOSITY=$verbosity
}

if {$run_all} {
    # batch regression
    foreach t $test_list { run_one $t $verbosity $logs_dir }
    # merge all UCDBs
    set ucdbs ""
    foreach t $test_list {
        set f "$logs_dir/coverage_$t.ucdb"
        if {[file exists $f]} { lappend ucdbs $f }
    }
    if {[llength $ucdbs] > 0} {
        eval exec vcover merge $base_dir/coverage_merged_cli.ucdb $ucdbs
        puts "INFO: merged coverage written to $base_dir/coverage_merged_cli.ucdb"
    } else {
        puts "WARN: no UCDB files found to merge"
    }
} else {
    # single run (GUI unless KEEP_VSIM_OPEN=0)
    set run_cmd   "run -all"
    set vsim_mode ""
    if {!$keep_open} {
        set vsim_mode "-c"
        set run_cmd   "run -all; quit -code 0"
    }
    eval vsim $vsim_mode -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug \
         -l $logs_dir/sim_run.log \
         -do \"$run_cmd\" \
         work.cpu_tb_top \
         +UVM_TESTNAME=$testname \
         +UVM_VERBOSITY=$verbosity

    # Save coverage database automatically
    if {![catch {coverage save $logs_dir/coverage_latest.ucdb}]} {
        puts "INFO: coverage saved to $logs_dir/coverage_latest.ucdb"
    } else {
        puts "INFO: coverage save failed (unsupported or not enabled)"
    }
}

# Extract warnings/errors (from single-run transcript)
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
