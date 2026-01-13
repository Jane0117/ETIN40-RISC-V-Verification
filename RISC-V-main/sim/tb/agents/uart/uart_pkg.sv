`timescale 1ns/1ps
`include "uvm_macros.svh"

package uart_pkg;
  import uvm_pkg::*;

  class uart_tx extends uvm_sequence_item;
    rand byte data;

    `uvm_object_utils(uart_tx)

    function new(string name = "uart_tx");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("uart_tx data=0x%02h", data);
    endfunction
  endclass


  class uart_config extends uvm_object;
    `uvm_object_utils(uart_config)

    virtual uart_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    int unsigned baud_count = 868; // 40MHz / 46080

    function new(string name = "uart_config");
      super.new(name);
    endfunction
  endclass


  class uart_sequencer extends uvm_sequencer #(uart_tx);
    `uvm_component_utils(uart_sequencer)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass


  class uart_driver extends uvm_driver #(uart_tx);
    `uvm_component_utils(uart_driver)

    virtual uart_if drv_vif;
    uart_config m_config;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(uart_config)::get(this, "", "config", m_config))
        `uvm_fatal(get_type_name(), "uart_config not found")
      drv_vif = m_config.vif;
      if (drv_vif == null)
        `uvm_fatal(get_type_name(), "uart_if is null")
    endfunction

    task drive_byte(byte b);
      int unsigned bc;
      bc = m_config.baud_count;
      // start bit
      drv_vif.io_rx <= 1'b0;
      repeat (bc) @(posedge drv_vif.clk);
      // data bits LSB first
      for (int i = 0; i < 8; i++) begin
        drv_vif.io_rx <= b[i];
        repeat (bc) @(posedge drv_vif.clk);
      end
      // stop bit
      drv_vif.io_rx <= 1'b1;
      repeat (bc) @(posedge drv_vif.clk);
    endtask

    task run_phase(uvm_phase phase);
      uart_tx tr;
      drv_vif.io_rx <= 1'b1; // idle high
      forever begin
        seq_item_port.get_next_item(tr);
        if (drv_vif.reset_n === 1'b0)
          wait (drv_vif.reset_n === 1'b1);
        drive_byte(tr.data);
        seq_item_port.item_done();
      end
    endtask
  endclass


  class uart_monitor extends uvm_component;
    `uvm_component_utils(uart_monitor)

    virtual uart_if mon_vif;
    uart_config m_config;
    uvm_analysis_port #(uart_tx) analysis_port;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(uart_config)::get(this, "", "config", m_config))
        `uvm_fatal(get_type_name(), "uart_config not found")
      mon_vif = m_config.vif;
      if (mon_vif == null)
        `uvm_fatal(get_type_name(), "uart_if is null")
    endfunction

    task run_phase(uvm_phase phase);
      int unsigned bc;
      uart_tx tr;
      bc = m_config.baud_count;
      forever begin
        @(posedge mon_vif.clk);
        if (mon_vif.reset_n === 1'b0) begin
          continue;
        end
        if (mon_vif.io_rx === 1'b0) begin
          // wait half bit to sample in the middle
          repeat (bc/2) @(posedge mon_vif.clk);
          if (mon_vif.io_rx !== 1'b0)
            continue;
          tr = uart_tx::type_id::create("tr");
          for (int i = 0; i < 8; i++) begin
            repeat (bc) @(posedge mon_vif.clk);
            tr.data[i] = mon_vif.io_rx;
          end
          // stop bit
          repeat (bc) @(posedge mon_vif.clk);
          analysis_port.write(tr);
        end
      end
    endtask
  endclass


  class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    uart_config m_config;
    uart_sequencer m_sequencer;
    uart_driver m_driver;
    uart_monitor m_monitor;
    uvm_analysis_port #(uart_tx) analysis_port;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(uart_config)::get(this, "", "config", m_config))
        `uvm_fatal(get_type_name(), "uart_config not found")

      m_monitor = uart_monitor::type_id::create("m_monitor", this);
      if (m_config.is_active == UVM_ACTIVE) begin
        m_driver = uart_driver::type_id::create("m_driver", this);
        m_sequencer = uart_sequencer::type_id::create("m_sequencer", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      if (m_config.is_active == UVM_ACTIVE) begin
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
      end
      m_monitor.analysis_port.connect(analysis_port);
    endfunction
  endclass

endpackage
