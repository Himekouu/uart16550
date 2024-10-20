`timescale 1ns/1ns
module tb_uart_16550();
  reg 					PCLK;
  reg 					PRESETn;
  reg 	[2:0]   PADDR;
  reg 					PSELx;
  reg 					PENABLE;
  reg 					PWRITE;
  reg 	[31:0]  PWDATA;
  reg           RXD;

  wire	[31:0]  PRDATA;
  wire          TXD;
  wire          irq;

initial begin
  PCLK = 1'b1;
  PRESETn <= 1'b0;
  PADDR <= 2'd0;
  PSELx <= 1'b0;
  PENABLE <= 1'b0;
  PWRITE <= 1'b0;
  PWDATA <= 32'bz;
  RXD <= 1'b1;
  #10
  PRESETn <= 1'b1;
end

initial begin
  #200
  APB_write(3'b011, 8'b1000_0000);  //修改DLAB
  // APB_write(3'b000, 8'b0101_1000);
  // APB_write(3'b001, 8'b0000_0010);
  APB_write(3'b000, 8'b0010_0000);  //设置波特率低八位
  APB_write(3'b001, 8'b0001_1100);  //设置波特率高八位
  APB_write(3'b011, 8'b0000_1011);  //设置字长为8，奇校验
  APB_write(3'b001, 8'b0000_0100);  //设置中断
  APB_write(3'b000, 8'b1010_0111);  //设置写入数据

end
initial begin
  #500
  rx_bit(9'b1_0110_1011, 2'd3, 16'd434, 1'b1);
  APB_read(3'b010);   //读中断类型信息
  APB_read(3'b101);   //读接收数据信息
  APB_read(3'b000);   //读接收数据
  APB_read(3'b101);   //读接收数据信息
  #9000
  APB_write(3'b001, 8'b0000_0001);  //设置中断
  APB_write(3'b011, 8'b0000_0011);  //设置字长为8，无奇偶校验
  rx_bit(9'b0_1100_0011, 2'd3, 16'd434, 1'b0);
  APB_read(3'b010);   //读中断类型信息
  APB_read(3'b101);   //读接收数据信息
  APB_read(3'b000);   //读接收数据
  APB_read(3'b101);   //读接收数据信息
end

always #10 PCLK = ~PCLK;

//APB总线写入数据
task APB_write(
  input  [2:0]   addr,
  input  [7:0]   data
);
begin
  PADDR <= addr;
  PWDATA <= {24'd0, data};
  PWRITE <= 1'b1;
  PSELx <= 1'b1;
  #20 
  PENABLE <= 1'b1;
  #20 
  PSELx <= 1'b0;
  PENABLE <= 1'b0;
  PWDATA <= 32'bz;
  #20;
end
endtask

//APB总线读出数据
task APB_read(
  input  [2:0]   addr
);
begin
  PADDR <= addr;
  PWRITE <= 1'b0;
  PSELx <= 1'b1;
  #20 
  PENABLE <= 1'b1;
  #20 
  PSELx <= 1'b0;
  PENABLE <= 1'b0;
  #20;
end
endtask

//发送RXD数据
task rx_bit(
  input  [8:0]   data,
  input  [1:0]   length,
  input  [15:0]  cnt,
  input          parity
);
integer i;
begin
  for (i = 0; i < 7 + length + parity; i = i + 1) begin
    case(i)
      0:RXD <= 1'd0;
      (6 + length + parity):RXD <= 1'b1;
      default:RXD <= data[i - 1];
    endcase
    #(cnt * 20);
  end
end
endtask

uart_16550 uart_16550_inst (
  .PCLK(PCLK),
  .PRESETn(PRESETn),
  .PADDR(PADDR),
  .PSELx(PSELx),
  .PENABLE(PENABLE),
  .PWRITE(PWRITE),
  .PWDATA(PWDATA),
  .RXD(RXD),

  .PRDATA(PRDATA),
  .TXD(TXD),
  .irq(irq)
);
endmodule