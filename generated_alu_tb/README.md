# generated_alu_tb 目录说明

## 顶层结构
- `dut/`：保存被测 RISC-V ALU 顶层工程的 RTL 文件（`alu.sv`、`cpu.sv` 等）以及仿真用的内存、文件列表 `files.f`。UVM testbench 最终会把 `tb/alu_top_tb` 中的 harness 与这里的 RTL 进行绑定。
- `sim/`：easier-uvm 生成的仿真脚本与中间库（针对 VCS、Questa、Riviera、IUS 等），包含 `compile_*.sh|do`、`certe_dump.xml` 以及 `work/` 目录下的仿真编译缓存。运行回归时直接在此目录调用相应脚本。
- `tb/`：UVM 验证环境主体。内部再细分为可复用 agent（`alu/`）、系统级 environment（`alu_top/`）、SystemVerilog 模块化 testbench（`alu_top_tb/`）、UVM test 类（`alu_top_test/`）和共用头文件（`include/`）。

## tb/ 层次与作用
- `tb/alu/`  
  - **定位**：单独的 ALU UVC。`sv/` 下的 `alu_pkg.sv` 汇总 sequence item、config、driver、monitor、sequencer、coverage、agent、默认序列。  
  - **作用**：定义 ALU 接口协议以及激励/采样机制，可被任意上层环境复用。  
  - **调用关系**：`alu_top_pkg` 通过 `import alu_pkg::*;` 引入 agent。driver/monitor 使用 `alu_if` 与 DUT 接口交互，sequencer 接收来自 test 的 sequence。

- `tb/alu_top/`  
  - **定位**：系统级环境包。`alu_top_pkg.sv` 再次打包顶层 config、虚拟序列库 `alu_top_seq_lib.sv` 和环境类 `alu_top_env.sv`。  
  - **作用**：在 `build_phase` 中创建 `alu_agent`、复制 config、连接 analysis port；`run_phase` 中启动虚拟序列。  
  - **调用关系**：被 UVM test (`alu_top_test`) 引用，内部实例化 `alu_pkg` 中的所有组件，并将 monitor 的分析端口接入 `alu_coverage`/scoreboard。

- `tb/alu_top_tb/`  
  - **定位**：纯 SV testbench 模块。`alu_top_th.sv` 负责实例化 DUT、接口、时钟/复位；`alu_top_tb.sv` 作为仿真顶层，创建 `alu_top_config`，把 virtual interface 写入 `uvm_config_db`，然后 `run_test()`。  
  - **作用**：搭建硬件级 test harness，把 RTL 与 UVM 世界连接起来。  
  - **调用关系**：`alu_top_tb` 模块 -> `alu_top_th` -> DUT；同时调用 `alu_top_test_pkg`，让仿真器知道要跑哪个 UVM test。

- `tb/alu_top_test/`  
  - **定位**：UVM test 定义。`alu_top_test_pkg.sv` 导入 `alu_pkg` 和 `alu_top_pkg`，再 `include "alu_top_test.sv"`；`alu_top_test` 继承自 `uvm_test` 并在 `build_phase` 中创建 `alu_top_env`。  
  - **作用**：控制哪套环境/序列运行，可派生多个 test 类配置不同约束或虚拟序列。  
  - **调用关系**：`run_test("alu_top_test")` -> `alu_top_test` -> `alu_top_env` -> `alu_agent`。

- `tb/include/`  
  - **定位**：存放可被多处 `include` 的宏、typedef、公共定义（目前为空，可按需添加）。  
  - **作用**：简化跨目录共享代码，避免在 `.sv` 文件中重复粘贴。

## 执行流程概览
1. 仿真从 `tb/alu_top_tb/sv/alu_top_tb.sv` 模块开始，构造 `alu_top_config`，将 virtual interface 指向 `alu_top_th` 中的 `alu_if_0` 并写入 `uvm_config_db`。
2. `run_test()` 调起 `alu_top_test_pkg`，创建 `alu_top_test` 对象。
3. `alu_top_test` 在 `build_phase` 中 `create` `alu_top_env`，环境再实例化 `alu_agent`、`alu_coverage` 等，并把 config 注入子组件。
4. `run_phase` 中的 `alu_top_default_seq` 通过虚拟 sequencer 控制 `alu_agent`，driver 经由 `alu_if` 驱动 `alu_top_th` 的 DUT 端口，monitor 采集响应后推送到 coverage/scoreboard。
5. 仿真脚本位于 `sim/`，根据所选仿真器调用 `compile_*.sh|do` 完成编译+运行，DUT 源来自 `dut/`。
