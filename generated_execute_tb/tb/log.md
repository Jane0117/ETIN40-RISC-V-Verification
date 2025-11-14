# 修改记录
- 2025-11-14: 在 `execute_top_env` 中通过 `uvm_config_db` 把 execute_in/forward driver 与 monitor 的 `vif` 提前传给工厂实例，同时让 FIFO 的 `blocking_get_export` 连接到参考模型与 scoreboard 的 `uvm_blocking_get_port`，从而满足接口要求并消除连接错误。
- 2025-11-14: 将 `execute_stage_scoreboard` 与 `execute_stage_ref_model` 中的 `uvm_blocking_get_port` 替换为 `uvm_get_peek_port`，以满足 `uvm_tlm_analysis_fifo::get_peek_export` 需要 `uvm_get_peek_imp` 接口的约束。
- 2025-11-14: 调整 `execute_top_env` 的 connect_phase，将各 `uvm_get_peek_port`（ref model 与 scoreboard）主动连接到 FIFO 的 `get_peek_export`，避免直接调用 imp 上的 `connect()` 并解决连接计数错误。
- 2025-11-14: 记录 `vlog` 编译路径（`../tb/execute_top/sv/execute_top_pkg.sv`）来确保在 `sim` 目录下运行时能正确定位覆盖所有被 `include` 的组件。
- 2025-11-14: 捕获 `uvm_warning.log` 中的四条 warning（execute_in/forward 的 driver 及 monitor 在 build_phase 里 `m_config` 为 null），解决办法是在 agent 创建这些组件后立即把 `m_config` 赋给它们，让 build_phase 能拿到 config，避免警告。
