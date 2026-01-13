`timescale 1ns/1ps

interface uart_if(input logic clk);
  logic reset_n;
  logic io_rx;

  modport drv (input clk, reset_n, output io_rx);
  modport mon (input clk, reset_n, io_rx);
endinterface
