#!/bin/sh
IUS_HOME=`ncroot`
irun -vtimescale 1ns/1ps -uvmhome ${IUS_HOME}/tools/methodology/UVM/CDNS-1.2 \
+incdir+../tb/include \
+incdir+../tb/alu/sv \
+incdir+../tb/alu_top/sv \
+incdir+../tb/alu_top_test/sv \
+incdir+../tb/alu_top_tb/sv \
-F ../dut/files.f \
../tb/alu/sv/alu_pkg.sv \
../tb/alu/sv/alu_if.sv \
../tb/alu_top/sv/alu_top_pkg.sv \
../tb/alu_top_test/sv/alu_top_test_pkg.sv \
../tb/alu_top_tb/sv/alu_top_th.sv \
../tb/alu_top_tb/sv/alu_top_tb.sv \
+UVM_TESTNAME=alu_top_test +UVM_VERBOSITY=UVM_MEDIUM $* 
