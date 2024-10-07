module tx_rx (
  input		wire					clk,
  input		wire					rst_n,
  input		wire	[1:0]   word_length,
  input   wire  [15:0]  baud_rate_cnt,
  input		wire	[2:0]   parity,
  input   wire          stop_bits,
  input   wire          set_break,
  input   wire          rx,
  input		wire	[7:0]   pi_tx_data,
  input		wire					read_flag,
  input		wire					write_flag,

  output	wire					tx,
  output	wire	[7:0]   po_rx_data,
  output	wire					parity_error,
  output	wire 					data_ready
);
wire  [8:0]   rx_data;
wire          rx_flag;
wire  [8:0]   tx_data;
wire          tx_flag;

tx_rx_control tx_rx_control_inst (
  .clk(clk),
  .rst_n(rst_n),
  .word_length(word_length),
  .parity(parity),
  .pi_rx_data(rx_data),
  .pi_rx_flag(rx_flag),
  .read_flag(read_flag),
  .pi_tx_data(pi_tx_data),
  // .pi_tx_flag(),
  .write_flag(write_flag),

  .parity_error(parity_error),
  .po_rx_data(po_rx_data),
  .data_ready(data_ready),
  .po_tx_data(tx_data),
  .po_tx_flag(tx_flag)
);
  
receiver receiver_inst (
  .clk(clk),
  .rst_n(rst_n),
  .word_length(word_length),
  .baud_rate_cnt(baud_rate_cnt),
  .parity_en(parity[0]),
  .rx(rx),

  .po_rx_data(rx_data),
  .po_flag(rx_flag)
);

transmitter transmitter_inst (
  .clk(clk),
  .rst_n(rst_n),
  .word_length(word_length),
  .baud_rate_cnt(baud_rate_cnt),
  .parity_en(parity[0]),
  .stop_bits(stop_bits),
  .set_break(set_break),
  .pi_tx_data(tx_data),
  .pi_flag(tx_flag),

  .tx(tx)
  // .po_flag()
);
endmodule