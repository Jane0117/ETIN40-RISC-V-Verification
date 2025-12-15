# **RISC-V Execute Stage UVM Deadlock Debug Report**

### *Technical Failure Analysis & Resolution Log*

**Author:** Shengjie Chen
**Date:** 2025-11-18
**Project:** RISC-V Execute Stage Verification

---

## 1. Overview

This document records two critical UVM simulation deadlocks encountered during the RISC-V Execute Stage verification:

1. **Driver stuck at `@(posedge vif.clock)`**
2. **Default sequence deadlock when `m_seq_count > 3`**
3. **Why switching from `main_phase` to `run_phase` resolves *all* timing-related deadlocks**

Both failures were traced to one common mechanism:
**UVM main_phase freezes simulation time when objections are incorrectly dropped.**

This log is meant for future debugging, methodology improvement, and documentation in the verification repository.

---

## 2. Issue #1 — Driver Blocking at `@(posedge vif.clock)`

### 2.1 Symptoms

* Simulation freezes at **time 0 ns**

* Transcript shows:

  ```
  driver sees clock = 0 @ time 0
  ```

* Driver never prints `"drive_transaction end"`

* Clock toggles in TB, but UVM driver never sees any posedge.

---

### 2.2 Root Cause

Driver code was written in:

```systemverilog
task main_phase(uvm_phase phase);
```

In UVM:

> **`main_phase` does not advance simulation time unless an objection is raised.**

Thus:

1. At simulation start objection_count = 0
2. main_phase never enters a time-advancing state
3. Clock generator (`always #10 clk = ~clk`) never executes
4. No posedge → driver blocks forever
5. Simulation hangs at time 0

---

### 2.3 Fix

Move driver logic to `run_phase`:

```systemverilog
task run_phase(uvm_phase phase);
    ...
endtask
```

Control objections explicitly in test:

```systemverilog
task main_phase(uvm_phase phase);
  phase.raise_objection(this);
  vseq.start(null);
  phase.drop_objection(this);
endtask
```

> **`run_phase` always advances simulation time, independent of objections.**

---

## 3. Issue #2 — Deadlock When `m_seq_count > 3`

### 3.1 Symptoms

* `m_seq_count <= 3` → simulation OK
* `m_seq_count > 3` → simulation deadlocks
* Driver again blocks at `@(posedge clk)`
* fork/join inside default sequence never completes

---

### 3.2 Default Sequence Structure

```systemverilog
for (iter = 0; iter < m_seq_count; iter++) begin
  fork
     seq_in.start(...)
     seq_fwd.start(...)
     seq_out.start(...)
  join
end
```

Each `seq.start()` performs automatic:

```
pre_start()  → raise_objection  
post_start() → drop_objection
```

This creates **four independent objection sources**:

* parent default sequence
* child seq1
* child seq2
* child seq3

---

### 3.3 Root Cause — *Objection Race Condition*

Because forked sequences finish at different speeds:

```
seq1 finishes → drop objection
seq2 still running
seq3 still running
default_seq finishes → drop objection
↓
objection_count reaches 0 prematurely ★
```

This forces UVM into:

```
main_phase → ending
↓
simulation time FREEZES
↓
clock stops toggling
↓
@(posedge clk) blocks forever
↓
fork/join deadlocks
↓
simulation halts
```

---

### 3.4 Why `m_seq_count <= 3` Does Not Deadlock

At small iteration counts:

* All 3 sequences finish quickly
* drop objection happens in correct order
* objection_count never becomes zero too early

At higher counts:

* Random execution delays accumulate
* Early drop objection becomes probable
* Phase ending triggers time freeze → deadlock

---

### 3.5 Fix

Use `run_phase` for all time-based activities:

* Time always advances
* No phase freeze
* No objection race
* fork/join always completes
* driver always receives posedge clock

Or centralize objection handling at test-level only.

---

## 4. run_phase vs main_phase — Why run_phase Solves All Deadlocks

### 4.1 run_phase — Time-Driven Phase

* Always advances simulation time
* Never freezes regardless of objections
* Ideal for:

  * `@(posedge clk)`
  * forever loops
  * fork/join
  * driver
  * monitor

`run_phase` behaves like:

```systemverilog
initial forever begin
    user_code();
    #0;
end
```

---

### 4.2 main_phase — Objection-Controlled Phase

`main_phase` advances time *only* when:

```
objection_count > 0
```

If objection_count becomes 0 at the wrong moment:

```
main_phase enters "ending"
↓
simulation time freezes
```

Consequences:

* No clock edges
* All @(posedge clk) block
* Driver freezes
* Sequences freeze
* fork/join never returns
* Simulation deadlocks

This matches **both** Issue #1 and Issue #2 exactly.

---

### 4.3 Why run_phase Fixes Everything

Because:

> **run_phase is immune to objection freezes and always allows time to move forward.**

Therefore:

* Clock always toggles
* Driver is never stuck
* fork/join sequences always complete
* Objection races cannot freeze the simulation
* m_seq_count can be arbitrarily large

---

## 5. Combined Root Cause Summary

Both failures arise from the same mechanism:

> **main_phase freezes simulation time when objections reach zero.
> run_phase never freezes — therefore, time always advances.**

Thus:

```
main_phase + @(posedge clk)  → dangerous
run_phase + @(posedge clk)   → safe
```

---

## 6. Best Practices (Industry Standards)

| Topic                  | Guideline                         |
| ---------------------- | --------------------------------- |
| Driver & Monitor       | Always implement in **run_phase** |
| Sequence orchestration | Avoid forked auto-objections      |
| Time-driven waits      | Never in main_phase               |
| Objections             | Only the test should manage them  |
| Default sequences      | Avoid per-iteration raise/drop    |
| Clock-sensitive logic  | Keep inside run_phase             |
| Multi-agent env        | Use parent-only objections        |

---

## 7. Recommended Safe Architecture

```
test.main_phase
  raise_objection()
  start virtual sequence
  drop_objection()

virtual_sequence
  coordinates child sequences (no objection)

driver.run_phase
  forever
    get_next_item()
    @(posedge clk)

monitor.run_phase
  @(posedge clk)
  send to scoreboard
```
