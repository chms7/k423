/*
 * @Design: k423_pipe_id_ex
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Pipeline between id & ex stage
 */
`include "k423_defines.svh"

module k423_pipe_id_ex (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline control
  input                             pcu_clear_id_ex_i,
  input                             pcu_stall_id_ex_i,
  // pipeline handshake
  input  logic                      id_stage_vld_i,
  input  logic                      ex_stage_rdy_i,
  output logic                      id2ex_stage_vld_o,
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
  output logic [`CORE_INST_W-1:0]   ex_inst_o,
  output logic [`INST_GRP_W-1:0]    ex_dec_grp_o,
  output logic [`INST_INFO_W-1:0]   ex_dec_info_o,
  output logic                      ex_dec_rs1_vld_o,
  output logic [`INST_RSDIDX_W-1:0] ex_dec_rs1_idx_o,
  output logic [`CORE_XLEN-1:0]     ex_dec_rs1_o,
  output logic                      ex_dec_rs2_vld_o,
  output logic [`INST_RSDIDX_W-1:0] ex_dec_rs2_idx_o,
  output logic [`CORE_XLEN-1:0]     ex_dec_rs2_o,
  output logic                      ex_dec_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] ex_dec_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     ex_dec_imm_o,
  output logic [`LS_SIZE_W-1:0]     ex_dec_load_size_o,
  output logic [`LS_SIZE_W-1:0]     ex_dec_store_size_o,
  output logic [`EXCP_TYPE_W-1:0]   ex_dec_excp_type_o,
  output logic [`INT_TYPE_W-1:0]    ex_dec_int_type_o,
  output logic [`INST_CSRADR_W-1:0] ex_dec_csr_addr_o,
  output logic [`INST_ZIMM_W-1:0]   ex_dec_csr_zimm_o,
  output logic                      ex_bpu_prd_tkn_o,
  output logic [`CORE_ADDR_W-1:0]   ex_bpu_prd_pc_o,
  output logic [1:0]                ex_bpu_prd_sat_cnt_o
);
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      id2ex_stage_vld_o <= 1'b0;
    else if (pcu_clear_id_ex_i)
      id2ex_stage_vld_o <= 1'b0;
    else if (ex_stage_rdy_i)
      id2ex_stage_vld_o <= id_stage_vld_i;
  end

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      ex_pc_o              <= '0;
      ex_inst_o            <= '0;
      ex_dec_grp_o         <= '0;
      ex_dec_info_o        <= '0;
      ex_dec_rs1_vld_o     <= '0;
      ex_dec_rs1_idx_o     <= '0;
      ex_dec_rs1_o         <= '0;
      ex_dec_rs2_vld_o     <= '0;
      ex_dec_rs2_idx_o     <= '0;
      ex_dec_rs2_o         <= '0;
      ex_dec_rd_vld_o      <= '0;
      ex_dec_rd_idx_o      <= '0;
      ex_dec_imm_o         <= '0;
      ex_dec_load_size_o   <= '0;
      ex_dec_store_size_o  <= '0;
    `ifdef ISA_Zicsr
      ex_dec_excp_type_o   <= '0;
      ex_dec_int_type_o    <= '0;
      ex_dec_csr_addr_o    <= '0;
      ex_dec_csr_zimm_o    <= '0;
    `endif
      ex_bpu_prd_tkn_o     <= '0;
      ex_bpu_prd_pc_o      <= '0;
      ex_bpu_prd_sat_cnt_o <= '0;
    end else if (pcu_clear_id_ex_i) begin
      ex_pc_o              <= '0;
      ex_inst_o            <= '0;
      ex_dec_grp_o         <= '0;
      ex_dec_info_o        <= '0;
      ex_dec_rs1_vld_o     <= '0;
      ex_dec_rs1_idx_o     <= '0;
      ex_dec_rs1_o         <= '0;
      ex_dec_rs2_vld_o     <= '0;
      ex_dec_rs2_idx_o     <= '0;
      ex_dec_rs2_o         <= '0;
      ex_dec_rd_vld_o      <= '0;
      ex_dec_rd_idx_o      <= '0;
      ex_dec_imm_o         <= '0;
      ex_dec_load_size_o   <= '0;
      ex_dec_store_size_o  <= '0;
    `ifdef ISA_Zicsr
      ex_dec_excp_type_o   <= '0;
      ex_dec_int_type_o    <= '0;
      ex_dec_csr_addr_o    <= '0;
      ex_dec_csr_zimm_o    <= '0;
    `endif
      ex_bpu_prd_tkn_o     <= '0;
      ex_bpu_prd_pc_o      <= '0;
      ex_bpu_prd_sat_cnt_o <= '0;
    end else if (pcu_stall_id_ex_i) begin
      ex_pc_o              <= ex_pc_o;
      ex_inst_o            <= ex_inst_o;
      ex_dec_grp_o         <= ex_dec_grp_o;
      ex_dec_info_o        <= ex_dec_info_o;
      ex_dec_rs1_vld_o     <= ex_dec_rs1_vld_o;
      ex_dec_rs1_idx_o     <= ex_dec_rs1_idx_o;
      ex_dec_rs1_o         <= ex_dec_rs1_o;
      ex_dec_rs2_vld_o     <= ex_dec_rs2_vld_o;
      ex_dec_rs2_idx_o     <= ex_dec_rs2_idx_o;
      ex_dec_rs2_o         <= ex_dec_rs2_o;
      ex_dec_rd_vld_o      <= ex_dec_rd_vld_o;
      ex_dec_rd_idx_o      <= ex_dec_rd_idx_o;
      ex_dec_imm_o         <= ex_dec_imm_o;
      ex_dec_load_size_o   <= ex_dec_load_size_o;
      ex_dec_store_size_o  <= ex_dec_store_size_o;
    `ifdef ISA_Zicsr
      ex_dec_excp_type_o   <= ex_dec_excp_type_o;
      ex_dec_int_type_o    <= ex_dec_int_type_o;
      ex_dec_csr_addr_o    <= ex_dec_csr_addr_o;
      ex_dec_csr_zimm_o    <= ex_dec_csr_zimm_o;
    `endif
      ex_bpu_prd_tkn_o     <= ex_bpu_prd_tkn_o;
      ex_bpu_prd_pc_o      <= ex_bpu_prd_pc_o;
      ex_bpu_prd_sat_cnt_o <= ex_bpu_prd_sat_cnt_o;
    end else if (id_stage_vld_i & ex_stage_rdy_i) begin
      ex_pc_o              <= id_pc_i;
      ex_inst_o            <= id_inst_i;
      ex_dec_grp_o         <= id_dec_grp_i;
      ex_dec_info_o        <= id_dec_info_i;
      ex_dec_rs1_vld_o     <= id_dec_rs1_vld_i;
      ex_dec_rs1_idx_o     <= id_dec_rs1_idx_i;
      ex_dec_rs1_o         <= id_dec_rs1_i;
      ex_dec_rs2_vld_o     <= id_dec_rs2_vld_i;
      ex_dec_rs2_idx_o     <= id_dec_rs2_idx_i;
      ex_dec_rs2_o         <= id_dec_rs2_i;
      ex_dec_rd_vld_o      <= id_dec_rd_vld_i;
      ex_dec_rd_idx_o      <= id_dec_rd_idx_i;
      ex_dec_imm_o         <= id_dec_imm_i;
      ex_dec_load_size_o   <= id_dec_load_size_i;
      ex_dec_store_size_o  <= id_dec_store_size_i;
    `ifdef ISA_Zicsr
      ex_dec_excp_type_o   <= id_dec_excp_type_i;
      ex_dec_int_type_o    <= id_dec_int_type_i;
      ex_dec_csr_addr_o    <= id_dec_csr_addr_i;
      ex_dec_csr_zimm_o    <= id_dec_csr_zimm_i;
    `endif
      ex_bpu_prd_tkn_o     <= id_bpu_prd_tkn_i;
      ex_bpu_prd_pc_o      <= id_bpu_prd_pc_i;
      ex_bpu_prd_sat_cnt_o <= id_bpu_prd_sat_cnt_i;
    end
  end

`ifndef ISA_Zicsr
  assign ex_dec_excp_type_o = '0;
  assign ex_dec_int_type_o  = '0;
  assign ex_dec_csr_addr_o  = '0;
  assign ex_dec_csr_zimm_o  = '0;
`endif

endmodule
