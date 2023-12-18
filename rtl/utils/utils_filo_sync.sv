/*
 * @Design: utils_filo_sync
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-12-16
 * @Description: Synchronized First-In-Last-Out
 */

module utils_filo_sync #(
  parameter FILO_WIDTH = 32,
  parameter FILO_DEPTH = 16
)(
  input                         clk_i,
  input                         rst_n_i,

  input  logic                  filo_wr_i,
  input  logic [FILO_WIDTH-1:0] filo_wdata_i,
  input  logic                  filo_rd_i,
  output logic [FILO_WIDTH-1:0] filo_rdata_o,

  output logic                  filo_full_o,
  output logic                  filo_empty_o
);
  // filo
  logic [FILO_WIDTH-1:0] filo_q [FILO_DEPTH-1:0];
  logic [$clog2(FILO_DEPTH)  :0] filo_cnt;  // status  of full/empty
  logic [$clog2(FILO_DEPTH)-1:0] filo_ptr;  // pointer of read/write
  
  // write & read enable
  wire filo_wr_en = filo_wr_i;  // replace the oldest data
  wire filo_rd_en = filo_rd_i & ~filo_empty_o;
  
  // write
  integer filo_rst_idx;
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (filo_rst_idx = 0; filo_rst_idx < FILO_DEPTH; filo_rst_idx = filo_rst_idx + 1) begin
        filo_q[filo_rst_idx] <= '0;
      end
    end else if (filo_wr_en) begin
        filo_q[filo_ptr]     <= filo_wdata_i;
    end
  end
  
  // read
  assign filo_rdata_o = filo_q[filo_ptr-1];
  
  // update ptr
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      filo_cnt <= '0;
      filo_ptr <= '0;
    end else if (filo_wr_en) begin
      filo_cnt <= filo_full_o ? filo_cnt : (filo_cnt + 1'b1);
      filo_ptr <= filo_ptr + 1'b1;
    end else if (filo_rd_en) begin
      filo_cnt <= filo_cnt - 1'b1;
      filo_ptr <= filo_ptr - 1'b1;
    end
  end
  
  // full & empty flag
  assign filo_full_o  = filo_cnt == FILO_DEPTH;
  assign filo_empty_o = filo_cnt == '0;

endmodule
