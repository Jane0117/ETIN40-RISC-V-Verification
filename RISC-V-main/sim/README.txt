UVM Testbench

- Compile: vlog -f sim/filelist.f
- Run:     vsim -c cpu_tb_top +UVM_TESTNAME=cpu_smoke_test -do "run -all; quit -f"

Tests:
  cpu_smoke_test
  cpu_mem_test
  cpu_branch_test
  cpu_compress_test
  cpu_hazard_test
  cpu_random_alu_test

Optional plusargs:
  +MAX_CYCLES=<n>
  +RAND_COUNT=<n>   (for cpu_random_alu_test)
