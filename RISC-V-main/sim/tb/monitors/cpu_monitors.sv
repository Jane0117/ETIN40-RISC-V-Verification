// cpu_monitors.sv: pipeline monitors
class cpu_issue_monitor extends uvm_component;
  `uvm_component_utils(cpu_issue_monitor)
  virtual cpu_mon_if vif;
  uvm_analysis_port #(issue_tx) analysis_port;
  function new(string name, uvm_component parent); super.new(name, parent); analysis_port = new("analysis_port", this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif)) `uvm_fatal(get_type_name(), "cpu_mon_if not found") endfunction
  task run_phase(uvm_phase phase); issue_tx tx; forever begin @(negedge vif.clk); if (vif.reset_n === 1'b0) continue; if (vif.id_ex_write && !vif.id_ex_flush) begin tx = issue_tx::type_id::create("tx", this); tx.pc = vif.if_id.pc; tx.instr = vif.if_id.instruction; analysis_port.write(tx); end end endtask
endclass

class cpu_wb_monitor extends uvm_component;
  `uvm_component_utils(cpu_wb_monitor)
  virtual cpu_mon_if vif; uvm_analysis_port #(wb_tx) analysis_port;
  function new(string name, uvm_component parent); super.new(name, parent); analysis_port = new("analysis_port", this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif)) `uvm_fatal(get_type_name(), "cpu_mon_if not found") endfunction
  task run_phase(uvm_phase phase); wb_tx tx; forever begin @(posedge vif.clk); if (vif.reset_n === 1'b0) continue; if (vif.mem_wb.control.reg_write && vif.mem_wb.reg_rd_id != 0) begin tx = wb_tx::type_id::create("tx", this); tx.pc = vif.mem_wb.pc; tx.rd = vif.mem_wb.reg_rd_id; tx.is_load = vif.mem_wb.control.mem_read; tx.mem_size = vif.mem_wb.control.mem_size; tx.mem_sign = vif.mem_wb.control.mem_sign; tx.data = vif.mem_wb.control.mem_read ? vif.mem_wb.memory_data : vif.mem_wb.alu_data; analysis_port.write(tx); end end endtask
endclass

class cpu_store_monitor extends uvm_component;
  `uvm_component_utils(cpu_store_monitor)
  virtual cpu_mon_if vif; uvm_analysis_port #(store_tx) analysis_port;
  function new(string name, uvm_component parent); super.new(name, parent); analysis_port = new("analysis_port", this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif)) `uvm_fatal(get_type_name(), "cpu_mon_if not found") endfunction
  task run_phase(uvm_phase phase); store_tx tx; forever begin @(posedge vif.clk); if (vif.reset_n === 1'b0) continue; if (vif.ex_mem.control.mem_write) begin tx = store_tx::type_id::create("tx", this); tx.pc = vif.ex_mem.pc; tx.addr = vif.ex_mem.alu_data; tx.data = vif.ex_mem.memory_data; tx.mem_size = vif.ex_mem.control.mem_size; analysis_port.write(tx); end end endtask
endclass

class cpu_mem_monitor extends uvm_component;
  `uvm_component_utils(cpu_mem_monitor)
  virtual cpu_mon_if vif; uvm_analysis_port #(mem_tx) analysis_port;
  function new(string name, uvm_component parent); super.new(name, parent); analysis_port = new("analysis_port", this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif)) `uvm_fatal(get_type_name(), "cpu_mon_if not found") endfunction
  task run_phase(uvm_phase phase); mem_tx tx; forever begin @(posedge vif.clk); if (vif.reset_n === 1'b0) continue; if (vif.ex_mem.control.mem_read || vif.ex_mem.control.mem_write) begin tx = mem_tx::type_id::create("tx", this); tx.addr = vif.ex_mem.alu_data; tx.is_read = vif.ex_mem.control.mem_read; tx.is_write = vif.ex_mem.control.mem_write; tx.mem_size = vif.ex_mem.control.mem_size; tx.mem_sign = vif.ex_mem.control.mem_sign; analysis_port.write(tx); end end endtask
endclass

class cpu_exec_monitor extends uvm_component;
  `uvm_component_utils(cpu_exec_monitor)
  virtual cpu_mon_if vif; uvm_analysis_port #(branch_tx) analysis_port;
  function new(string name, uvm_component parent); super.new(name, parent); analysis_port = new("analysis_port", this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if (!uvm_config_db#(virtual cpu_mon_if)::get(this, "", "cpu_mon_vif", vif)) `uvm_fatal(get_type_name(), "cpu_mon_if not found") endfunction
  task run_phase(uvm_phase phase); branch_tx tx; forever begin @(posedge vif.clk); if (vif.reset_n === 1'b0) continue; if (vif.id_ex.control.encoding == B_TYPE) begin tx = branch_tx::type_id::create("tx", this); tx.pc = vif.execute_pc; tx.taken = vif.pc_src; tx.funct3 = 3'b000; analysis_port.write(tx); end end endtask
endclass
