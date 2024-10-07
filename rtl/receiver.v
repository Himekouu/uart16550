module receiver (
  input   wire          clk,
  input   wire          rst_n,
  input   wire  [1:0]   word_length,    //数据长度
  input   wire  [15:0]  baud_rate_cnt,  //波特率计数上限
  input   wire          parity_en,      //是否启用奇偶校验
  input   wire          rx,

  output  reg   [8:0]   po_rx_data,     //接收的数据
  output  reg           po_flag         //接收完毕的标志
);

reg           rx_reg1, rx_reg2, rx_reg3;
reg           start_flag;
reg           work_en;
reg   [15:0]  baud_cnt;
reg           bit_flag;
reg   [3:0]   bit_cnt;
reg   [8:0]   rx_data;
reg           rx_flag;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_reg1 <= 1'b1;
  else
    rx_reg1 <= rx;
  
always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_reg2 <= 1'b1;
  else
    rx_reg2 <= rx_reg1;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_reg3 <= 1'b1;
  else
    rx_reg3 <= rx_reg2;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    start_flag <= 1'b0;
  else if((rx_reg3 == 1'b1) && (rx_reg2 == 1'b0) && (work_en == 1'b0))
    start_flag <= 1'b1;
  else
    start_flag <= 1'b0;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    work_en <= 1'b0;
  else if(start_flag == 1'b1)
    work_en <= 1'b1;
  else if((bit_cnt == (4'd5 + word_length + parity_en)) && (bit_flag == 1'b1))
    work_en <= 1'b0;
  else
    work_en <= work_en;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    baud_cnt <= 16'd0;
  else if((baud_cnt == baud_rate_cnt - 1) || (work_en == 1'b0))
    baud_cnt <= 16'd0;
  else
    baud_cnt <= baud_cnt + 1'b1;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    bit_flag <= 1'b0;
  else if(baud_cnt == (baud_rate_cnt - 2) / 2)
    bit_flag <= 1'b1;
  else
    bit_flag <= 1'b0;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    bit_cnt <= 4'd0;
  else if((bit_cnt == (4'd5 + word_length + parity_en)) && (bit_flag == 1'b1))
    bit_cnt <= 4'd0;
  else if(bit_flag == 1'b1)
    bit_cnt <= bit_cnt + 1'b1;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_data <= 8'b0;
  else if((bit_cnt >= 4'd1) && (bit_cnt <= (4'd5 + word_length + parity_en)) && (bit_flag == 1'b1))
    rx_data <= {rx_reg3, rx_data[8:1]};

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    rx_flag <= 1'b0;
  else if((bit_cnt == (4'd5 + word_length + parity_en)) && (bit_flag == 1'b1))
    rx_flag <= 1'b1;
  else
    rx_flag <= 1'b0;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    po_rx_data <= 8'b0;
  else if(rx_flag == 1'b1)
    po_rx_data <= rx_data >> (4 - word_length - parity_en);

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    po_flag <= 1'b0;
  else
    po_flag <= rx_flag;

endmodule