module APB_UserRegisters (
  input		wire					PCLK,
  input		wire					PRESETn,
  input		wire	[2:0]   PADDR,
  input		wire					PSELx,
  input		wire					PENABLE,
  input		wire					PWRITE,
  input		wire	[31:0]  PWDATA,

  output  reg 	[31:0]  PRDATA,

  input		wire	[7:0]   rx_data,
  input		wire					parity_error,
  input		wire					data_ready,

  output	wire	[1:0]   word_length,
  output	wire	[15:0]  baud_rate_cnt,
  output	wire	[2:0]   parity,
  output	wire	        stop_bits,
  output	wire	        set_break,
  output	wire	[7:0]   tx_data,
  output	reg 	        read_flag,
  output	reg 	        write_flag,

  input		wire	        interrupt_status,
  input		wire	[2:0]   interrupt_type,

  output 	reg 	[5:0]   interrupt_en,
  output 	wire	        error
);
//General Register Set
reg   [7:0]   RHR;  //000  R  Receiver Holding Register
reg   [7:0]   THR;  //000  W  Transmitter Holding Register
reg   [7:0]   IER;  //001 R/W Interrupt Enable Register
reg   [7:0]   ISR;  //010  R  Interrupt Status Register
reg   [7:0]   FCR;  //010  W  FIFO Control Register
reg   [7:0]   LCR;  //011 R/W Line Control Register
reg   [7:0]   MCR;  //100 R/W Modern Control Register
reg   [7:0]   LSR;  //101  R  Line Status Register
reg   [7:0]   MSR;  //110  R  Modern Status Register
reg   [7:0]   SPR;  //111 R/W Scratch Pad Register

//Registers accesible only when DLAB = 1
reg   [7:0]   DLL;  //000 R/W Divisor Latch, Least signif. byte
reg   [7:0]   DLM;  //001 R/W Divisor Latch, Most signif. byte
reg   [7:0]   PSD;  //010  W  Prescaler Division

always @(posedge PCLK or negedge PRESETn)
  if(PRESETn == 1'b0)
    begin
      PRDATA <= 32'bz;

      THR <= 8'd0;
      IER <= 8'd0;
      FCR <= 8'd0;
      LCR <= 8'd0;
      MCR <= 8'd0;
      MSR <= 8'd0;
      SPR <= 8'd0;

      DLL <= 8'd0;
      DLM <= 8'd0;
      PSD <= 8'd0;
    end
  else if((PWRITE == 1'b1) && (PSELx == 1'b1) && (PENABLE == 1'b1))
    begin
      if(LCR[7] == 1'b0)
        case (PADDR)
          3'b000  : THR <= PWDATA[7:0];
          3'b001  : IER <= PWDATA[7:0];
          3'b010  : FCR <= PWDATA[7:0];
          3'b011  : LCR <= PWDATA[7:0];
          3'b100  : MCR <= PWDATA[7:0];
          3'b111  : SPR <= PWDATA[7:0];
        endcase
      else if(LCR[7] == 1'b1)
        case (PADDR)
          3'b000  : DLL <= PWDATA[7:0];
          3'b001  : DLM <= PWDATA[7:0];
          3'b010  : FCR <= PWDATA[7:0];
          3'b011  : LCR <= PWDATA[7:0];
          3'b100  : MCR <= PWDATA[7:0];
          3'b101  : PSD <= PWDATA[7:0];
          3'b111  : SPR <= PWDATA[7:0];
        endcase
    end
  else if((PWRITE == 1'b0) && (PSELx == 1'b1) && (PENABLE == 1'b1))
    PRDATA <= 32'bz;
  else if((PWRITE == 1'b0) && (PSELx == 1'b1))
    begin
      if(LCR[7] == 1'b0)
        case (PADDR)
          3'b000  : PRDATA <= {24'd0, RHR};
          3'b001  : PRDATA <= {24'd0, IER};
          3'b010  : PRDATA <= {24'd0, ISR};
          3'b011  : PRDATA <= {24'd0, LCR};
          3'b100  : PRDATA <= {24'd0, MCR};
          3'b101  : PRDATA <= {24'd0, LSR};
          3'b110  : PRDATA <= {24'd0, MSR};
          3'b111  : PRDATA <= {24'd0, SPR};
          default : PRDATA <= 32'b0;
        endcase
      else if(LCR[7] == 1'b1)
        case (PADDR)
          3'b000  : PRDATA <= {24'd0, DLL};
          3'b001  : PRDATA <= {24'd0, DLM};
          3'b010  : PRDATA <= {24'd0, ISR};
          3'b011  : PRDATA <= {24'd0, LCR};
          3'b100  : PRDATA <= {24'd0, MCR};
          3'b101  : PRDATA <= {24'd0, LSR};
          3'b110  : PRDATA <= {24'd0, MSR};
          3'b111  : PRDATA <= {24'd0, SPR};
          default : PRDATA <= 32'b0;
        endcase
    end

always @(posedge PCLK or negedge PRESETn)
  if(PRESETn == 1'b0)
    RHR <= 8'd0;
  else
    RHR <= rx_data;

always @(posedge PCLK or negedge PRESETn)
  if(PRESETn == 1'b0)
    LSR <= 8'd0;
  else begin
    LSR[0] <= data_ready;
    LSR[2] <= parity_error;
  end

always @(posedge PCLK or negedge PRESETn)
  if(PRESETn == 1'b0)
    interrupt_en <= 6'd0;
  else begin
    interrupt_en <= {IER[7:6], IER[3:0]};
  end

always @(posedge PCLK or negedge PRESETn)
  if(PRESETn == 1'b0)
    ISR <= 8'd0;
  else begin
    ISR[0] <= ~interrupt_status;
    ISR[3:1] <= interrupt_type;
  end

always @(posedge PCLK or negedge PRESETn)
  if(PRESETn == 1'b0)
    read_flag <= 1'b0;
  else if((PWRITE == 1'b0) && (PSELx == 1'b1) && (PADDR == 3'b000) && (LCR[7] == 1'b0))
    read_flag <= 1'b1;
  else
    read_flag <= 1'b0;

always @(posedge PCLK or negedge PRESETn)
  if(PRESETn == 1'b0)
    write_flag <= 1'b0;
  else if((PWRITE == 1'b1) && (PSELx == 1'b1) && (PENABLE == 1'b1) && (PADDR == 3'b000) && (LCR[7] == 1'b0))
    write_flag <= 1'b1;
  else
    write_flag <= 1'b0;
    
assign word_length = LCR[1:0];
assign stop_bits = LCR[2];
assign parity = LCR[5:3];
assign set_break = LCR[6];

assign tx_data = THR;

assign baud_rate_cnt = (22'd3_125_000 / {DLM, DLL});

assign error = LSR[2];
  
endmodule