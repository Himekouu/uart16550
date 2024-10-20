module transmitter (
  input   wire          clk,
  input   wire          rst_n,
  input   wire  [1:0]   word_length,
  input   wire  [15:0]  baud_rate_cnt,
  input   wire          parity_en,
  input   wire          stop_bits,
  input   wire          set_break,
  input   wire  [8:0]   pi_tx_data,
  input   wire          pi_flag,

  output  reg           tx,
  output  wire          po_flag,
  output  wire          busy_flag
);

reg           work_en, bit_flag;
reg   [15:0]  baud_cnt;
reg   [3:0]   bit_cnt;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    work_en <= 1'b0;
  else if(pi_flag == 1'b1)
    work_en <= 1'b1;
  else if((bit_cnt == (4'd7 + word_length + parity_en + stop_bits)) && (bit_flag == 1'b1))
    work_en <= 1'b0;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    baud_cnt <= 16'd0;
  else if((work_en == 1'b0) || (baud_cnt == baud_rate_cnt))
    baud_cnt <= 16'd0;
  else if(work_en == 1'b1)
    baud_cnt <= baud_cnt + 1'b1;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    bit_flag <= 1'b0;
  else if(baud_cnt == 16'd1)
    bit_flag <= 1'b1;
  else
    bit_flag <= 1'b0;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    bit_cnt <= 4'd0;
  else if((bit_cnt == (4'd7 + word_length + parity_en + stop_bits)) && (bit_flag == 1'b1))
    bit_cnt <= 4'd0;
  else if((work_en == 1'b1) && (bit_flag == 1'b1))
    bit_cnt <= bit_cnt + 1'b1;

always @(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)
    tx <= 1'b1;
  else if(set_break == 1'b1)
    tx <= 1'b0;
  else if(bit_flag == 1'b1)
    case (bit_cnt)
      0       : tx <= 1'b0; 
      (4'd6 + word_length + parity_en): tx <= 1'b1;
      (4'd7 + word_length + parity_en): tx <= 1'b1;
      (4'd7 + word_length + parity_en + stop_bits): tx <= 1'b1;
      default : tx <= pi_tx_data[bit_cnt - 1];
    endcase

assign po_flag = (bit_cnt == (4'd7 + word_length + parity_en + stop_bits))? bit_flag : 1'b0;

assign busy_flag = (bit_cnt != 4'd0)? 1'b1 : 1'b0;

endmodule