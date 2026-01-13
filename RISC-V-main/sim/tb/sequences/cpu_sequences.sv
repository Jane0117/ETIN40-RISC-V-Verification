// cpu_sequences.sv
class uart_program_seq extends uvm_sequence #(uart_tx);
  `uvm_object_utils(uart_program_seq)
  logic [31:0] program_words[$];
  bit append_sentinel = 1'b1;
  function new(string name = "uart_program_seq"); super.new(name); endfunction
  task send_byte(byte b); uart_tx tx; tx = uart_tx::type_id::create("tx"); tx.data = b; start_item(tx); finish_item(tx); endtask
  // DUT UART wrapper shifts existing bytes up and appends the new byte at LSB; send MSB first so final word matches
  task send_word(logic [31:0] w); send_byte(w[31:24]); send_byte(w[23:16]); send_byte(w[15:8]); send_byte(w[7:0]); endtask
  task body();
    // Align to DUT's byte_counter (which asserts data_valid one byte later)
    send_byte(8'h00); // leading dummy byte so first data_valid captures the first program word
    foreach (program_words[i]) send_word(program_words[i]);
    if (append_sentinel) send_word(32'h0000_1111);
  endtask
endclass
