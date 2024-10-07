`timescale 1ns/1ns
module tb_tx_rx();
  reg 					clk;
  reg 					rst_n;
  reg 	[1:0]   word_length;
  reg   [15:0]  baud_rate_cnt;
  reg 	[2:0]   parity;
  reg           stop_bits;
  reg           set_break;
  reg           rx;
  reg   [7:0]   pi_tx_data;
  reg		    		read_flag;
  reg				    write_flag;

  wire					tx;
  wire	[7:0]   po_rx_data;
  wire					parity_error;
  wire 					data_ready;
initial begin
  clk = 1'b1;
  rst_n <= 1'b0;
  word_length <= 2'd0;
  baud_rate_cnt <= 15'd0;
  parity <= 3'd0;
  stop_bits <= 1'b0;
  set_break <= 1'b0;
  rx <= 1'b1;
  pi_tx_data <= 8'd0;
  read_flag <= 1'b0;
  write_flag <= 1'b0;
  #10
  rst_n <= 1'b1;
end

initial begin
  #100
  rx_tx_bit(9'b1_1111_1001, 2'b00, 16'd5208, 3'b001, 1'b0);
end

task rx_tx_bit(
  input  [8:0]   data,
  input  [1:0]   length,
  input  [15:0]  cnt,
  input  [2:0]   parity_,
  input          stop_bit
);
integer i;
begin
  word_length <= length;
  baud_rate_cnt <= cnt;
  parity <= parity_;
  stop_bits <= stop_bit;
  for (i = 0; i < 7 + length + parity_[0]; i = i + 1) begin
    case(i)
      0:rx <= 1'd0;
      (6 + length + parity_[0]):rx <= 1'b1;
      default:rx <= data[i - 1];
    endcase
    #(cnt * 20);
  end
  #20
  read_flag <= 1'b1;
  #20
  read_flag <= 1'b0;
  pi_tx_data <= po_rx_data;
  write_flag <= 1'b1;
  #20
  write_flag <= 1'b0;
  #(((3'd7 + length + parity_[0] + stop_bit) * cnt + stop_bit) * 20 + 280);
end
endtask

always #10 clk = ~clk;

tx_rx tx_rx_inst (
  .clk(clk),
  .rst_n(rst_n),
  .word_length(word_length),
  .baud_rate_cnt(baud_rate_cnt),
  .parity(parity),
  .stop_bits(stop_bits),
  .set_break(set_break),
  .rx(rx),
  .pi_tx_data(pi_tx_data),
  .read_flag(read_flag),
  .write_flag(write_flag),

  .tx(tx),
  .po_rx_data(po_rx_data),
  .parity_error(parity_error),
  .data_ready(data_ready)
);

endmodule