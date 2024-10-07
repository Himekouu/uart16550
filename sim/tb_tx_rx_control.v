`timescale 1ns/1ns
module tb_tx_rx_control();
  reg 					clk;
  reg 					rst_n;
  reg 	[1:0]   word_length;
  reg 	[2:0]   parity;
  reg 	[8:0]		pi_rx_data;
  reg 					pi_rx_flag;
  reg 					read_flag;
  reg 	[7:0]		pi_tx_data;
  reg 					pi_tx_flag;
  reg 					write_flag;

  wire	        parity_error;
  wire	[7:0]   po_rx_data;
  wire	        data_ready;
  wire	[8:0]   po_tx_data;
  wire	        po_tx_flag;

initial begin
  clk = 1'b1;
  rst_n <= 1'b0;
  word_length <= 2'd0;
  parity <= 3'd0;
  pi_rx_data <= 9'd0;
  pi_rx_flag <= 1'b0;
  read_flag <= 1'b0;
  pi_tx_data <= 8'd0;
  pi_tx_flag <= 1'b0;
  write_flag <= 1'b0;
  #10
  rst_n <= 1'b1;
end

initial begin
  #100
  word_length <= 2'b11;
  parity <= 3'b001;
  #100
  pi_rx_data <= 9'b1_0111_1111;
  pi_rx_flag <= 1'b1;
  #20
  pi_rx_flag <= 1'b0;
  #80
  read_flag <= 1'b1;
  #20
  read_flag <= 1'b0;
  #100
  pi_tx_data <= 8'b1111_1111;
  write_flag <= 1'b1;
  #20
  write_flag <= 1'b0;
end

always #10 clk = ~clk;

tx_rx_control tx_rx_control_inst (
  .clk(clk),
  .rst_n(rst_n),
  .word_length(word_length),
  .parity(parity),
  .pi_rx_data(pi_rx_data),
  .pi_rx_flag(pi_rx_flag),
  .read_flag(read_flag),
  .pi_tx_data(pi_tx_data),
  .pi_tx_flag(pi_tx_flag),
  .write_flag(write_flag),

  .parity_error(parity_error),
  .po_rx_data(po_rx_data),
  .data_ready(data_ready),
  .po_tx_data(po_tx_data),
  .po_tx_flag(po_tx_flag)
);

endmodule