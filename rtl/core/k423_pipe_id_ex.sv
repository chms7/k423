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
  input                             pcu_stall_loaduse_i,
  input                             pcu_flush_br_i,
  // pipeline handshake
  input  logic                      id_stage_vld_i,
  input  logic                      ex_stage_rdy_i,
  output logic                      id2ex_stage_vld_o,
  // id stage
  input  logic [`CORE_ADDR_W-1:0]   id_pc_i,
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
  input  logic [`RSD_SIZE_W-1:0]    id_dec_load_size_i,
  input  logic [`RSD_SIZE_W-1:0]    id_dec_store_size_i,
  // ex stage
  output logic [`CORE_ADDR_W-1:0]   ex_pc_o,
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
  output logic [`RSD_SIZE_W-1:0]    ex_dec_load_size_o,
  output logic [`RSD_SIZE_W-1:0]    ex_dec_store_size_o
);
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      id2ex_stage_vld_o <= 1'b0;
    else if (pcu_flush_br_i)
      id2ex_stage_vld_o <= 1'b0;
    else if (ex_stage_rdy_i)
      id2ex_stage_vld_o <= id_stage_vld_i;
  end

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      ex_pc_o             <= '0;
      ex_dec_grp_o        <= '0;
      ex_dec_info_o       <= '0;
      ex_dec_rs1_vld_o    <= '0;
      ex_dec_rs1_idx_o    <= '0;
      ex_dec_rs1_o        <= '0;
      ex_dec_rs2_vld_o    <= '0;
      ex_dec_rs2_idx_o    <= '0;
      ex_dec_rs2_o        <= '0;
      ex_dec_rd_vld_o     <= '0;
      ex_dec_rd_idx_o     <= '0;
      ex_dec_imm_o        <= '0;
      ex_dec_load_size_o  <= '0;
      ex_dec_store_size_o <= '0;
    end else if (pcu_flush_br_i | pcu_stall_loaduse_i) begin
      ex_pc_o             <= '0;
      ex_dec_grp_o        <= '0;
      ex_dec_info_o       <= '0;
      ex_dec_rs1_vld_o    <= '0;
      ex_dec_rs1_idx_o    <= '0;
      ex_dec_rs1_o        <= '0;
      ex_dec_rs2_vld_o    <= '0;
      ex_dec_rs2_idx_o    <= '0;
      ex_dec_rs2_o        <= '0;
      ex_dec_rd_vld_o     <= '0;
      ex_dec_rd_idx_o     <= '0;
      ex_dec_imm_o        <= '0;
      ex_dec_load_size_o  <= '0;
      ex_dec_store_size_o <= '0;
    end else if (id_stage_vld_i & ex_stage_rdy_i) begin
      ex_pc_o             <= id_pc_i;
      ex_dec_grp_o        <= id_dec_grp_i;
      ex_dec_info_o       <= id_dec_info_i;
      ex_dec_rs1_vld_o    <= id_dec_rs1_vld_i;
      ex_dec_rs1_idx_o    <= id_dec_rs1_idx_i;
      ex_dec_rs1_o        <= id_dec_rs1_i;
      ex_dec_rs2_vld_o    <= id_dec_rs2_vld_i;
      ex_dec_rs2_idx_o    <= id_dec_rs2_idx_i;
      ex_dec_rs2_o        <= id_dec_rs2_i;
      ex_dec_rd_vld_o     <= id_dec_rd_vld_i;
      ex_dec_rd_idx_o     <= id_dec_rd_idx_i;
      ex_dec_imm_o        <= id_dec_imm_i;
      ex_dec_load_size_o  <= id_dec_load_size_i;
      ex_dec_store_size_o <= id_dec_store_size_i;
    end
  end
endmodule
