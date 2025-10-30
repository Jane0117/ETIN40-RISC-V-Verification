# Easier UVM ALU Environment Setup

This folder is prepared to generate a UVM verification environment for the ALU design using the Easier UVM generator script `easier_uvm_gen.pl`.

## What Was Added
- `common.tpl` - Common template configuring the DUT path, project output, and options.
- `alu.tpl` - Agent/interface template for the ALU (ports and transaction fields).
- `alu_pinlist` - Pin mapping between the generated interface and DUT ports (first line `!alu_if`).
- `include/` - Placeholder include directory for any user inserts (created if missing).

## DUT Location
- The DUT is expected at: `D:/RISC-V/ICP-rv/code/RISC-V-main/RISC-V-main/SystemVerilog/Design/alu.sv`.
- Adjust `dut_top` and `dut_source_path` in `common.tpl` if your module name or path differs.

## Prerequisites
- Perl (recommended: Strawberry Perl on Windows).
- Perl module `File::Copy::Recursive` (bundled with Strawberry Perl; otherwise install via CPAN).

Quick way to use Strawberry Perl for the current PowerShell session:
- `$env:Path = "E:\\Strawberry\\perl\\bin;E:\\Strawberry\\c\\bin;$env:Path"`
- Verify: `Get-Command perl | Select-Object -ExpandProperty Source`

## How To Generate
From this directory:

- Template-based generation (recommended)
  - `perl .\\easier_uvm_gen.pl -m .\\common.tpl .\\alu.tpl`

- Alternative: using the `.if` control file you edited
  - `perl .\\easier_uvm_gen.pl .\\alu.if`
  - Note: `.if` must use keys recognized by the generator (e.g., `if_port`, `trans_var`). If it doesn't, prefer the template-based flow above.

Generated files will be written to the folder set by `project` in `common.tpl` (default: `generated_alu_tb`). Simulator helper scripts (Questa/VCS/IUS/Riviera) are included there.

## Generated Structure
With `project = generated_alu_tb`, the generator lays out files like this (names use `agent = alu` and `prefix = alu_top`):

- `generated_alu_tb/dut/`
  - DUT sources gathered for convenience and `files.f` (compile list)

- `generated_alu_tb/sim/`
  - `compile_questa.do`, `compile_riviera.do`, `compile_ius.sh`, `compile_vcs.sh` - simulator helper scripts that use `files.f` and `uvm_cmdline`

- `generated_alu_tb/tb/alu/sv/` (agent-level)
  - `alu_pkg.sv` - agent package and includes
  - `alu_if.sv` - interface matching `alu_pinlist`
  - `alu_seq_item.sv` - sequence item (transaction)
  - `alu_sequencer.sv` - sequencer class (since `uvm_seqr_class = yes`)
  - `alu_driver.sv` - drives the interface from sequence items
  - `alu_monitor.sv` - samples the interface and publishes transactions
  - `alu_config.sv` - agent configuration object
  - `alu_coverage.sv` - coverage subscriber skeleton (if enabled)
  - `alu_agent.sv` - agent tying driver/monitor/sequencer together
  - `alu_seq_lib.sv` - default sequences for the agent

- `generated_alu_tb/tb/alu_top/sv/` (top-level env)
  - `alu_top_pkg.sv` - top-level package
  - `alu_top_env.sv` - environment connecting one or more agents
  - `alu_top_config.sv` - top-level configuration (can contain agent configs)
  - `alu_top_seq_lib.sv` - virtual sequences coordinating agents

- `generated_alu_tb/tb/alu_top_tb/sv/` (modules)
  - `alu_top_tb.sv` - UVM testbench module calling `run_test()`
  - `alu_top_th.sv` - test harness; instantiates the DUT and interfaces, clock/reset if configured

- `generated_alu_tb/tb/alu_top_test/sv/` (tests)
  - `alu_top_test_pkg.sv` - test package
  - `alu_top_test.sv` - default test class

Depending on options (e.g., register model), additional files such as adapters, reg coverage, or a port converter may be generated.

## Customization Checklist
- Module name: update `dut_top` in `common.tpl` if not `alu`.
- DUT path: update `dut_source_path` in `common.tpl` to the folder containing `alu.sv`.
- Pin mapping: confirm names in `alu_pinlist` match DUT port names exactly.
- Clock/reset: if ALU uses a clock, add it in `alu.tpl`:
  - `if_port = logic clk;` and `if_clock = clk`
  - Optionally enable clock/reset generation in `common.tpl`.
- Transactions: trim or adjust `trans_var` in `alu.tpl` to reflect what the driver drives vs. monitor samples.

## Troubleshooting
- Error: `Can't locate File/Copy/Recursive.pm` - use Strawberry Perl or install the module with `cpan install File::Copy::Recursive`.
- If a simulator script fails, inspect the auto-generated `files.f` and prune/adjust as needed.

## Notes
- Backups for generated files are disabled via `backup = no` in `common.tpl` (enable if desired).
- UVM verbosity can be adjusted via `uvm_cmdline` in `common.tpl`.


