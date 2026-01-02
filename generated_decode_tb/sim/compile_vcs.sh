#!/bin/sh
vcs -sverilog +acc +vpi -timescale=1ns/1ps -ntb_opts uvm-1.2 \
+incdir+../tb/include \
+incdir+../tb/decode_in/sv \
+incdir+../tb/decode_wb/sv \
+incdir+../tb/decode_out/sv \
+incdir+../tb/decode_top/sv \
+incdir+../tb/decode_top_test/sv \
+incdir+../tb/decode_top_tb/sv \
-F ../dut/files.f \
../tb/decode_in/sv/decode_in_pkg.sv \
../tb/decode_in/sv/decode_in_if.sv \
../tb/decode_wb/sv/decode_wb_pkg.sv \
../tb/decode_wb/sv/decode_wb_if.sv \
../tb/decode_out/sv/decode_out_pkg.sv \
../tb/decode_out/sv/decode_out_if.sv \
../tb/decode_top/sv/decode_top_pkg.sv \
../tb/decode_top_test/sv/decode_top_test_pkg.sv \
../tb/decode_top_tb/sv/decode_top_th.sv \
../tb/decode_top_tb/sv/decode_top_tb.sv \
-R +UVM_TESTNAME=decode_top_test +UVM_VERBOSITY=UVM_MEDIUM $* 
