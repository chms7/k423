/*
 * @Design: k423_if_bpu_bht
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-12-10
 * @Description: Branch history table of bpu
 */
`include "k423_defines.svh"

module k423_if_bpu_bht (
  input                           clk_i,
  input                           rst_n_i,
  // pc & instruction
  input  logic [`CORE_ADDR_W-1:0] prd_src_pc_i,
  // update
  input  logic                    upd_vld_i,
  input  logic                    upd_tkn_i,
  input  logic [`CORE_DATA_W-1:0] upd_src_pc_i,
  input  logic [1:0]              upd_sat_cnt_i,
  // predict
  output logic                    bht_prd_tkn_o,
  output logic [1:0]              bht_prd_sat_cnt_o
);
  // ---------------------------------------------------------------------------
  // BHT
  // ---------------------------------------------------------------------------
  logic [`BHT_WIDTH-1:0] bht_q [`BHT_DEPTH-1:0];

  // BHT index: part of PC
  wire [$clog2(`BHT_DEPTH)-1:0] bht_upd_idx = upd_src_pc_i[$clog2(`BHT_DEPTH)+1:2];
  wire [$clog2(`BHT_DEPTH)-1:0] bht_prd_idx = prd_src_pc_i[$clog2(`BHT_DEPTH)+1:2];

  // update BHR
  integer bht_rst_idx;
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (bht_rst_idx = `BHT_DEPTH-1; bht_rst_idx >= 0; bht_rst_idx = bht_rst_idx - 1) begin
        bht_q[bht_rst_idx] <= '0;
      end
    end else if (upd_vld_i) begin
      if (upd_tkn_i) begin
        bht_q[bht_upd_idx] <= {bht_q[bht_upd_idx][`BHT_WIDTH-2:0], 1'b1};
      end else begin
        bht_q[bht_upd_idx] <= {bht_q[bht_upd_idx][`BHT_WIDTH-2:0], 1'b0};
      end
    end
  end

  // ---------------------------------------------------------------------------
  // PHT
  // ---------------------------------------------------------------------------
  logic [1:0] pht_q [`PHT_DEPTH-1:0];
  logic [1:0] pht_d;

  // PHT index: {BHR ^ PC[y:x], PC[x-1:2]}
  // hash-code: BHR ^ PC[y:x]
  wire [`BHT_WIDTH-1:0] pht_prd_hash_idx    = bht_q[bht_prd_idx] ^ prd_src_pc_i[($clog2(`PHT_DEPTH))+1: ($clog2(`PHT_DEPTH)-`BHT_WIDTH)+2];
  wire [`BHT_WIDTH-1:0] pht_upd_hash_idx    = bht_q[bht_upd_idx] ^ upd_src_pc_i[($clog2(`PHT_DEPTH))+1: ($clog2(`PHT_DEPTH)-`BHT_WIDTH)+2];
  // concat PC[x-1:2]
  wire [$clog2(`PHT_DEPTH)-`BHT_WIDTH-1:0]
                        pht_prd_concat_idx  = prd_src_pc_i[($clog2(`PHT_DEPTH)-`BHT_WIDTH)+1:2];
  wire [$clog2(`PHT_DEPTH)-`BHT_WIDTH-1:0]
                        pht_upd_concat_idx  = upd_src_pc_i[($clog2(`PHT_DEPTH)-`BHT_WIDTH)+1:2];
  // PHT index
  wire [$clog2(`PHT_DEPTH)-1:0] pht_prd_idx = {pht_prd_hash_idx, pht_prd_concat_idx};
  wire [$clog2(`PHT_DEPTH)-1:0] pht_upd_idx = {pht_upd_hash_idx, pht_upd_concat_idx};

  // update PHT
  integer pht_rst_idx;
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (pht_rst_idx = `PHT_DEPTH-1; pht_rst_idx >= 0; pht_rst_idx = pht_rst_idx - 1) begin
        pht_q[pht_rst_idx] <= `PHT_NTKN_STRONG;
      end
    end else if (upd_vld_i) begin
        pht_q[pht_upd_idx] <= pht_d;
    end
  end
  
  assign pht_d = upd_sat_cnt_i;
  // always @(*) begin
  //   pht_d = pht_q[pht_upd_idx];

  //   if (pht_q[pht_upd_idx] == `PHT_NTKN_STRONG) begin
  //     if (upd_tkn_i) begin
  //       pht_d = `PHT_NTKN_WEAK;
  //     end else begin
  //       pht_d = `PHT_NTKN_STRONG;
  //     end
  //   end else if (pht_q[pht_upd_idx] == `PHT_NTKN_WEAK) begin
  //     if (upd_tkn_i) begin
  //       pht_d = `PHT_TKN_WEAK;
  //     end else begin
  //       pht_d = `PHT_NTKN_WEAK;
  //     end
  //   end else if (pht_q[pht_upd_idx] == `PHT_TKN_WEAK) begin
  //     if (upd_tkn_i) begin
  //       pht_d = `PHT_TKN_STRONG;
  //     end else begin
  //       pht_d = `PHT_NTKN_WEAK;
  //     end
  //   end else if (pht_q[pht_upd_idx] == `PHT_TKN_STRONG) begin
  //     if (upd_tkn_i) begin
  //       pht_d = `PHT_TKN_WEAK;
  //     end else begin
  //       pht_d = `PHT_TKN_STRONG;
  //     end
  //   end
  // end

  // read PHT for prediction
  wire [1:0] pht_prd = pht_q[pht_prd_idx];
  assign bht_prd_sat_cnt_o = pht_prd;

  // ---------------------------------------------------------------------------
  // Predict Result
  // ---------------------------------------------------------------------------
  // STRONG TAKEN or WEAK TAKEN
  assign bht_prd_tkn_o = pht_prd[1];

endmodule
