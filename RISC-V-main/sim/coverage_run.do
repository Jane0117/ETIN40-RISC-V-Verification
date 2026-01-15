catch {vdel -lib work -all}
vlib work
vlog -cover bcesft -sv -timescale 1ns/1ps -f filelist.f
vsim -coverage -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug work.cpu_tb_top +UVM_TESTNAME=cpu_smoke_test +UVM_VERBOSITY=UVM_MEDIUM -do "run -all; coverage save coverage.ucdb; coverage report -output coverage_report.txt -details -code bcesf -assert -cvg; quit -code 0"
