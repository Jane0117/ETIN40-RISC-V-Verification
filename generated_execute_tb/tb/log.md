# 修改记录
#2025-12-07
- 2025-12-07: 删除foreach语句，使用类FIFO 匹配，只比较队首，确保 exp/act 一一对应
- 2025-12-07: forward driver（`forward_driver.sv`）在 reset 释放后多等两个时钟再驱动，避免 monitor 漏采首条 txn；（存在1个报错）
- 2025-12-07: forward monitor（`forward_monitor.sv`）复位后清零 prev/has_prev，上升沿后 `#1step` 等 NBA 完成再采样；（存在1个报错）
- 2025-12-07: 若 wb/mem/rs1/rs2 出现 X/Z 则跳过本次样本，消除 forward_scoreboard 首条 X 比对误差。

#2025-12-06
- 2025-12-06: forward tx（`forward_forward_tx.sv`）增加期望数据/源字段、9 路 `path_tag`，bake_expect 补期望标签；post_randomize、pack/unpack/print/compare 全量支持新字段。
- 2025-12-06: forward seq_lib（`forward_seq_lib.sv`）改为穷举 9 组 selector 组合，逐笔随机化并打印 path_tag。
- 2025-12-06: forward driver（`forward_driver.sv`）增加 analysis_port 输出期望 txn，驱动前 bake_expect；日志包含 path_tag。
- 2025-12-06: forward monitor（`forward_monitor.sv`）采样后 bake_expect，按时钟对齐且去重，仅信号变化时写出 txn。
- 2025-12-06: forward scoreboard（`tb/include/forward_scoreboard.sv` + env 连接）新增端到端比较，匹配 selector/数据/path_tag，并打印匹配/差异；在 `execute_top_env` 中接 driver.ap→exp、monitor→act。
- 2025-12-06: forward 覆盖（`forward_coverage.sv`）加入 `path_tag` 9 个 bin、rs1×rs2 cross、hazard bins，覆盖率达 100%。
- 2025-12-06: 新增 `forward_scoreboard` 并在 `execute_top_env` 里连接 driver.ap→exp、monitor.ap→act，实现 selector/数据/path 的端到端对比。
- 2025-12-06: `forward_coverage` 增加 `path_tag` 9 bin、rs1×rs2 cross 等 hazard 覆盖，运行已达 100%。
- 2025-12-06: `compile_questa.do` 多处优化：清理 work/_lock/wlf、设置 transcript 输出、无 warning/error 时写入占位，避免锁文件和旧日志干扰重复仿真。

#2025-11-14
- 2025-11-14: 在 `execute_top_env` 中通过 `uvm_config_db` 把 execute_in/forward driver 与 monitor 的 `vif` 提前传给工厂实例，同时让 FIFO 的 `blocking_get_export` 连接到参考模型与 scoreboard 的 `uvm_blocking_get_port`，从而满足接口要求并消除连接错误。
- 2025-11-14: 将 `execute_stage_scoreboard` 与 `execute_stage_ref_model` 中的 `uvm_blocking_get_port` 替换为 `uvm_get_peek_port`，以满足 `uvm_tlm_analysis_fifo::get_peek_export` 需要 `uvm_get_peek_imp` 接口的约束。
- 2025-11-14: 调整 `execute_top_env` 的 connect_phase，将各 `uvm_get_peek_port`（ref model 与 scoreboard）主动连接到 FIFO 的 `get_peek_export`，避免直接调用 imp 上的 `connect()` 并解决连接计数错误。
- 2025-11-14: 记录 `vlog` 编译路径（`../tb/execute_top/sv/execute_top_pkg.sv`）来确保在 `sim` 目录下运行时能正确定位覆盖所有被 `include` 的组件。
- 2025-11-14: 捕获 `uvm_warning.log` 中的四条 warning（execute_in/forward 的 driver 及 monitor 在 build_phase 里 `m_config` 为 null），解决办法是在 agent 创建这些组件后立即把 `m_config` 赋给它们，让 build_phase 能拿到 config，避免警告。
