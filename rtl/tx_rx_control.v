module tx_rx_control (
  input		wire					clk,
  input		wire					rst_n,
  input		wire	[1:0]   word_length,
  input		wire	[2:0]   parity,
  input		wire	[8:0]   pi_rx_data,
  input		wire					pi_rx_flag,
  input		wire					read_flag,
  input		wire	[7:0]   pi_tx_data,
  input		wire					pi_tx_flag,
  input		wire					write_flag,

  output	wire					parity_error,
  output	wire	[7:0]   po_rx_data,
  output	reg 					data_ready,
  output	wire	[8:0]   po_tx_data,
  output	reg 					po_tx_flag
);
reg   [10:0]  rx_reg; //串口收数据寄存器
reg   [8:0]   tx_reg; //串口发数据寄存器

//串口收数据
always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_reg[7:0] <= 8'd0;
  else if(read_flag == 1'b1)
    rx_reg[7:0] <= 8'd0;
  else if(pi_rx_flag == 1'b1)
    case (word_length)
      2'b00   : rx_reg[7:0] <= {3'd0, pi_rx_data[4:0]};
      2'b01   : rx_reg[7:0] <= {2'd0, pi_rx_data[5:0]};
      2'b10   : rx_reg[7:0] <= {1'd0, pi_rx_data[6:0]};
      2'b11   : rx_reg[7:0] <= pi_rx_data;
      default : rx_reg[7:0] <= 8'd0;
    endcase

assign po_rx_data = rx_reg;
    
always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    data_ready <= 1'b0;
  else if(read_flag == 1'b1)
    data_ready <= 1'b0;
  else if(pi_rx_flag == 1'b1)
    data_ready <= 1'b1;
    
//串口收错误1：奇偶校验错误
always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_reg[8] <= 1'b0;
  else if(read_flag == 1'b1)
    rx_reg[8] <= 1'b0;
  else if((parity[0] == 1'b1) && (pi_rx_flag == 1'b1))begin
    if(parity[1] == 1'b0)       //奇校验
      rx_reg[8] <= ~(^pi_rx_data);
    else if(parity[1] == 1'b1)  //偶校验
      rx_reg[8] <= (^pi_rx_data);
  end

assign parity_error = rx_reg[8];

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_reg[10:9] <= 2'b00;

//串口发数据
always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    tx_reg <= 9'd0;
  else if(write_flag == 1'b1)begin
    tx_reg[7:0] <= pi_tx_data;
    if(parity[0] == 1'b1)begin
      if(parity[2:1] == 2'b00)        //奇校验
        tx_reg[4'd5 + word_length] <= ~(^pi_tx_data);
      else if(parity[2:1] == 2'b01)   //偶校验
        tx_reg[4'd5 + word_length] <= (^pi_tx_data);
      else if(parity[2:1] == 2'b10)   //强制为1
        tx_reg[4'd5 + word_length] <= 1'b1;
      else if(parity[2:1] == 2'b11)   //强制为0
        tx_reg[4'd5 + word_length] <= 1'b0;
    end
  end

assign po_tx_data = tx_reg;
  
always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    po_tx_flag <= 1'b0;
  else 
    po_tx_flag <= write_flag;

endmodule