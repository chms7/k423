/*
 * @Design: k423_core
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Top module of k423 core
 */
`include "k423_defines.svh"

module k423_core (
  input                             clk_i,
  input                             rst_n_i,
  // inst mem interface
  output logic                      mem_inst_req_vld_o,
  output logic                      mem_inst_req_wen_o,
  output logic [`CORE_ADDR_W -1:0]  mem_inst_req_addr_o,
  output logic [`CORE_XLEN-1:0]     mem_inst_req_wdata_o,
  input  logic                      mem_inst_req_rdy_i,
  input  logic                      mem_inst_rsp_vld_i,
  input  logic [`CORE_FETCH_W-1:0]  mem_inst_rsp_rdata_i,
  // data mem interface
  output logic                      mem_data_req_vld_o,
  output logic [`CORE_XLEN/8-1:0]   mem_data_req_wen_o,
  output logic [`CORE_ADDR_W -1:0]  mem_data_req_addr_o,
  output logic [`CORE_XLEN-1:0]     mem_data_req_wdata_o,
  input  logic                      mem_data_req_rdy_i,
  input  logic                      mem_data_rsp_vld_i,
  input  logic [`CORE_FETCH_W-1:0]  mem_data_rsp_rdata_i,
  // debug interface
  output logic [`CORE_ADDR_W-1:0]   debug_wb_pc_o,
  output logic                      debug_wb_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] debug_wb_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     debug_wb_rd_o
);
  // ---------------------------------------------------------------------------
  // Wire Declaration
  // ---------------------------------------------------------------------------
  // pipeline control
  logic                       pcu_clear_pc_w;
  logic                       pcu_clear_if_id_w;
  logic                       pcu_clear_id_ex_w;
  logic                       pcu_clear_ex_wb_w;

  logic                       pcu_stall_pc_w;
  logic                       pcu_stall_if_id_w;
  logic                       pcu_stall_id_ex_w;
  logic                       pcu_stall_ex_wb_w;

  // if stage
  logic                       if_stage_vld_w;
  logic                       if_stage_rdy_w;

  logic                       if_mem_req_vld_w;
  logic                       if_mem_req_wen_w;
  logic [`CORE_ADDR_W -1:0]   if_mem_req_addr_w;
  logic [`CORE_XLEN-1:0]      if_mem_req_wdata_w;
  logic                       if_mem_req_rdy_w;
  logic                       if_mem_rsp_vld_w;
  logic [`CORE_FETCH_W-1:0]   if_mem_rsp_rdata_w;
  
  assign mem_inst_req_vld_o   = if_mem_req_vld_w;
  assign mem_inst_req_wen_o   = if_mem_req_wen_w;
  assign mem_inst_req_addr_o  = if_mem_req_addr_w;
  assign mem_inst_req_wdata_o = if_mem_req_wdata_w;
  assign if_mem_req_rdy_w     = mem_inst_req_rdy_i;
  assign if_mem_rsp_vld_w     = mem_inst_rsp_vld_i;
  assign if_mem_rsp_rdata_w   = mem_inst_rsp_rdata_i;

  logic [`CORE_ADDR_W-1:0]    if_pc_w;
  logic [`CORE_INST_W-1:0]    if_inst_w;
  logic                       if_bpu_prd_tkn_w;
  logic [`CORE_ADDR_W-1:0]    if_bpu_prd_pc_w;
  logic [1:0]                 if_bpu_prd_sat_cnt_w;

  // if to id pipeline
  logic                       if2id_stage_vld_w;

  logic [`CORE_ADDR_W-1:0]    if2id_pc_w;
  logic [`CORE_INST_W-1:0]    if2id_inst_w;
  logic                       if2id_bpu_prd_tkn_w;
  logic [`CORE_ADDR_W-1:0]    if2id_bpu_prd_pc_w;
  logic [1:0]                 if2id_bpu_prd_sat_cnt_w;

  // id stage
  logic                       id_stage_vld_w;
  logic                       id_stage_rdy_w;

  logic [`CORE_ADDR_W-1:0]    id_pc_w;
  logic [`CORE_INST_W-1:0]    id_inst_w;

  logic [`INST_GRP_W-1:0]     id_dec_grp_w;
  logic [`INST_INFO_W-1:0]    id_dec_info_w;

  logic                       id_dec_rs1_vld_w;
  logic [`INST_RSDIDX_W-1:0]  id_dec_rs1_idx_w;
  logic [`CORE_XLEN-1:0]      id_dec_rs1_w;
  logic                       id_dec_rs2_vld_w;
  logic [`INST_RSDIDX_W-1:0]  id_dec_rs2_idx_w;
  logic [`CORE_XLEN-1:0]      id_dec_rs2_w;
  logic                       id_dec_rd_vld_w;
  logic [`INST_RSDIDX_W-1:0]  id_dec_rd_idx_w;
  logic [`CORE_XLEN-1:0]      id_dec_imm_w;

  logic [`LS_SIZE_W-1:0]      id_dec_load_size_w;
  logic [`LS_SIZE_W-1:0]      id_dec_store_size_w;

  logic [`EXCP_TYPE_W-1:0]    id_dec_excp_type_w;
  logic [`INT_TYPE_W-1:0]     id_dec_int_type_w;
  logic [`INST_CSRADR_W-1:0]  id_dec_csr_addr_w;
  logic [`INST_ZIMM_W-1:0]    id_dec_csr_zimm_w;
  logic                       id_bpu_prd_tkn_w;
  logic [`CORE_ADDR_W-1:0]    id_bpu_prd_pc_w;
  logic [1:0]                 id_bpu_prd_sat_cnt_w;

  // id to ex pipeline
  logic                       id2ex_stage_vld_w;

  logic [`CORE_ADDR_W-1:0]    id2ex_pc_w;
  logic [`CORE_INST_W-1:0]    id2ex_inst_w;
  logic [`INST_GRP_W-1:0]     id2ex_dec_grp_w;
  logic [`INST_INFO_W-1:0]    id2ex_dec_info_w;
  logic                       id2ex_dec_rs1_vld_w;
  logic [`INST_RSDIDX_W-1:0]  id2ex_dec_rs1_idx_w;
  logic [`CORE_XLEN-1:0]      id2ex_dec_rs1_w;
  logic                       id2ex_dec_rs2_vld_w;
  logic [`INST_RSDIDX_W-1:0]  id2ex_dec_rs2_idx_w;
  logic [`CORE_XLEN-1:0]      id2ex_dec_rs2_w;
  logic                       id2ex_dec_rd_vld_w;
  logic [`INST_RSDIDX_W-1:0]  id2ex_dec_rd_idx_w;
  logic [`CORE_XLEN-1:0]      id2ex_dec_imm_w;
  logic [`LS_SIZE_W-1:0]      id2ex_dec_load_size_w;
  logic [`LS_SIZE_W-1:0]      id2ex_dec_store_size_w;
  logic [`EXCP_TYPE_W-1:0]    id2ex_dec_excp_type_w;
  logic [`INT_TYPE_W-1:0]     id2ex_dec_int_type_w;
  logic [`INST_CSRADR_W-1:0]  id2ex_dec_csr_addr_w;
  logic [`INST_ZIMM_W-1:0]    id2ex_dec_csr_zimm_w;
  logic                       id2ex_bpu_prd_tkn_w;
  logic [`CORE_ADDR_W-1:0]    id2ex_bpu_prd_pc_w;
  logic [1:0]                 id2ex_bpu_prd_sat_cnt_w;
  
  // ex stage
  logic                       ex_stage_vld_w;
  logic                       ex_stage_rdy_w;

  logic [`CORE_ADDR_W-1:0]    ex_pc_w;
  logic [`CORE_INST_W-1:0]    ex_inst_w;

  logic                       ex_rd_vld_w;
  logic [`INST_RSDIDX_W-1:0]  ex_rd_idx_w;
  logic [`CORE_XLEN-1:0]      ex_rd_w;
  logic                       ex_rd_load_w;
  logic [`LS_SIZE_W-1:0]      ex_rd_load_size_w;
  logic                       ex_rd_load_unsigned_w;

  logic                       ex_excp_br_tkn_w;
  logic [`CORE_XLEN-1:0]      ex_excp_br_pc_w;

  logic                       ex_bju_upd_vld_w;
  logic                       ex_bju_upd_mis_w;
  logic                       ex_bju_upd_tkn_w;
  logic [`BR_TYPE_W-1:0]      ex_bju_upd_type_w;
  logic [`CORE_XLEN-1:0]      ex_bju_upd_src_pc_w;
  logic [`CORE_XLEN-1:0]      ex_bju_upd_tgt_pc_w;
  logic [1:0]                 ex_bju_upd_sat_cnt_w;

  logic                       ex_mem_req_vld_w;
  logic [`CORE_XLEN/8-1:0]    ex_mem_req_wen_w;
  logic [`CORE_ADDR_W-1:0]    ex_mem_req_addr_w;
  logic [`CORE_XLEN-1:0]      ex_mem_req_wdata_w;
  logic                       ex_mem_req_rdy_w;
  
  assign mem_data_req_vld_o   = ex_mem_req_vld_w;
  assign mem_data_req_wen_o   = ex_mem_req_wen_w;
  assign mem_data_req_addr_o  = ex_mem_req_addr_w;
  assign mem_data_req_wdata_o = ex_mem_req_wdata_w;
  assign ex_mem_req_rdy_w     = mem_data_req_rdy_i;

  // ex to wb pipeline
  logic                       ex2wb_stage_vld_w;

  logic [`CORE_ADDR_W-1:0]    ex2wb_pc_w;
  logic                       ex2wb_rd_vld_w;
  logic [`INST_RSDIDX_W-1:0]  ex2wb_rd_idx_w;
  logic [`CORE_XLEN-1:0]      ex2wb_rd_w;
  logic                       ex2wb_rd_load_w;
  logic [`LS_SIZE_W-1:0]      ex2wb_rd_load_size_w;
  logic                       ex2wb_rd_load_unsigned_w;
  logic [`CORE_ADDR_W-1:0]    ex2wb_rd_load_addr_w;
  logic                       ex2wb_excp_br_tkn_w;
  logic [`CORE_XLEN-1:0]      ex2wb_excp_br_pc_w;

  logic                       ex2wb_bju_upd_vld_w;
  logic                       ex2wb_bju_upd_mis_w;
  logic                       ex2wb_bju_upd_tkn_w;
  logic [`BR_TYPE_W-1:0]      ex2wb_bju_upd_type_w;
  logic [`CORE_XLEN-1:0]      ex2wb_bju_upd_src_pc_w;
  logic [`CORE_XLEN-1:0]      ex2wb_bju_upd_tgt_pc_w;
  logic [1:0]                 ex2wb_bju_upd_sat_cnt_w;

  logic                       ex2wb_mem_rsp_vld_w;
  logic [`CORE_FETCH_W-1:0]   ex2wb_mem_rsp_rdata_w;
  
  assign ex2wb_mem_rsp_vld_w   = mem_data_rsp_vld_i;
  assign ex2wb_mem_rsp_rdata_w = mem_data_rsp_rdata_i;

  // wb stage
  logic                       wb_stage_vld_w;
  logic                       wb_stage_rdy_w;

  logic [`CORE_ADDR_W-1:0]    wb_pc_w;

  logic [`CORE_XLEN-1:0]      wb_rd_w;
  logic                       wb_rd_vld_w;
  logic [`INST_RSDIDX_W-1:0]  wb_rd_idx_w;

  logic                       wb_excp_br_tkn_w;
  logic [`CORE_XLEN-1:0]      wb_excp_br_pc_w;

  logic                       wb_bju_upd_vld_w;
  logic                       wb_bju_upd_mis_w;
  logic                       wb_bju_upd_tkn_w;
  logic [`BR_TYPE_W-1:0]      wb_bju_upd_type_w;
  logic [`CORE_XLEN-1:0]      wb_bju_upd_src_pc_w;
  logic [`CORE_XLEN-1:0]      wb_bju_upd_tgt_pc_w;
  logic [1:0]                 wb_bju_upd_sat_cnt_w;
  
  // debug interface
  assign debug_wb_pc_o        = wb_pc_w;
  assign debug_wb_rd_vld_o    = wb_rd_vld_w;
  assign debug_wb_rd_idx_o    = wb_rd_idx_w;
  assign debug_wb_rd_o        = wb_rd_w;

  // ---------------------------------------------------------------------------
  // Pipeline Control Unit
  // ---------------------------------------------------------------------------
  k423_pcu  u_k423_pcu (
    .clk_i               ( clk_i               ),
    .rst_n_i             ( rst_n_i             ),
    // rs in id & rd in ex
    .id_dec_rs1_vld_i    ( id_dec_rs1_vld_w    ),
    .id_dec_rs1_idx_i    ( id_dec_rs1_idx_w    ),
    .id_dec_rs2_vld_i    ( id_dec_rs2_vld_w    ),
    .id_dec_rs2_idx_i    ( id_dec_rs2_idx_w    ),
    .ex_rd_vld_i         ( ex_rd_vld_w         ),
    .ex_rd_idx_i         ( ex_rd_idx_w         ),
    .ex_rd_load_i        ( ex_rd_load_w        ),
    // branch prediction miss
    .wb_bju_upd_mis_i    ( wb_bju_upd_mis_w    ),
    // exception
    .wb_excp_br_tkn_i    ( wb_excp_br_tkn_w    ),
    // pipeline control signals
    .pcu_clear_pc_o      ( pcu_clear_pc_w      ),
    .pcu_clear_if_id_o   ( pcu_clear_if_id_w   ),
    .pcu_clear_id_ex_o   ( pcu_clear_id_ex_w   ),
    .pcu_clear_ex_wb_o   ( pcu_clear_ex_wb_w   ),

    .pcu_stall_pc_o      ( pcu_stall_pc_w      ),
    .pcu_stall_if_id_o   ( pcu_stall_if_id_w   ),
    .pcu_stall_id_ex_o   ( pcu_stall_id_ex_w   ),
    .pcu_stall_ex_wb_o   ( pcu_stall_ex_wb_w   )
  );

  // ---------------------------------------------------------------------------
  // IF Stage
  // ---------------------------------------------------------------------------
  k423_if_stage u_k423_if_stage (
    .clk_i                ( clk_i                ),
    .rst_n_i              ( rst_n_i              ),
    // pipeline control
    .pcu_clear_pc_i       ( pcu_clear_pc_w       ),
    .pcu_stall_pc_i       ( pcu_stall_pc_w       ),
    // pipeline handshake
    .if_stage_vld_o       ( if_stage_vld_w       ),
    .id_stage_rdy_i       ( id_stage_rdy_w       ),
    // branch
    .wb_excp_br_tkn_i     ( wb_excp_br_tkn_w     ),
    .wb_excp_br_pc_i      ( wb_excp_br_pc_w      ),
    .wb_bju_upd_vld_i     ( wb_bju_upd_vld_w     ),
    .wb_bju_upd_mis_i     ( wb_bju_upd_mis_w     ),
    .wb_bju_upd_tkn_i     ( wb_bju_upd_tkn_w     ),
    .wb_bju_upd_type_i    ( wb_bju_upd_type_w    ),
    .wb_bju_upd_src_pc_i  ( wb_bju_upd_src_pc_w  ),
    .wb_bju_upd_tgt_pc_i  ( wb_bju_upd_tgt_pc_w  ),
    .wb_bju_upd_sat_cnt_i ( wb_bju_upd_sat_cnt_w ),
    // inst mem interface
    .if_mem_req_vld_o     ( if_mem_req_vld_w     ),
    .if_mem_req_wen_o     ( if_mem_req_wen_w     ),
    .if_mem_req_addr_o    ( if_mem_req_addr_w    ),
    .if_mem_req_wdata_o   ( if_mem_req_wdata_w   ),
    .if_mem_req_rdy_i     ( if_mem_req_rdy_w     ),
    .if_mem_rsp_vld_i     ( if_mem_rsp_vld_w     ),
    .if_mem_rsp_rdata_i   ( if_mem_rsp_rdata_w   ),
    // if stage
    .if_pc_o              ( if_pc_w              ),
    .if_inst_o            ( if_inst_w            ),
    .if_bpu_prd_tkn_o     ( if_bpu_prd_tkn_w     ),
    .if_bpu_prd_pc_o      ( if_bpu_prd_pc_w      ),
    .if_bpu_prd_sat_cnt_o ( if_bpu_prd_sat_cnt_w )
  );

  // ---------------------------------------------------------------------------
  // IF to ID Pipeline
  // ---------------------------------------------------------------------------
  k423_pipe_if_id  u_k423_pipe_if_id (
    .clk_i                ( clk_i                   ),
    .rst_n_i              ( rst_n_i                 ),
    // pipeline control
    .pcu_clear_if_id_i    ( pcu_clear_if_id_w       ),
    .pcu_stall_if_id_i    ( pcu_stall_if_id_w       ),
    // pipeline handshake
    .if_stage_vld_i       ( if_stage_vld_w          ),
    .id_stage_rdy_i       ( id_stage_rdy_w          ),
    .if2id_stage_vld_o    ( if2id_stage_vld_w       ),
    // if stage
    .if_pc_i              ( if_pc_w                 ),
    .if_inst_i            ( if_inst_w               ),
    .if_bpu_prd_tkn_i     ( if_bpu_prd_tkn_w        ),
    .if_bpu_prd_pc_i      ( if_bpu_prd_pc_w         ),
    .if_bpu_prd_sat_cnt_i ( if_bpu_prd_sat_cnt_w    ),
    // id stage
    .id_pc_o              ( if2id_pc_w              ),
    .id_inst_o            ( if2id_inst_w            ),
    .id_bpu_prd_tkn_o     ( if2id_bpu_prd_tkn_w     ),
    .id_bpu_prd_pc_o      ( if2id_bpu_prd_pc_w      ),
    .id_bpu_prd_sat_cnt_o ( if2id_bpu_prd_sat_cnt_w )
  );

  // ---------------------------------------------------------------------------
  // ID Stage
  // ---------------------------------------------------------------------------
  k423_id_stage  u_k423_id_stage (
    .clk_i                ( clk_i                   ),
    .rst_n_i              ( rst_n_i                 ),
    // pipeline handshake 
    .if_stage_vld_i       ( if2id_stage_vld_w       ),
    .id_stage_vld_o       ( id_stage_vld_w          ),
    .id_stage_rdy_o       ( id_stage_rdy_w          ),
    .ex_stage_rdy_i       ( ex_stage_rdy_w          ),
    // if stage
    .if_pc_i              ( if2id_pc_w              ),
    .if_inst_i            ( if2id_inst_w            ),
    .if_bpu_prd_tkn_i     ( if2id_bpu_prd_tkn_w     ),
    .if_bpu_prd_pc_i      ( if2id_bpu_prd_pc_w      ),
    .if_bpu_prd_sat_cnt_i ( if2id_bpu_prd_sat_cnt_w ),
    // decode information 
    .id_pc_o              ( id_pc_w                 ),
    .id_inst_o            ( id_inst_w               ),
    .id_dec_grp_o         ( id_dec_grp_w            ),
    .id_dec_info_o        ( id_dec_info_w           ),
    .id_dec_rs1_vld_o     ( id_dec_rs1_vld_w        ),
    .id_dec_rs1_idx_o     ( id_dec_rs1_idx_w        ),
    .id_dec_rs2_vld_o     ( id_dec_rs2_vld_w        ),
    .id_dec_store_size_o  ( id_dec_store_size_w     ),
    .id_dec_rs2_idx_o     ( id_dec_rs2_idx_w        ),
    .id_dec_rd_vld_o      ( id_dec_rd_vld_w         ),
    .id_dec_load_size_o   ( id_dec_load_size_w      ),
    .id_dec_rd_idx_o      ( id_dec_rd_idx_w         ),
    .id_dec_imm_o         ( id_dec_imm_w            ),
    .id_dec_excp_type_o   ( id_dec_excp_type_w      ),
    .id_dec_int_type_o    ( id_dec_int_type_w       ),
    .id_dec_csr_addr_o    ( id_dec_csr_addr_w       ),
    .id_dec_csr_zimm_o    ( id_dec_csr_zimm_w       ),
    .id_bpu_prd_tkn_o     ( id_bpu_prd_tkn_w        ),
    .id_bpu_prd_pc_o      ( id_bpu_prd_pc_w         ),
    .id_bpu_prd_sat_cnt_o ( id_bpu_prd_sat_cnt_w    )
  );

  // ---------------------------------------------------------------------------
  // ID Stage Regfile
  // ---------------------------------------------------------------------------
  k423_id_regfile u_k423_id_regfile (
    .clk_i              ( clk_i               ),
    .rst_n_i            ( rst_n_i             ),
    // forward
    .ex_fwd_rd_vld_i    ( ex_rd_vld_w         ),
    .ex_fwd_rd_idx_i    ( ex_rd_idx_w         ),
    .ex_fwd_rd_data_i   ( ex_rd_w             ),
    .wb_fwd_rd_vld_i    ( wb_rd_vld_w         ),
    .wb_fwd_rd_idx_i    ( wb_rd_idx_w         ),
    .wb_fwd_rd_data_i   ( wb_rd_w             ),
    // write
    .wb_rd_vld_i        ( wb_rd_vld_w         ),
    .wb_rd_idx_i        ( wb_rd_idx_w         ),
    .wb_rd_data_i       ( wb_rd_w             ),
    // read
    .id_rs1_vld_i       ( id_dec_rs1_vld_w    ),
    .id_rs1_idx_i       ( id_dec_rs1_idx_w    ),
    .id_rs2_vld_i       ( id_dec_rs2_vld_w    ),
    .id_store_size_i    ( id_dec_store_size_w ),
    .id_rs2_idx_i       ( id_dec_rs2_idx_w    ),
    .id_rs1_data_o      ( id_dec_rs1_w        ),
    .id_rs2_data_o      ( id_dec_rs2_w        )
  );

  // ---------------------------------------------------------------------------
  // ID to EX Pipeline
  // ---------------------------------------------------------------------------
  k423_pipe_id_ex  u_k423_pipe_id_ex (
    .clk_i                ( clk_i                   ),
    .rst_n_i              ( rst_n_i                 ),
    // pipeline control
    .pcu_clear_id_ex_i    ( pcu_clear_id_ex_w       ),
    .pcu_stall_id_ex_i    ( pcu_stall_id_ex_w       ),
    // pipeline handshake
    .id_stage_vld_i       ( id_stage_vld_w          ),
    .ex_stage_rdy_i       ( id_stage_rdy_w          ),
    .id2ex_stage_vld_o    ( id2ex_stage_vld_w       ),
    // id stage
    .id_pc_i              ( id_pc_w                 ),
    .id_inst_i            ( id_inst_w               ),
    .id_dec_grp_i         ( id_dec_grp_w            ),
    .id_dec_info_i        ( id_dec_info_w           ),
    .id_dec_rs1_vld_i     ( id_dec_rs1_vld_w        ),
    .id_dec_rs1_idx_i     ( id_dec_rs1_idx_w        ),
    .id_dec_rs1_i         ( id_dec_rs1_w            ),
    .id_dec_rs2_vld_i     ( id_dec_rs2_vld_w        ),
    .id_dec_store_size_i  ( id_dec_store_size_w     ),
    .id_dec_rs2_idx_i     ( id_dec_rs2_idx_w        ),
    .id_dec_rs2_i         ( id_dec_rs2_w            ),
    .id_dec_rd_vld_i      ( id_dec_rd_vld_w         ),
    .id_dec_load_size_i   ( id_dec_load_size_w      ),
    .id_dec_rd_idx_i      ( id_dec_rd_idx_w         ),
    .id_dec_imm_i         ( id_dec_imm_w            ),
    .id_dec_excp_type_i   ( id_dec_excp_type_w      ),
    .id_dec_int_type_i    ( id_dec_int_type_w       ),
    .id_dec_csr_addr_i    ( id_dec_csr_addr_w       ),
    .id_dec_csr_zimm_i    ( id_dec_csr_zimm_w       ),
    .id_bpu_prd_tkn_i     ( id_bpu_prd_tkn_w        ),
    .id_bpu_prd_pc_i      ( id_bpu_prd_pc_w         ),
    .id_bpu_prd_sat_cnt_i ( id_bpu_prd_sat_cnt_w    ),
    // ex stage
    .ex_pc_o              ( id2ex_pc_w              ),
    .ex_inst_o            ( id2ex_inst_w            ),
    .ex_dec_grp_o         ( id2ex_dec_grp_w         ),
    .ex_dec_info_o        ( id2ex_dec_info_w        ),
    .ex_dec_rs1_vld_o     ( id2ex_dec_rs1_vld_w     ),
    .ex_dec_rs1_idx_o     ( id2ex_dec_rs1_idx_w     ),
    .ex_dec_rs1_o         ( id2ex_dec_rs1_w         ),
    .ex_dec_rs2_vld_o     ( id2ex_dec_rs2_vld_w     ),
    .ex_dec_store_size_o  ( id2ex_dec_store_size_w  ),
    .ex_dec_rs2_idx_o     ( id2ex_dec_rs2_idx_w     ),
    .ex_dec_rs2_o         ( id2ex_dec_rs2_w         ),
    .ex_dec_rd_vld_o      ( id2ex_dec_rd_vld_w      ),
    .ex_dec_load_size_o   ( id2ex_dec_load_size_w   ),
    .ex_dec_rd_idx_o      ( id2ex_dec_rd_idx_w      ),
    .ex_dec_imm_o         ( id2ex_dec_imm_w         ),
    .ex_dec_excp_type_o   ( id2ex_dec_excp_type_w   ),
    .ex_dec_int_type_o    ( id2ex_dec_int_type_w    ),
    .ex_dec_csr_addr_o    ( id2ex_dec_csr_addr_w    ),
    .ex_dec_csr_zimm_o    ( id2ex_dec_csr_zimm_w    ),
    .ex_bpu_prd_tkn_o     ( id2ex_bpu_prd_tkn_w     ),
    .ex_bpu_prd_pc_o      ( id2ex_bpu_prd_pc_w      ),
    .ex_bpu_prd_sat_cnt_o ( id2ex_bpu_prd_sat_cnt_w )
  );

  // ---------------------------------------------------------------------------
  // EX Stage
  // ---------------------------------------------------------------------------
  k423_ex_stage  u_k423_ex_stage (
    .clk_i                  ( clk_i                   ),
    .rst_n_i                ( rst_n_i                 ),
    // pipeline handshake
    .id_stage_vld_i         ( id2ex_stage_vld_w       ),
    .ex_stage_vld_o         ( ex_stage_vld_w          ),
    .ex_stage_rdy_o         ( ex_stage_rdy_w          ),
    .wb_stage_rdy_i         ( wb_stage_rdy_w          ),
    // id stage
    .id_pc_i                ( id2ex_pc_w              ),
    .id_inst_i              ( id2ex_inst_w            ),
    .id_dec_grp_i           ( id2ex_dec_grp_w         ),
    .id_dec_info_i          ( id2ex_dec_info_w        ),
    .id_dec_rs1_vld_i       ( id2ex_dec_rs1_vld_w     ),
    .id_dec_rs1_idx_i       ( id2ex_dec_rs1_idx_w     ),
    .id_dec_rs1_i           ( id2ex_dec_rs1_w         ),
    .id_dec_rs2_vld_i       ( id2ex_dec_rs2_vld_w     ),
    .id_dec_store_size_i    ( id2ex_dec_store_size_w  ),
    .id_dec_rs2_idx_i       ( id2ex_dec_rs2_idx_w     ),
    .id_dec_rs2_i           ( id2ex_dec_rs2_w         ),
    .id_dec_rd_vld_i        ( id2ex_dec_rd_vld_w      ),
    .id_dec_load_size_i     ( id2ex_dec_load_size_w   ),
    .id_dec_rd_idx_i        ( id2ex_dec_rd_idx_w      ),
    .id_dec_imm_i           ( id2ex_dec_imm_w         ),
    .id_dec_excp_type_i     ( id2ex_dec_excp_type_w   ),
    .id_dec_int_type_i      ( id2ex_dec_int_type_w    ),
    .id_dec_csr_addr_i      ( id2ex_dec_csr_addr_w    ),
    .id_dec_csr_zimm_i      ( id2ex_dec_csr_zimm_w    ),
    .id_bpu_prd_tkn_i       ( id2ex_bpu_prd_tkn_w     ),
    .id_bpu_prd_pc_i        ( id2ex_bpu_prd_pc_w      ),
    .id_bpu_prd_sat_cnt_i   ( id2ex_bpu_prd_sat_cnt_w ),
    // rd information
    .ex_pc_o                ( ex_pc_w                 ),
    .ex_rd_vld_o            ( ex_rd_vld_w             ),
    .ex_rd_idx_o            ( ex_rd_idx_w             ),
    .ex_rd_o                ( ex_rd_w                 ),
    .ex_rd_load_o           ( ex_rd_load_w            ),
    .ex_rd_load_size_o      ( ex_rd_load_size_w       ),
    .ex_rd_load_unsigned_o  ( ex_rd_load_unsigned_w   ),
    // branch
    .ex_excp_br_tkn_o       ( ex_excp_br_tkn_w        ),
    .ex_excp_br_pc_o        ( ex_excp_br_pc_w         ),
    .ex_bju_upd_vld_o       ( ex_bju_upd_vld_w        ),
    .ex_bju_upd_mis_o       ( ex_bju_upd_mis_w        ),
    .ex_bju_upd_tkn_o       ( ex_bju_upd_tkn_w        ),
    .ex_bju_upd_type_o      ( ex_bju_upd_type_w       ),
    .ex_bju_upd_src_pc_o    ( ex_bju_upd_src_pc_w     ),
    .ex_bju_upd_tgt_pc_o    ( ex_bju_upd_tgt_pc_w     ),
    .ex_bju_upd_sat_cnt_o   ( ex_bju_upd_sat_cnt_w    ),
    // data mem interface
    .ex_mem_req_vld_o       ( ex_mem_req_vld_w       ),
    .ex_mem_req_rdy_i       ( ex_mem_req_rdy_w       ),
    .ex_mem_req_wen_o       ( ex_mem_req_wen_w       ),
    .ex_mem_req_addr_o      ( ex_mem_req_addr_w      ),
    .ex_mem_req_wdata_o     ( ex_mem_req_wdata_w     )
  );
  
  // ---------------------------------------------------------------------------
  // EX to WB Pipeline
  // ---------------------------------------------------------------------------
  k423_pipe_ex_wb  u_k423_pipe_ex_wb (
    .clk_i                  ( clk_i                     ),
    .rst_n_i                ( rst_n_i                   ),
    // pipeline control
    .pcu_clear_ex_wb_i      ( pcu_clear_ex_wb_w         ),
    .pcu_stall_ex_wb_i      ( pcu_stall_ex_wb_w         ),
    // pipeline handshake
    .ex_stage_vld_i         ( ex_stage_vld_w            ),
    .wb_stage_rdy_i         ( ex_stage_rdy_w            ),
    .ex2wb_stage_vld_o      ( ex2wb_stage_vld_w         ),
    // ex stage
    .ex_pc_i                ( ex_pc_w                   ),
    .ex_rd_vld_i            ( ex_rd_vld_w               ),
    .ex_rd_idx_i            ( ex_rd_idx_w               ),
    .ex_rd_i                ( ex_rd_w                   ),
    .ex_rd_load_i           ( ex_rd_load_w              ),
    .ex_rd_load_size_i      ( ex_rd_load_size_w         ),
    .ex_rd_load_unsigned_i  ( ex_rd_load_unsigned_w     ),
    .ex_rd_load_addr_i      ( ex_mem_req_addr_w         ),
    .ex_excp_br_tkn_i       ( ex_excp_br_tkn_w          ),
    .ex_excp_br_pc_i        ( ex_excp_br_pc_w           ),
    .ex_bju_upd_vld_i       ( ex_bju_upd_vld_w          ),
    .ex_bju_upd_mis_i       ( ex_bju_upd_mis_w          ),
    .ex_bju_upd_tkn_i       ( ex_bju_upd_tkn_w          ),
    .ex_bju_upd_type_i      ( ex_bju_upd_type_w         ),
    .ex_bju_upd_src_pc_i    ( ex_bju_upd_src_pc_w       ),
    .ex_bju_upd_tgt_pc_i    ( ex_bju_upd_tgt_pc_w       ),
    .ex_bju_upd_sat_cnt_i   ( ex_bju_upd_sat_cnt_w      ),
    // wb stage
    .wb_pc_o                ( ex2wb_pc_w                ),
    .wb_rd_vld_o            ( ex2wb_rd_vld_w            ),
    .wb_rd_idx_o            ( ex2wb_rd_idx_w            ),
    .wb_rd_o                ( ex2wb_rd_w                ),
    .wb_rd_load_o           ( ex2wb_rd_load_w           ),
    .wb_rd_load_size_o      ( ex2wb_rd_load_size_w      ),
    .wb_rd_load_unsigned_o  ( ex2wb_rd_load_unsigned_w  ),
    .wb_rd_load_addr_o      ( ex2wb_rd_load_addr_w      ),
    .wb_excp_br_tkn_o       ( ex2wb_excp_br_tkn_w       ),
    .wb_excp_br_pc_o        ( ex2wb_excp_br_pc_w        ),
    .wb_bju_upd_vld_o       ( ex2wb_bju_upd_vld_w       ),
    .wb_bju_upd_mis_o       ( ex2wb_bju_upd_mis_w       ),
    .wb_bju_upd_tkn_o       ( ex2wb_bju_upd_tkn_w       ),
    .wb_bju_upd_type_o      ( ex2wb_bju_upd_type_w      ),
    .wb_bju_upd_src_pc_o    ( ex2wb_bju_upd_src_pc_w    ),
    .wb_bju_upd_tgt_pc_o    ( ex2wb_bju_upd_tgt_pc_w    ),
    .wb_bju_upd_sat_cnt_o   ( ex2wb_bju_upd_sat_cnt_w   )
  );
  
  // ---------------------------------------------------------------------------
  // WB Stage
  // ---------------------------------------------------------------------------
  k423_wb_stage  u_k423_wb_stage (
    .clk_i                  ( clk_i                    ),
    .rst_n_i                ( rst_n_i                  ),
    // pipeline handshake
    .ex_stage_vld_i         ( ex2wb_stage_vld_w        ),
    .wb_stage_vld_o         ( wb_stage_vld_w           ),
    .wb_stage_rdy_o         ( wb_stage_rdy_w           ),
    // ex stage
    .ex_pc_i                ( ex2wb_pc_w               ),
    .ex_rd_vld_i            ( ex2wb_rd_vld_w           ),
    .ex_rd_idx_i            ( ex2wb_rd_idx_w           ),
    .ex_rd_i                ( ex2wb_rd_w               ),
    .ex_rd_load_i           ( ex2wb_rd_load_w          ),
    .ex_rd_load_size_i      ( ex2wb_rd_load_size_w     ),
    .ex_rd_load_unsigned_i  ( ex2wb_rd_load_unsigned_w ),
    .ex_rd_load_addr_i      ( ex2wb_rd_load_addr_w     ),

    .ex_excp_br_tkn_i       ( ex2wb_excp_br_tkn_w      ),
    .ex_excp_br_pc_i        ( ex2wb_excp_br_pc_w       ),
    .ex_bju_upd_vld_i       ( ex2wb_bju_upd_vld_w      ),
    .ex_bju_upd_mis_i       ( ex2wb_bju_upd_mis_w      ),
    .ex_bju_upd_tkn_i       ( ex2wb_bju_upd_tkn_w      ),
    .ex_bju_upd_type_i      ( ex2wb_bju_upd_type_w     ),
    .ex_bju_upd_src_pc_i    ( ex2wb_bju_upd_src_pc_w   ),
    .ex_bju_upd_tgt_pc_i    ( ex2wb_bju_upd_tgt_pc_w   ),
    .ex_bju_upd_sat_cnt_i   ( ex2wb_bju_upd_sat_cnt_w  ),
    // memory response
    .mem_data_rsp_vld_i     ( ex2wb_mem_rsp_vld_w      ),
    .mem_data_rsp_rdata_i   ( ex2wb_mem_rsp_rdata_w    ),
    // wb stage
    .wb_pc_o                ( wb_pc_w                  ),
    .wb_rd_o                ( wb_rd_w                  ),
    .wb_rd_vld_o            ( wb_rd_vld_w              ),
    .wb_rd_idx_o            ( wb_rd_idx_w              ),
    
    .wb_excp_br_tkn_o       ( wb_excp_br_tkn_w         ),
    .wb_excp_br_pc_o        ( wb_excp_br_pc_w          ),
    .wb_bju_upd_vld_o       ( wb_bju_upd_vld_w         ),
    .wb_bju_upd_mis_o       ( wb_bju_upd_mis_w         ),
    .wb_bju_upd_tkn_o       ( wb_bju_upd_tkn_w         ),
    .wb_bju_upd_type_o      ( wb_bju_upd_type_w        ),
    .wb_bju_upd_src_pc_o    ( wb_bju_upd_src_pc_w      ),
    .wb_bju_upd_tgt_pc_o    ( wb_bju_upd_tgt_pc_w      ),
    .wb_bju_upd_sat_cnt_o   ( wb_bju_upd_sat_cnt_w     )
  );
  
endmodule
