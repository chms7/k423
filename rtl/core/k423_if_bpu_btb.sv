/*
 * @Design: k423_if_bpu_btb
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-12-10
 * @Description: Branch target buffer of bpu
 */
`include "k423_defines.svh"

module k423_if_bpu_btb (
  input                            clk_i,
  input                            rst_n_i,
  // pc for prediction
  input  logic [`CORE_ADDR_W-1:0]  prd_src_pc_i,
  // update
  input  logic                     upd_vld_i,
  input  logic                     upd_tkn_i,
  input  logic [`CORE_DATA_W-1:0]  upd_src_pc_i,
  input  logic [`CORE_DATA_W-1:0]  upd_tgt_pc_i,
  // predict
  output logic                     btb_prd_vld_o,
  output logic [`CORE_DATA_W-1:0]  btb_prd_tgt_pc_o
);
  // BTB
  logic [`BTB_WIDTH-1:0] btb_q [`BTB_DEPTH-1:0];
  logic [`BTB_WIDTH-1:0] btb_d;
  
  // index & tag
  wire [$clog2(`BTB_DEPTH)-1:0] btb_upd_idx = upd_src_pc_i[$clog2(`BTB_DEPTH)+1:2];
  wire [$clog2(`BTB_DEPTH)-1:0] btb_prd_idx = prd_src_pc_i[$clog2(`BTB_DEPTH)+1:2];
  wire [`BTB_TAG_W-1:0]         btb_upd_tag = upd_src_pc_i[`BTB_TAG_W+$clog2(`BTB_DEPTH)+1:$clog2(`BTB_DEPTH)+2];
  wire [`BTB_TAG_W-1:0]         btb_prd_tag = prd_src_pc_i[`BTB_TAG_W+$clog2(`BTB_DEPTH)+1:$clog2(`BTB_DEPTH)+2];
  
  // update
  integer btb_rst_idx;
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (btb_rst_idx = `BTB_DEPTH-1; btb_rst_idx >= 0; btb_rst_idx = btb_rst_idx - 1) begin
        btb_q[btb_rst_idx] <= '0;
      end
    end else if (upd_vld_i & upd_tkn_i) begin
        btb_q[btb_upd_idx] <= btb_d;
    end
  end
  
  assign btb_d[`BTB_VLD_BITS] = 1'b1;
  assign btb_d[`BTB_TAG_BITS] = btb_upd_tag;
  assign btb_d[`BTB_BTA_BITS] = upd_tgt_pc_i;
  
  // read BTB for prediction
  assign btb_prd_vld_o    = btb_q[btb_prd_idx][`BTB_VLD_BITS] & (btb_q[btb_prd_idx][`BTB_TAG_BITS] == btb_prd_tag);
  assign btb_prd_tgt_pc_o = btb_q[btb_prd_idx][`BTB_BTA_BITS];

endmodule
