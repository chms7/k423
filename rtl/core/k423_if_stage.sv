/*
 * @Design: k423_if_stage
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Instruction-Fetch stage of core
 */
`include "k423_defines.svh"

module k423_if_stage (
  input                            clk_i,
  input                            rst_n_i,
  // pipeline control
  input                            pcu_clear_pc_i,
  input                            pcu_stall_pc_i,
  // pipeline handshake
  output logic                     if_stage_vld_o,
  input  logic                     id_stage_rdy_i,
  // branch
  input  logic                     wb_excp_br_tkn_i,
  input  logic [`CORE_XLEN-1:0]    wb_excp_br_pc_i,
  input  logic                     wb_bju_upd_vld_i,
  input  logic                     wb_bju_upd_mis_i,
  input  logic                     wb_bju_upd_tkn_i,
  input  logic [`BR_TYPE_W-1:0]    wb_bju_upd_type_i,
  input  logic [`CORE_XLEN-1:0]    wb_bju_upd_src_pc_i,
  input  logic [`CORE_XLEN-1:0]    wb_bju_upd_tgt_pc_i,
  input  logic [1:0]               wb_bju_upd_sat_cnt_i,
  // inst mem interface
  output logic                     if_mem_req_vld_o,
  output logic                     if_mem_req_wen_o,
  output logic [`CORE_ADDR_W -1:0] if_mem_req_addr_o,
  output logic [`CORE_XLEN-1:0]    if_mem_req_wdata_o,
  input  logic                     if_mem_req_rdy_i,
  input  logic                     if_mem_rsp_vld_i,
  input  logic [`CORE_FETCH_W-1:0] if_mem_rsp_rdata_i,
  // if stage
  output logic [`CORE_ADDR_W-1:0]  if_pc_o,
  output logic [`CORE_INST_W-1:0]  if_inst_o,
  output logic                     if_bpu_prd_tkn_o,
  output logic [`CORE_ADDR_W-1:0]  if_bpu_prd_pc_o,
  output logic [1:0]               if_bpu_prd_sat_cnt_o
);
  // ---------------------------------------------------------------------------
  // Fetch
  // ---------------------------------------------------------------------------
  logic pc_stage_vld_w;
  logic if_stage_rdy_w;

  k423_if_fetch u_k423_if_fetch (
    .clk_i              ( clk_i               ),
    .rst_n_i            ( rst_n_i             ),
    
    .pcu_clear_pc_i     ( pcu_clear_pc_i      ),
    .pcu_stall_pc_i     ( pcu_stall_pc_i      ),
    
    .pc_stage_vld_o     ( pc_stage_vld_w      ),
    .if_stage_rdy_i     ( if_stage_rdy_w      ),
    
    .wb_excp_br_tkn_i   ( wb_excp_br_tkn_i    ),
    .wb_excp_br_pc_i    ( wb_excp_br_pc_i     ),
    .wb_bju_br_mis_i    ( wb_bju_upd_mis_i    ),
    .wb_bju_br_pc_i     ( wb_bju_upd_tgt_pc_i ),
    .if_bpu_br_tkn_i    ( if_bpu_prd_tkn_o    ),
    .if_bpu_br_pc_i     ( if_bpu_prd_pc_o     ),
  
    .if_mem_req_vld_o   ( if_mem_req_vld_o    ),
    .if_mem_req_wen_o   ( if_mem_req_wen_o    ),
    .if_mem_req_addr_o  ( if_mem_req_addr_o   ),
    .if_mem_req_wdata_o ( if_mem_req_wdata_o  ),
    .if_mem_req_rdy_i   ( if_mem_req_rdy_i    ),
    .if_mem_rsp_vld_i   ( if_mem_rsp_vld_i    ),
    .if_mem_rsp_rdata_i ( if_mem_rsp_rdata_i  ),

    .pc_o               ( if_pc_o             ),
    .inst_o             ( if_inst_o           )
  );

`ifdef BPU_EN
  // ---------------------------------------------------------------------------
  // Mini-decode
  // ---------------------------------------------------------------------------
  logic                  dec_br_w;
  logic                  dec_bxx_w;
  logic                  dec_jal_w;
  logic                  dec_jalr_w;
  logic                  dec_call_w;
  logic                  dec_ret_w;
  logic [`CORE_XLEN-1:0] dec_imm_w;
  
  k423_if_minidec  u_k423_if_minidec (
    .inst_i     ( if_inst_o  ),

    .dec_br_o   ( dec_br_w   ),
    .dec_bxx_o  ( dec_bxx_w  ),
    .dec_jal_o  ( dec_jal_w  ),
    .dec_jalr_o ( dec_jalr_w ),
    .dec_call_o ( dec_call_w ),
    .dec_ret_o  ( dec_ret_w  ),
    .dec_imm_o  ( dec_imm_w  )
  );

  // ---------------------------------------------------------------------------
  // Branch Predict
  // ---------------------------------------------------------------------------

  k423_if_bpu  u_k423_if_bpu (
    .clk_i             ( clk_i                ),
    .rst_n_i           ( rst_n_i              ),

    .pc_i              ( if_pc_o              ),
    .inst_i            ( if_inst_o            ),

    .dec_br_i          ( dec_br_w             ),
    .dec_bxx_i         ( dec_bxx_w            ),
    .dec_jal_i         ( dec_jal_w            ),
    .dec_jalr_i        ( dec_jalr_w           ),
    .dec_call_i        ( dec_call_w           ),
    .dec_ret_i         ( dec_ret_w            ),
    .dec_imm_i         ( dec_imm_w            ),

    .upd_vld_i         ( wb_bju_upd_vld_i     ),
    .upd_tkn_i         ( wb_bju_upd_tkn_i     ),
    .upd_mis_i         ( wb_bju_upd_mis_i     ),
    .upd_type_i        ( wb_bju_upd_type_i    ),
    .upd_src_pc_i      ( wb_bju_upd_src_pc_i  ),
    .upd_tgt_pc_i      ( wb_bju_upd_tgt_pc_i  ),
    .upd_sat_cnt_i     ( wb_bju_upd_sat_cnt_i ),

    .bpu_prd_tkn_o     ( if_bpu_prd_tkn_o     ),
    .bpu_prd_pc_o      ( if_bpu_prd_pc_o      ),
    .bpu_prd_sat_cnt_o ( if_bpu_prd_sat_cnt_o )
  );

`else

  assign if_bpu_prd_tkn_o     = '0;
  assign if_bpu_prd_pc_o      = '0;
  assign if_bpu_prd_sat_cnt_o = '0;

`endif

  // ---------------------------------------------------------------------------
  // Pipeline Handshake
  // ---------------------------------------------------------------------------
  wire   if_stage_done  = if_mem_rsp_vld_i;
  assign if_stage_vld_o = pc_stage_vld_w & if_stage_done;
  assign if_stage_rdy_w = ~pc_stage_vld_w | if_stage_done & id_stage_rdy_i;

endmodule
