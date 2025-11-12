// Scoreboard connections are managed in execute_top_env.sv:
//  - execute_out_monitor.analysis_port feeds the actual FIFO.
//  - execute_stage_ref_model.ref_ap feeds the expected FIFO.
//  - execute_stage_scoreboard reads both FIFOs and performs the comparison.
