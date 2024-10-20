`timescale 1ns/1ns
module tb_interrupt_controller();
reg 					clk;
reg 					rst_n;
reg 	[5:0]   interrupt_en;
reg 					error;
reg 					rx_data_ready;
reg 					tx_data_empty;

wire					irq;
wire	[2:0]   interrupt_type;

initial begin
  clk = 1'b1;
  rst_n <= 1'b0;
  interrupt_en <= 6'd0;
  error <= 1'b0;
  rx_data_ready <= 1'b0;
  tx_data_empty <= 1'b1;
  #10
  rst_n <= 1'b1;
end

initial begin
  #100
  interrupt_en <= 6'b000111;
  #20
  error <= 1'b1;
  rx_data_ready <= 1'b1;
  tx_data_empty <= 1'b0;
  #40
  interrupt_en <= 6'b000011;
  #40
  rx_data_ready <= 1'b0;
end

always #10 clk = ~clk;

interrupt_controller interrupt_controller_inst (
  .clk(clk),
  .rst_n(rst_n),
  .interrupt_en(interrupt_en),
  .error(error),
  .rx_data_ready(rx_data_ready),
  .tx_data_empty(tx_data_empty),

  .irq(irq),
  .interrupt_type(interrupt_type)
);

endmodule