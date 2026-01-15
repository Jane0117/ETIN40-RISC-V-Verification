// cpu_env.sv
class cpu_env extends uvm_env;
  `uvm_component_utils(cpu_env)

  uart_agent m_uart_agent;
  cpu_issue_monitor m_issue_mon;
  cpu_wb_monitor m_wb_mon;
  cpu_store_monitor m_store_mon;
  cpu_mem_monitor m_mem_mon;
  cpu_exec_monitor m_exec_mon;

  cpu_ref_model m_ref_model;
  cpu_scoreboard m_scoreboard;
  cpu_coverage m_coverage;

  uvm_tlm_analysis_fifo #(issue_tx) issue_fifo;

  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    uart_config uart_cfg; virtual uart_if uart_vif;
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal(get_type_name(), "uart_vif not found")
    uart_cfg = uart_config::type_id::create("uart_cfg");
    uart_cfg.vif = uart_vif; uart_cfg.is_active = UVM_ACTIVE;
    uvm_config_db#(uart_config)::set(this, "m_uart_agent", "config", uart_cfg);
    uvm_config_db#(uart_config)::set(this, "m_uart_agent.*", "config", uart_cfg);

    m_uart_agent = uart_agent::type_id::create("m_uart_agent", this);
    m_issue_mon = cpu_issue_monitor::type_id::create("m_issue_mon", this);
    m_wb_mon = cpu_wb_monitor::type_id::create("m_wb_mon", this);
    m_store_mon = cpu_store_monitor::type_id::create("m_store_mon", this);
    m_mem_mon = cpu_mem_monitor::type_id::create("m_mem_mon", this);
    m_exec_mon = cpu_exec_monitor::type_id::create("m_exec_mon", this);

    m_ref_model = cpu_ref_model::type_id::create("m_ref_model", this);
    m_scoreboard = cpu_scoreboard::type_id::create("m_scoreboard", this);
    m_coverage = cpu_coverage::type_id::create("m_coverage", this);

    issue_fifo = new("issue_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    m_issue_mon.analysis_port.connect(issue_fifo.analysis_export);
    m_ref_model.issue_port.connect(issue_fifo.get_peek_export);
    m_ref_model.exp_issue_ap.connect(m_scoreboard.exp_issue_fifo.analysis_export);
    m_issue_mon.analysis_port.connect(m_scoreboard.act_issue_fifo.analysis_export);

    m_ref_model.exp_wb_ap.connect(m_scoreboard.exp_wb_fifo.analysis_export);
    m_wb_mon.analysis_port.connect(m_scoreboard.act_wb_fifo.analysis_export);

    m_ref_model.exp_store_ap.connect(m_scoreboard.exp_store_fifo.analysis_export);
    m_store_mon.analysis_port.connect(m_scoreboard.act_store_fifo.analysis_export);

    m_ref_model.exp_branch_ap.connect(m_scoreboard.exp_branch_fifo.analysis_export);
    m_exec_mon.analysis_port.connect(m_scoreboard.act_branch_fifo.analysis_export);
    m_ref_model.exp_mem_ap.connect(m_scoreboard.exp_mem_fifo.analysis_export);
    m_mem_mon.analysis_port.connect(m_scoreboard.act_mem_fifo.analysis_export);

    m_issue_mon.analysis_port.connect(m_coverage.issue_imp);
    m_wb_mon.analysis_port.connect(m_coverage.wb_imp);
    m_store_mon.analysis_port.connect(m_coverage.store_imp);
    m_mem_mon.analysis_port.connect(m_coverage.mem_imp);
    m_ref_model.exp_branch_ap.connect(m_coverage.branch_imp);
  endfunction
endclass
