`timescale 1ns/1ns
module tb_receiver();
reg           clk;
reg           rst_n;
reg   [1:0]   word_length;
reg   [15:0]  baud_rate_cnt;
reg           parity_en;
reg           rx;

wire  [8:0]   po_rx_data;
wire          po_flag;

initial begin
  clk = 1'b1;
  rst_n <= 1'b0;
  word_length <= 2'd0;
  baud_rate_cnt <= 15'd0;
  parity_en <= 1'b0;
  rx <= 1'b1;
  #20
  rst_n <= 1'b1;
end

initial begin
  #200
  rx_bit(9'b1_1111_1111, 2'd3, 16'd10416, 1'b1);
  rx_bit(9'b1_1111_1100, 2'd2, 16'd434, 1'b0);
  rx_bit(9'b0_0000_1111, 2'd0, 16'd5208, 1'b0);
  rx_bit(9'b0_0110_1010, 2'd0, 16'd5208, 1'b1);
end

always #10 clk = ~clk;

task rx_bit(
  input  [8:0]   data,
  input  [1:0]   length,
  input  [15:0]  cnt,
  input          parity
);
integer i;
begin
  word_length <= length;
  baud_rate_cnt <= cnt;
  parity_en <= parity;
  for (i = 0; i < 7 + length + parity; i = i + 1) begin
    case(i)
      0:rx <= 1'd0;
      (6 + length + parity):rx <= 1'b1;
      default:rx <= data[i - 1];
    endcase
    #(cnt * 20);
  end
end
endtask

receiver receiver_inst (
  .clk(clk),
  .rst_n(rst_n),
  .word_length(word_length),
  .baud_rate_cnt(baud_rate_cnt),
  .parity_en(parity_en),
  .rx(rx),

  .po_rx_data(po_rx_data),
  .po_flag(po_flag)
);
endmodule