`timescale 1ns/1ns
module tb_APB_UserRegisters();
  reg 					PCLK;
  reg 					PRESETn;
  reg 	[2:0]   PADDR;
  reg 					PSELx;
  reg 					PENABLE;
  reg 					PWRITE;
  reg 	[31:0]  PWDATA;

  wire	[31:0]  PRDATA;

initial begin
  PCLK = 1'b1;
  PRESETn <= 1'b0;
  PADDR <= 2'd0;
  PSELx <= 1'b0;
  PENABLE <= 1'b0;
  PWRITE <= 1'b0;
  PWDATA <= 32'bz;
  #10
  PRESETn <= 1'b1;
end

initial begin
  #200
  APB_read(3'b001);
  APB_write(3'b001, 8'b1111_1111);
  APB_read(3'b001);

  APB_read(3'b011);
  APB_write(3'b011, 8'b1010_1010);
  APB_read(3'b011);

  APB_read(3'b001);
  APB_write(3'b001, 8'b1111_1111);
  APB_read(3'b001);
end

always #10 PCLK = ~PCLK;

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

APB_UserRegisters APB_UserRegisters_inst (
  .PCLK(PCLK),
  .PRESETn(PRESETn),
  .PADDR(PADDR),
  .PSELx(PSELx),
  .PENABLE(PENABLE),
  .PWRITE(PWRITE),
  .PWDATA(PWDATA),

  .PRDATA(PRDATA)
);
endmodule