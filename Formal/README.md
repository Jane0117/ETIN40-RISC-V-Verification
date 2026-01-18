# Formal (decode + execute)

This folder follows the FPV_ref structure for VC Formal FPV.

## Structure
- `Formal/design/` RTL wrapper and filelist
- `Formal/sva/` SVA assertions and bind file
- `Formal/run/` run scripts
- `Formal/solution/` legacy files (not used by run scripts)

## Notes
- RTL files are referenced from `generated_decode_tb/dut` via `Formal/design/filelist`.
- Top wrapper: `Formal/design/decode_execute_top.sv`.
- Update `Formal/sva/decode_execute.sva` with your assertions.
