module interrupt_controller (
  input		wire					clk,
  input		wire					rst_n,
  input		wire	[5:0]   interrupt_en,
  input		wire					error,
  input		wire					rx_data_ready,
  input		wire					tx_data_empty,

  output 	reg 					irq,
  output 	reg 	[2:0]   interrupt_type
);

wire  [5:0]   interrupt;

assign interrupt[0]   = (interrupt_en[0] == 1)? rx_data_ready : 1'b0;
assign interrupt[1]   = (interrupt_en[1] == 1)? ~tx_data_empty : 1'b0;
assign interrupt[2]   = (interrupt_en[2] == 1)? error : 1'b0;
assign interrupt[5:3] = 3'd0; //未启用

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0) begin
    interrupt_type <= 3'b100; //默认不存在100这种编码
  end
  else begin
    if(interrupt[0] == 1'b1)
      interrupt_type <= 3'b010;
    else if(interrupt[1] == 1'b1)
      interrupt_type <= 3'b001;
    else if(interrupt[2] == 1'b1)
      interrupt_type <= 3'b011;
    else if(interrupt[3] == 1'b1)
      interrupt_type <= 3'b000;
    else if(interrupt[4] == 1'b1)
      interrupt_type <= 3'b111;
    else if(interrupt[5] == 1'b1)
      interrupt_type <= 3'b101;
    else
      interrupt_type <= 3'b100;
  end

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    irq <= 1'b0;
  else
    irq <= |interrupt;
  
endmodule