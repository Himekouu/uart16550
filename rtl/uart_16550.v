module uart_16550 (
  input		wire					PCLK,
  input		wire					PRESETn,
  input		wire	[2:0]   PADDR,
  input		wire					PSELx,
  input		wire					PENABLE,
  input		wire					PWRITE,
  input		wire	[31:0]  PWDATA,
  input   wire          RXD,

  output  wire 	[31:0]  PRDATA,
  output  wire          TXD
);

wire  [1:0]   word_length;
wire  [15:0]  baud_rate_cnt;
wire  [2:0]   parity;
wire          stop_bits;
wire          set_break;

wire  [7:0]   tx_data;
wire          read_flag;
wire          write_flag;

wire  [7:0]   rx_data;
wire          parity_error;
wire          data_ready;

APB_UserRegisters APB_UserRegisters_inst (
  .PCLK(PCLK),
  .PRESETn(PRESETn),
  .PADDR(PADDR),
  .PSELx(PSELx),
  .PENABLE(PENABLE),
  .PWRITE(PWRITE),
  .PWDATA(PWDATA),

  .PRDATA(PRDATA),

  .rx_data(rx_data),
  .parity_error(parity_error),
  .data_ready(data_ready),

  .word_length(word_length),
  .baud_rate_cnt(baud_rate_cnt),
  .parity(parity),
  .stop_bits(stop_bits),
  .set_break(set_break),
  .tx_data(tx_data),
  .read_flag(read_flag),
  .write_flag(write_flag)
);

tx_rx tx_rx_inst (
  .clk(PCLK),
  .rst_n(PRESETn),
  .word_length(word_length),
  .baud_rate_cnt(baud_rate_cnt),
  .parity(parity),
  .stop_bits(stop_bits),
  .set_break(set_break),
  .rx(RXD),
  .pi_tx_data(tx_data),
  .read_flag(read_flag),
  .write_flag(write_flag),

  .tx(TXD),
  .po_rx_data(rx_data),
  .parity_error(parity_error),
  .data_ready(data_ready)
);
  
endmodule