/*
 * @Design: k423_id_stage
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Instruction-Decode stage of core
 */
`include "k423_defines.svh"

module k423_id_stage (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline handshake
  input  logic                      if_stage_vld_i,
  output logic                      id_stage_vld_o,
  output logic                      id_stage_rdy_o,
  input  logic                      ex_stage_rdy_i,
  // if stage
  input  logic [`CORE_ADDR_W-1:0]   if_pc_i,
  input  logic [`CORE_INST_W-1:0]   if_inst_i,

  input  logic                      if_bpu_prd_tkn_i,
  input  logic [`CORE_ADDR_W-1:0]   if_bpu_prd_pc_i,
  input  logic [1:0]                if_bpu_prd_sat_cnt_i,
  // decode information
  output logic [`CORE_ADDR_W-1:0]   id_pc_o,
  output logic [`CORE_INST_W-1:0]   id_inst_o,
  output logic [`INST_GRP_W-1:0]    id_dec_grp_o,
  output logic [`INST_INFO_W-1:0]   id_dec_info_o,
  
  output logic                      id_dec_rs1_vld_o,
  output logic [`INST_RSDIDX_W-1:0] id_dec_rs1_idx_o,
  output logic                      id_dec_rs2_vld_o,
  output logic [`INST_RSDIDX_W-1:0] id_dec_rs2_idx_o,
  output logic                      id_dec_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] id_dec_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     id_dec_imm_o,

  output logic [`LS_SIZE_W-1:0]     id_dec_load_size_o,
  output logic [`LS_SIZE_W-1:0]     id_dec_store_size_o,
  
  output logic [`EXCP_TYPE_W-1:0]   id_dec_excp_type_o,
  output logic [`INT_TYPE_W-1:0]    id_dec_int_type_o,
  output logic [`INST_CSRADR_W-1:0] id_dec_csr_addr_o,
  output logic [`INST_ZIMM_W-1:0]   id_dec_csr_zimm_o,

  output logic                      id_bpu_prd_tkn_o,
  output logic [`CORE_ADDR_W-1:0]   id_bpu_prd_pc_o,
  output logic [1:0]                id_bpu_prd_sat_cnt_o
);
  // ---------------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------------
  k423_id_decode u_k423_id_decode (
    .if_inst_i        ( if_inst_i           ),
  
    .dec_grp_o        ( id_dec_grp_o        ),
    .dec_info_o       ( id_dec_info_o       ),

    .dec_rs1_vld_o    ( id_dec_rs1_vld_o    ),
    .dec_rs1_idx_o    ( id_dec_rs1_idx_o    ),
    .dec_rs2_vld_o    ( id_dec_rs2_vld_o    ),
    .dec_rs2_idx_o    ( id_dec_rs2_idx_o    ),
    .dec_rd_vld_o     ( id_dec_rd_vld_o     ),
    .dec_rd_idx_o     ( id_dec_rd_idx_o     ),
    .dec_imm_o        ( id_dec_imm_o        ),

    .dec_load_size_o  ( id_dec_load_size_o  ),
    .dec_store_size_o ( id_dec_store_size_o ),

    .dec_excp_type_o  ( id_dec_excp_type_o  ),
    .dec_int_type_o   ( id_dec_int_type_o   ),
    .dec_csr_addr_o   ( id_dec_csr_addr_o   ),
    .dec_csr_zimm_o   ( id_dec_csr_zimm_o   )
  );
  
  assign id_pc_o              = if_pc_i;
  assign id_inst_o            = if_inst_i;
  assign id_bpu_prd_tkn_o     = if_bpu_prd_tkn_i;
  assign id_bpu_prd_pc_o      = if_bpu_prd_pc_i;
  assign id_bpu_prd_sat_cnt_o = if_bpu_prd_sat_cnt_i;

  // ---------------------------------------------------------------------------
  // Pipeline Handshake
  // ---------------------------------------------------------------------------
  wire   id_stage_done  = 1'b1;
  assign id_stage_vld_o = if_stage_vld_i & id_stage_done;
  assign id_stage_rdy_o = ~if_stage_vld_i | id_stage_done & ex_stage_rdy_i;
  
endmodule
