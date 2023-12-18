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
  input logic                      wb_excp_br_tkn_i,
  input logic [`CORE_XLEN-1:0]     wb_excp_br_pc_i,
  input logic                      wb_bju_br_tkn_i,
  input logic [`CORE_XLEN-1:0]     wb_bju_br_pc_i,
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
  output logic [`CORE_INST_W-1:0]  if_inst_o
  
);
  // ---------------------------------------------------------------------------
  // Fetch
  // ---------------------------------------------------------------------------
  wire pc_stage_vld_w;
  wire if_stage_rdy_w;

  k423_if_fetch u_k423_if_fetch (
    .clk_i              ( clk_i               ),
    .rst_n_i            ( rst_n_i             ),
    
    .pcu_clear_pc_i     ( pcu_clear_pc_i      ),
    .pcu_stall_pc_i     ( pcu_stall_pc_i      ),
    
    .pc_stage_vld_o     ( pc_stage_vld_w      ),
    .if_stage_rdy_i     ( if_stage_rdy_w      ),
    
    .wb_excp_br_tkn_i   ( wb_excp_br_tkn_i    ),
    .wb_excp_br_pc_i    ( wb_excp_br_pc_i     ),
    .wb_bju_br_tkn_i    ( wb_bju_br_tkn_i     ),
    .wb_bju_br_pc_i     ( wb_bju_br_pc_i      ),
  
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

  // ---------------------------------------------------------------------------
  // Branch Predict
  // ---------------------------------------------------------------------------
  
  
  // ---------------------------------------------------------------------------
  // Pipeline Handshake
  // ---------------------------------------------------------------------------
  wire   if_stage_done  = if_mem_rsp_vld_i;
  assign if_stage_vld_o = pc_stage_vld_w & if_stage_done;
  assign if_stage_rdy_w = ~pc_stage_vld_w | if_stage_done & id_stage_rdy_i;

endmodule
