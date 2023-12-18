/*
 * @Design: k423_if_bpu
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-12-10
 * @Description: Branch predict unit of if stage
 */
`include "k423_defines.svh"

module k423_if_bpu (
  input                           clk_i,
  input                           rst_n_i,
  // pc & instruction
  input  logic [`CORE_ADDR_W-1:0] pc_i,
  input  logic [`CORE_DATA_W-1:0] inst_i,
  // mini-decode
  input  logic                    dec_br_i,
  input  logic                    dec_bxx_i,
  input  logic                    dec_jal_i,
  input  logic                    dec_jalr_i,
  input  logic                    dec_call_i,
  input  logic                    dec_ret_i,
  input  logic [`CORE_XLEN-1:0]   dec_imm_i,
  // update
  input  logic                    upd_vld_i,
  input  logic                    upd_tkn_i,
  input  logic                    upd_mis_i,
  input  logic [`BR_TYPE_W-1:0]   upd_type_i,
  input  logic [`CORE_DATA_W-1:0] upd_src_pc_i,
  input  logic [`CORE_DATA_W-1:0] upd_tgt_pc_i,
  input  logic [1:0]              upd_sat_cnt_i,
  // predict
  output logic                    bpu_prd_tkn_o,
  output logic [`CORE_ADDR_W-1:0] bpu_prd_pc_o,
  output logic [1:0]              bpu_prd_sat_cnt_o
);
  // ---------------------------------------------------------------------------
  // Branch History Table
  // ---------------------------------------------------------------------------
  logic       bht_prd_tkn;
  logic [1:0] bht_prd_sat_cnt;

  k423_if_bpu_bht  u_k423_if_bpu_bht (
    .clk_i             ( clk_i           ),
    .rst_n_i           ( rst_n_i         ),

    .prd_src_pc_i      ( pc_i            ),

    .upd_vld_i         ( upd_vld_i       ),
    .upd_tkn_i         ( upd_tkn_i       ),
    .upd_src_pc_i      ( upd_src_pc_i    ),
    .upd_sat_cnt_i     ( upd_sat_cnt_i   ),

    .bht_prd_tkn_o     ( bht_prd_tkn     ),
    .bht_prd_sat_cnt_o ( bht_prd_sat_cnt )
  );
  
  // ---------------------------------------------------------------------------
  // Branch Target Buffer
  // ---------------------------------------------------------------------------
  logic                    btb_prd_vld;
  logic [`CORE_DATA_W-1:0] btb_prd_tgt_pc;

  k423_if_bpu_btb  u_k423_if_bpu_btb (
    .clk_i            ( clk_i          ),
    .rst_n_i          ( rst_n_i        ),

    .prd_src_pc_i     ( pc_i           ),

    .upd_vld_i        ( upd_vld_i      ),
    .upd_tkn_i        ( upd_tkn_i      ),
    .upd_src_pc_i     ( upd_src_pc_i   ),
    .upd_tgt_pc_i     ( upd_tgt_pc_i   ),

    .btb_prd_vld_o    ( btb_prd_vld    ),
    .btb_prd_tgt_pc_o ( btb_prd_tgt_pc )
  );

  // ---------------------------------------------------------------------------
  // Return Address Stack
  // ---------------------------------------------------------------------------
  wire                    ras_vld;
  wire [`CORE_DATA_W-1:0] ras_ret_pc;

  k423_if_bpu_ras  u_k423_if_bpu_ras (
    .clk_i          ( clk_i           ),
    .rst_n_i        ( rst_n_i         ),

    .upd_vld_i      ( upd_vld_i       ),
    .upd_tkn_i      ( upd_tkn_i       ),
    .upd_type_i     ( upd_type_i      ),
    .upd_src_pc_i   ( upd_src_pc_i    ),
    .upd_tgt_pc_i   ( upd_tgt_pc_i    ),
    .upd_sat_cnt_i  ( upd_sat_cnt_i   ),

    .ras_vld_o      ( ras_vld         ),
    .ras_ret_pc_o   ( ras_ret_pc      )
  );
  
  // ---------------------------------------------------------------------------
  // Branch Prediction
  // ---------------------------------------------------------------------------
  assign bpu_prd_tkn_o     = dec_br_i & bht_prd_tkn & btb_prd_vld;
  assign bpu_prd_pc_o      = dec_ret_i ? ras_ret_pc : btb_prd_tgt_pc;
  assign bpu_prd_sat_cnt_o = bht_prd_sat_cnt;

endmodule
