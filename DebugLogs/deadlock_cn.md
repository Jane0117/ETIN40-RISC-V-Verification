下面是 **完整中文版本**，已按 GitHub 最佳实践排版成 Markdown。

---

# **RISC-V Execute Stage UVM 死锁调试报告**

### *技术故障分析与修复文档*

**作者：** Shengjie Chen
**日期：** 2025-11-18
**项目：** RISC-V Execute Stage Verification

---

## 1. 概述

本调试文档记录了在 RISC-V Execute Stage 的 UVM 验证中遇到的两个关键死锁问题：

1. **Driver 卡死在 `@(posedge vif.clock)`**
2. **default sequence 在 `m_seq_count > 3` 时出现死锁**
3. **为什么将组件从 `main_phase` 改为 `run_phase` 后两个问题全部解决**

两个问题最终都指向同一个根本原因：
**UVM 的 main_phase 会在 objection 计数归零时冻结时间，导致所有基于时钟的逻辑死锁。**

---

## 2. 问题一：Driver 卡死在 `@(posedge vif.clock)`

### 2.1 现象

* 仿真停在 **time = 0 ns**

* Transcript 输出：

  ```
  driver sees clock = 0 @ time 0
  ```

* driver 永远不会打印 `"drive_transaction end"`

* testbench 内部 clock 确实翻转，但 driver 看不到 posedge

---

### 2.2 根本原因

driver 的逻辑写在：

```systemverilog
task main_phase(uvm_phase phase);
```

而在 UVM 中：

> **main_phase 只有在 objection>0 时才允许仿真时间推进。**

因此：

1. 仿真启动时没有 raise_objection
2. main_phase 不推动时间
3. testbench 中 `always #10 clk = ~clk` 根本不会执行
4. `@(posedge clk)` 永远不会触发
5. driver 在时间 0 卡死

---

### 2.3 解决方法

将 driver 逻辑移动到 `run_phase`：

```systemverilog
task run_phase(uvm_phase phase);
    ...
endtask
```

同时 test 负责统一管理 objection：

```systemverilog
task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    vseq.start(null);
    phase.drop_objection(this);
endtask
```

因为：

> **run_phase 不受 objection 影响，时间永远会往前推进。**

---

## 3. 问题二：当 `m_seq_count > 3` 时 default sequence 死锁

### 3.1 现象

* `m_seq_count <= 3`：仿真正常
* `m_seq_count > 3`：仿真死锁
* driver 仍然卡在 `@(posedge clk)`
* fork/join 内的三个子 sequence 执行不完整

---

### 3.2 default sequence 结构

```systemverilog
for (iter = 0; iter < m_seq_count; iter++) begin
  fork
    seq_in.start(...)
    seq_fwd.start(...)
    seq_out.start(...)
  join
end
```

每个 seq.start() 都会自动：

```
pre_start()  → raise_objection  
post_start() → drop_objection
```

这意味着：

* 父 default_seq
* 子 seq1
* 子 seq2
* 子 seq3

**共 4 个 objection 来源同时存在。**

---

### 3.3 根本原因：Objection 竞争条件（Race Condition）

多个序列并行执行速度不一致，导致可能出现：

```
seq1 结束 → drop objection
seq2 仍在执行
seq3 仍在执行
default_seq 结束 → drop objection
↓
objection_count == 0 ★（提前归零）
```

UVM 立即进入：

```
main_phase → ending 状态
↓
仿真时间冻结
↓
clock 停止翻转
↓
driver 卡住 @(posedge clk)
↓
fork/join 永远无法返回
↓
仿真死锁
```

---

### 3.4 为什么 m_seq_count 小于等于 3 不会死？

因为迭代次数少，子 sequence 执行快，drop objection 的顺序刚好正确，没有触发 objection_count 提前归零的条件。

但随着 m_seq_count 增加：

* 随机化差异堆积
* 某一次 iteration 就会出现 objection 提前归零
* 触发 main_phase 时间冻结
* 导致死锁

---

### 3.5 解决方法

把这个多序列调度过程放到 `run_phase`：

* run_phase 永远推进时间
* 不会被 objection freeze
* fork/join 一定能走完
* 任意 m_seq_count 都不会再死锁
* driver 也能正常看到 clock posedge

或完全由 test-level 控制 objection，避免子序列自动 raise/drop。

---

## 4. run_phase vs main_phase —— 为什么改成 run_phase 就全部修好了？

### 4.1 run_phase：**时间驱动（time-driven）**

* 总是推进时间
* 不管 objection 状态如何
* 适合所有基于时间的逻辑：

  * `@(posedge clk)`
  * forever 循环
  * fork/join
  * 驱动器 driver
  * 监视器 monitor

`run_phase` 的行为等价于：

```systemverilog
initial forever begin
    user_code();
    #0;
end
```

---

### 4.2 main_phase：**objection 驱动（objection-driven）**

main_phase 的时间推进由 objection controlling：

```
objection_count > 0 才允许时间流动
objection_count == 0 → 进入 ending 状态 → 时间冻结
```

因此：

* 数据通路卡住
* clock 停止
* @(posedge clk) 卡死
* fork/join 卡死
* 所有 sequence 卡死

你遇到的两个问题都完全符合这一模式。

---

### 4.3 为什么 run_phase 能“一键根治”？

因为：

> **run_phase 不使用 objection，不可能被冻结，时间永远推进。**

因此：

* clock 永远翻转
* @(posedge clk) 永远生效
* driver 不会挂
* fork/join 不会死锁
* m_seq_count 可以是 1000 也没问题

这就是 run_phase 用于时间敏感组件的根本原因。

---

## 5. 两个问题的共同根因总结

两个死锁来自同一机制：

> **main_phase 在 objection 提前归零时会冻结仿真时间。**
> **run_phase 永远不会冻结时间，因此彻底避免了所有卡死。**

---

## 6. 最佳实践总结（工业标准）

| 类型               | 建议                              |
| ---------------- | ------------------------------- |
| Driver / Monitor | 必须放在 **run_phase**              |
| 时间敏感逻辑           | 禁止放在 main_phase                 |
| Objection        | 只由 Test 控制                      |
| 多 agent sequence | 不要让子序列自动 raise/drop             |
| default sequence | 避免 loop + fork + auto-objection |
| clock 相关逻辑       | run_phase 执行                    |
| 复杂协调逻辑           | 用 virtual sequence 而不是 fork 乱序  |

---

## 7. 推荐验证架构（安全版本）

```
test.main_phase
  raise_objection()
  启动 virtual sequence
  drop_objection()

virtual_sequence
  负责多序列调度，无 objection

driver.run_phase
  forever
    get_next_item()
    @(posedge clk)

monitor.run_phase
  @(posedge clk)
  发送到 scoreboard
```
