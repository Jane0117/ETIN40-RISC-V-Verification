# EX-Stage UVM 环境使用说明

此目录保存 Easier UVM 对 `execute_stage` 的测试环境输出，包含新的 agent、env，以及仿真脚本。

## 1. 目录结构
- `dut/`：include 原始的 `execute_stage.sv` 以及复制的依赖文件，方便一键编译。
- `tb/`：`decode_in`、`forward`、`execute_out` 三个 agent 的 interface/transaction/driver/monitor/seq_lib/agent/config/coverage 文件。
- `sim/`：Questa/VCS/IUS/Riviera 的编译/仿真脚本，自动使用 `files.f` 与 `uvm_cmdline`。

## 2. 重新生成步骤
1. 进入 generator 工作目录（本例在 Windows 下）：
   ```
   cd D:/IC-Project/ICP2-Verification/phase-2/easier_uvm_gen-2017-01-19
   ```
2. 确保 `execute_common.tpl` 中的 `dut_source_path` 指向 `RISC-V-main/.../SystemVerilog/Design`，`project = generated_execute_tb`，`dut_pfile = execute_pinlist`。
   - 你可以在 `execute_common.tpl` 里面观察到 `dut_top = execute_stage`、`project = generated_execute_tb`，以及 `execute_pinlist` 三段 `!decode_if`/`!forward_if`/`!execute_out_if` 的端口映射，确保这些绑定到刚刚添加的 `.tpl` 文件中定义的 interface。
3. 执行生成命令（Linux/WSL 下需加 `PERL5LIB=$PWD`）：
   ```
   PERL5LIB=$PWD perl easier_uvm_gen.pl -m execute_common.tpl decode_in.tpl forward.tpl execute_out.tpl
   ```
   该命令会依次生成三个 agent 的 UVC、顶层 env/test、以及 `generated_execute_tb` 的目录结构。

### 三个模板区别
 - `decode_in.tpl`：主动 agent，`uvm_seqr_class = yes`、`agent_is_active = UVM_ACTIVE`，包含 `data1/data2/immediate_data/pc_in/control_in` 等解码阶段输入端口。driver/seq_lib 负责随机化这些寄存器源与立即数，monitor 可留用 coverage/scoreboard。  
 - `forward.tpl`：同样做成 ACTIVE agent，有 `uvm_seqr_class = yes`，涵盖 `wb_forward_data/mem_forward_data/forward_rs1/forward_rs2`，用于系统地激励 forwarding 选择（EX/MEM/WB）。它的 sequencer/driver 细节与 `decode_in` 类似但字段不同。  
 - `execute_out.tpl`：header 里只保留 `agent_is_active = UVM_PASSIVE`，去掉 `uvm_seqr_class`（默认 `no`），所以生成的 `execute_out_sequencer.sv` 只有 `typedef uvm_sequencer`，不会创建完整 class。它只声明 `control_out/alu_data/memory_data/pc_src/jalr*` 等输出端口，由 monitor 拍摄；driver 虽然存在但从 config `is_active = UVM_PASSIVE` 角度永远不会被 `create()`，`agent_append_to_connect_phase` 预留了 scoreboard 的插槽。这样才能让 execute_out 做观察者而不干扰 DUT，同样可随时把它改成 ACTIVE 再次生成。

## 3. 使用说明
- `execute_out_agent` 走 passive 模式（`agent_is_active = UVM_PASSIVE`，在 `execute_top_tb.sv` 里也把 `is_active_execute_out = UVM_PASSIVE` 设置成被动），运行时只会保留 monitor，driver/sequencer 依旧生成但不会 new。
- `execute_out.tpl` 通过 `agent_append_to_connect_phase = my_exec_scoreboard_connect.sv inline` 预留 scoreboard hook，具体连接逻辑写在 `include/my_exec_scoreboard_connect.sv`。
- 想查看 driver 激励/transaction 结构，可在 `tb/decode_in/sv`、`tb/forward/sv` 中打开 `*_transaction.sv`、`*_driver.sv`、`*_seq_lib.sv` 等文件。

## 4. 后续建议
1. 在 `include/` 中补充 reference model/scoreboard，让 `execute_out_monitor.analysis_port` 连接到你的验证逻辑。
2. 为 `decode_in` 和 `forward` agent 写 sequence（`*_seq_lib.sv`）来驱动控制、转发场景。
3. 使用 `generated_execute_tb/sim/compile_*` 脚本或自定义仿真流程编译/运行，验证 execute-stage 的功能性与 scoreboard 比对。
