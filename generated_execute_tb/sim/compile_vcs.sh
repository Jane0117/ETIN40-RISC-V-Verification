#!/bin/sh
vcs -sverilog +acc +vpi -timescale=1ns/1ps -ntb_opts uvm-1.2 \
+incdir+../tb/include \
+incdir+../tb/decode_in/sv \
+incdir+../tb/forward/sv \
+incdir+../tb/execute_out/sv \
+incdir+../tb/execute_top/sv \
+incdir+../tb/execute_top_test/sv \
+incdir+../tb/execute_top_tb/sv \
-F ../dut/files.f \
../tb/decode_in/sv/decode_in_pkg.sv \
../tb/decode_in/sv/decode_in_if.sv \
../tb/forward/sv/forward_pkg.sv \
../tb/forward/sv/forward_if.sv \
../tb/execute_out/sv/execute_out_pkg.sv \
../tb/execute_out/sv/execute_out_if.sv \
../tb/execute_top/sv/execute_top_pkg.sv \
../tb/execute_top_test/sv/execute_top_test_pkg.sv \
../tb/execute_top_tb/sv/execute_top_th.sv \
../tb/execute_top_tb/sv/execute_top_tb.sv \
-R +UVM_TESTNAME=execute_top_test +UVM_VERBOSITY=UVM_MEDIUM $* 
