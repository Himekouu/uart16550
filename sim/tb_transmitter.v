`timescale 1ns/1ns
module tb_transmitter();
reg           clk;
reg           rst_n;
reg   [1:0]   word_length;
reg   [15:0]  baud_rate_cnt;
reg           parity_en;
reg           stop_bits;
reg           set_break;
reg   [8:0]   pi_tx_data;
reg           pi_flag;

wire          tx;
wire          po_flag;
wire          busy_flag;

initial begin
  clk = 1'b1;
  rst_n <= 1'b0;
  word_length <= 2'd0;
  baud_rate_cnt <= 15'd0;
  parity_en <= 1'b0;
  stop_bits <= 1'b0;
  set_break <= 1'b0;
  pi_tx_data <= 9'b0;
  pi_flag <= 1'b0;
  #20
  rst_n <= 1'b1;
end

initial begin
  #200
  tx_bit(9'b0_1111_1111, 2'd3, 16'd5208, 1'b1, 1'b0);
  tx_bit(9'b0_1111_1011, 2'd3, 16'd5208, 1'b1, 1'b1);
  tx_bit(9'b1_1011_0111, 2'd2, 16'd5208, 1'b0, 1'b0);
  tx_bit(9'b1_1101_1111, 2'd1, 16'd5208, 1'b0, 1'b0);
end

always #10 clk = ~clk;

task tx_bit(
  input  [8:0]   data,
  input  [1:0]   length,
  input  [15:0]  cnt,
  input          parity,
  input          stop_bit
);
integer i;
begin
  pi_tx_data <= data;
  word_length <= length;
  baud_rate_cnt <= cnt;
  parity_en <= parity;
  stop_bits <= stop_bit;
  pi_flag <= 1'b1;
  #20
  pi_flag <= 1'b0;
  #(((3'd7 + length + parity + stop_bit) * cnt + stop_bit) * 20 + 280);
end
endtask

transmitter transmitter_inst (
  .clk(clk),
  .rst_n(rst_n),
  .word_length(word_length),
  .baud_rate_cnt(baud_rate_cnt),
  .parity_en(parity_en),
  .stop_bits(stop_bits),
  .set_break(set_break),
  .pi_tx_data(pi_tx_data),
  .pi_flag(pi_flag),

  .tx(tx),
  .po_flag(po_flag),
  .busy_flag(busy_flag)
);
endmodule