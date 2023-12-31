/*
 * @Design: k423_ex_stage
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Execute stage of core
 */
`include "k423_defines.svh"

module k423_ex_stage (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline handshake
  input  logic                      id_stage_vld_i,
  output logic                      ex_stage_vld_o,
  output logic                      ex_stage_rdy_o,
  input  logic                      wb_stage_rdy_i,
  // id stage
  input  logic [`CORE_ADDR_W-1:0]   id_pc_i,
  input  logic [`CORE_INST_W-1:0]   id_inst_i,
  input  logic [`INST_GRP_W-1:0]    id_dec_grp_i,
  input  logic [`INST_INFO_W-1:0]   id_dec_info_i,

  input  logic                      id_dec_rs1_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] id_dec_rs1_idx_i,
  input  logic [`CORE_XLEN-1:0]     id_dec_rs1_i,
  input  logic                      id_dec_rs2_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] id_dec_rs2_idx_i,
  input  logic [`CORE_XLEN-1:0]     id_dec_rs2_i,
  input  logic                      id_dec_rd_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] id_dec_rd_idx_i,
  input  logic [`CORE_XLEN-1:0]     id_dec_imm_i,

  input  logic [`LS_SIZE_W-1:0]     id_dec_load_size_i,
  input  logic [`LS_SIZE_W-1:0]     id_dec_store_size_i,

  input  logic [`EXCP_TYPE_W-1:0]   id_dec_excp_type_i,
  input  logic [`INT_TYPE_W-1:0]    id_dec_int_type_i,
  input  logic [`INST_CSRADR_W-1:0] id_dec_csr_addr_i,
  input  logic [`INST_ZIMM_W-1:0]   id_dec_csr_zimm_i,

  input  logic                      id_bpu_prd_tkn_i,
  input  logic [`CORE_ADDR_W-1:0]   id_bpu_prd_pc_i,
  input  logic [1:0]                id_bpu_prd_sat_cnt_i,
  // ex stage
  output logic [`CORE_ADDR_W-1:0]   ex_pc_o,
  // rd information
  output logic                      ex_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] ex_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     ex_rd_o,
  output logic                      ex_rd_load_o,
  output logic                      ex_rd_load_unsigned_o,
  output logic [`LS_SIZE_W-1:0]     ex_rd_load_size_o,
  // branch
  output logic                      ex_excp_br_tkn_o,
  output logic [`CORE_XLEN-1:0]     ex_excp_br_pc_o,
  output logic                      ex_bju_upd_vld_o,
  output logic                      ex_bju_upd_mis_o,
  output logic                      ex_bju_upd_tkn_o,
  output logic [`BR_TYPE_W-1:0]     ex_bju_upd_type_o,
  output logic [`CORE_XLEN-1:0]     ex_bju_upd_src_pc_o,
  output logic [`CORE_XLEN-1:0]     ex_bju_upd_tgt_pc_o,
  output logic [1:0]                ex_bju_upd_sat_cnt_o,
  // data mem interface
  output logic                      ex_mem_req_vld_o,
  input  logic                      ex_mem_req_rdy_i,
  output logic [`CORE_XLEN/8-1:0]   ex_mem_req_wen_o,
  output logic [`CORE_ADDR_W-1:0]   ex_mem_req_addr_o,
  output logic [`CORE_XLEN-1:0]     ex_mem_req_wdata_o
);
  // ---------------------------------------------------------------------------
  // ALU
  // ---------------------------------------------------------------------------
  logic [`CORE_XLEN-1:0] alu_rd_w;

  k423_ex_alu  u_k423_ex_alu (
    .clk_i         ( clk_i            ),
    .rst_n_i       ( rst_n_i          ),

    .pc_i          ( id_pc_i          ),
    .dec_grp_i     ( id_dec_grp_i     ),
    .dec_info_i    ( id_dec_info_i    ),

    .dec_rs1_idx_i ( id_dec_rs1_idx_i ),
    .dec_rs2_idx_i ( id_dec_rs2_idx_i ),
    .dec_rs1_i     ( id_dec_rs1_i     ),
    .dec_rs2_i     ( id_dec_rs2_i     ),
    .dec_imm_i     ( id_dec_imm_i     ),

    .alu_rd_o      ( alu_rd_w        )
  );

  // ---------------------------------------------------------------------------
  // MDU
  // ---------------------------------------------------------------------------


  // ---------------------------------------------------------------------------
  // LSU
  // ---------------------------------------------------------------------------
  logic lsu_rd_load_w;
  logic lsu_rd_load_unsigned_w;
  k423_ex_lsu  u_k423_ex_lsu (
    .clk_i                  ( clk_i                  ),
    .rst_n_i                ( rst_n_i                ),

    .pc_i                   ( id_pc_i                ),
    .dec_grp_i              ( id_dec_grp_i           ),
    .dec_info_i             ( id_dec_info_i          ),
    .dec_rs1_i              ( id_dec_rs1_i           ),
    .dec_rs2_i              ( id_dec_rs2_i           ),
    .dec_imm_i              ( id_dec_imm_i           ),
    .dec_store_size_i       ( id_dec_store_size_i    ),

    .lsu_rd_load_o          ( lsu_rd_load_w          ),
    .lsu_rd_load_unsigned_o ( lsu_rd_load_unsigned_w ),

    .lsu_mem_req_vld_o      ( ex_mem_req_vld_o       ),
    .lsu_mem_req_rdy_i      ( ex_mem_req_rdy_i       ),
    .lsu_mem_req_wen_o      ( ex_mem_req_wen_o       ),
    .lsu_mem_req_addr_o     ( ex_mem_req_addr_o      ),
    .lsu_mem_req_wdata_o    ( ex_mem_req_wdata_o     )
  );

  // ---------------------------------------------------------------------------
  // BJU
  // ---------------------------------------------------------------------------
  logic                  bju_upd_vld_w;
  logic                  bju_upd_mis_w;
  logic                  bju_upd_tkn_w;
  logic [`BR_TYPE_W-1:0] bju_upd_type_w;
  logic [`CORE_XLEN-1:0] bju_upd_src_pc_w;
  logic [`CORE_XLEN-1:0] bju_upd_tgt_pc_w;
  logic [1:0]            bju_upd_sat_cnt_w;

  logic                  bju_jal_rd_tkn_w;
  logic [`CORE_XLEN-1:0] bju_jal_rd_w;

  k423_ex_bju  u_k423_ex_bju (
    .clk_i             ( clk_i                ),
    .rst_n_i           ( rst_n_i              ),

    .pc_i              ( id_pc_i              ),
    .dec_grp_i         ( id_dec_grp_i         ),
    .dec_info_i        ( id_dec_info_i        ),
    .dec_rs1_i         ( id_dec_rs1_i         ),
    .dec_rs2_i         ( id_dec_rs2_i         ),
    .dec_imm_i         ( id_dec_imm_i         ),
    
    .bpu_prd_tkn_i     ( id_bpu_prd_tkn_i     ),
    .bpu_prd_pc_i      ( id_bpu_prd_pc_i      ),
    .bpu_prd_sat_cnt_i ( id_bpu_prd_sat_cnt_i ),

    .bju_upd_vld_o     ( bju_upd_vld_w        ),
    .bju_upd_mis_o     ( bju_upd_mis_w        ),
    .bju_upd_tkn_o     ( bju_upd_tkn_w        ),
    .bju_upd_type_o    ( bju_upd_type_w       ),
    .bju_upd_src_pc_o  ( bju_upd_src_pc_w     ),
    .bju_upd_tgt_pc_o  ( bju_upd_tgt_pc_w     ),
    .bju_upd_sat_cnt_o ( bju_upd_sat_cnt_w    ),
    
    .bju_jal_rd_tkn_o  ( bju_jal_rd_tkn_w     ),
    .bju_jal_rd_o      ( bju_jal_rd_w         )
  );

  // ---------------------------------------------------------------------------
  // CSR
  // ---------------------------------------------------------------------------
  logic                    csr_mtvec_tkn_w;
  logic [`CORE_ADDR_W-1:0] csr_mtvec_w;
  logic                    csr_mepc_tkn_w;
  logic [`CORE_ADDR_W-1:0] csr_mepc_w;
  logic [`CORE_XLEN-1:0]   csr_rd_w;
  
`ifdef ISA_Zicsr

  k423_ex_csr  u_k423_ex_csr (
    .clk_i              ( clk_i               ),
    .rst_n_i            ( rst_n_i             ),

    .id_pc_i            ( id_pc_i             ),
    .id_inst_i          ( id_inst_i           ),
    .id_dec_grp_i       ( id_dec_grp_i        ),
    .id_dec_info_i      ( id_dec_info_i       ),
    .id_dec_rs1_vld_i   ( id_dec_rs1_vld_i    ),
    .id_dec_rs1_i       ( id_dec_rs1_i        ),
    .id_dec_excp_type_i ( id_dec_excp_type_i  ),
    .id_dec_int_type_i  ( id_dec_int_type_i   ),
    .id_dec_csr_addr_i  ( id_dec_csr_addr_i   ),
    .id_dec_csr_zimm_i  ( id_dec_csr_zimm_i   ),
  
    .csr_mtvec_tkn_o    ( csr_mtvec_tkn_w     ),
    .csr_mtvec_o        ( csr_mtvec_w         ),
    .csr_mepc_tkn_o     ( csr_mepc_tkn_w      ),
    .csr_mepc_o         ( csr_mepc_w          ),
    .csr_rd_o           ( csr_rd_w            )
  );

`else

  assign csr_mtvec_tkn_w = '0;
  assign csr_mtvec_w     = '0;
  assign csr_mepc_tkn_w  = '0;
  assign csr_mepc_w      = '0;
  assign csr_rd_w        = '0;

`endif

  // ---------------------------------------------------------------------------
  // Rd Select
  // ---------------------------------------------------------------------------
  assign ex_rd_vld_o            = id_dec_rd_vld_i;
  assign ex_rd_idx_o            = id_dec_rd_idx_i;
  assign ex_rd_o                = id_dec_grp_i[`INST_GRP_CSR] ? csr_rd_w     :
                                  bju_jal_rd_tkn_w            ? bju_jal_rd_w :
                                                                alu_rd_w     ;

  assign ex_rd_load_o           = lsu_rd_load_w;
  assign ex_rd_load_size_o      = id_dec_load_size_i;
  assign ex_rd_load_unsigned_o  = lsu_rd_load_unsigned_w;
  
  assign ex_bju_upd_vld_o       = bju_upd_vld_w;
  assign ex_bju_upd_mis_o       = bju_upd_mis_w;
  assign ex_bju_upd_tkn_o       = bju_upd_tkn_w;
  assign ex_bju_upd_type_o      = bju_upd_type_w;
  assign ex_bju_upd_src_pc_o    = bju_upd_src_pc_w;
  assign ex_bju_upd_tgt_pc_o    = bju_upd_tgt_pc_w;
  assign ex_bju_upd_sat_cnt_o   = bju_upd_sat_cnt_w;
  
  assign ex_excp_br_tkn_o       = csr_mepc_tkn_w  | csr_mtvec_tkn_w;
  assign ex_excp_br_pc_o        = csr_mepc_tkn_w  ? csr_mepc_w     :
                                  csr_mtvec_tkn_w ? csr_mtvec_w    :
                                                    32'h0000_0000  ;
  
  assign ex_pc_o                = id_pc_i;

  // ---------------------------------------------------------------------------
  // Pipeline Handshake
  // ---------------------------------------------------------------------------
  wire   ex_stage_done  = 1'b1;
  assign ex_stage_vld_o = id_stage_vld_i & ex_stage_done;
  assign ex_stage_rdy_o = ~id_stage_vld_i | ex_stage_done & wb_stage_rdy_i;

endmodule
