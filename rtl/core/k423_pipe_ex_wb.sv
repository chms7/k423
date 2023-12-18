/*
 * @Design: k423_pipe_ex_wb
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Pipeline between ex & wb stage
 */
`include "k423_defines.svh"

module k423_pipe_ex_wb (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline control
  input                             pcu_clear_ex_wb_i,
  input                             pcu_stall_ex_wb_i,
  // pipeline handshake
  input  logic                      ex_stage_vld_i,
  input  logic                      wb_stage_rdy_i,
  output logic                      ex2wb_stage_vld_o,
  // ex stage
  input  logic [`CORE_ADDR_W-1:0]   ex_pc_i,
  input  logic                      ex_rd_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] ex_rd_idx_i,
  input  logic [`CORE_XLEN-1:0]     ex_rd_i,
  input  logic                      ex_rd_load_i,
  input  logic [`LS_SIZE_W-1:0]     ex_rd_load_size_i,
  input  logic                      ex_rd_load_unsigned_i,
  input  logic [`CORE_ADDR_W-1:0]   ex_rd_load_addr_i,
  input  logic                      ex_excp_br_tkn_i,
  input  logic [`CORE_XLEN-1:0]     ex_excp_br_pc_i,
  input  logic                      ex_bju_br_tkn_i,
  input  logic [`CORE_XLEN-1:0]     ex_bju_br_pc_i,
  // wb stage
  output logic [`CORE_ADDR_W-1:0]   wb_pc_o,
  output logic                      wb_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] wb_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     wb_rd_o,
  output logic                      wb_rd_load_o,
  output logic [`LS_SIZE_W-1:0]     wb_rd_load_size_o,
  output logic                      wb_rd_load_unsigned_o,
  output logic [`CORE_ADDR_W-1:0]   wb_rd_load_addr_o,
  output logic                      wb_excp_br_tkn_o,
  output logic [`CORE_XLEN-1:0]     wb_excp_br_pc_o,
  output logic                      wb_bju_br_tkn_o,
  output logic [`CORE_XLEN-1:0]     wb_bju_br_pc_o
);
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      ex2wb_stage_vld_o <= 1'b0;
    else if (pcu_clear_ex_wb_i)
      ex2wb_stage_vld_o <= 1'b0;
    else if (wb_stage_rdy_i)
      ex2wb_stage_vld_o <= ex_stage_vld_i;
  end

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      wb_pc_o               <= '0;
      wb_rd_vld_o           <= '0;
      wb_rd_idx_o           <= '0;
      wb_rd_o               <= '0;
      wb_rd_load_o          <= '0;
      wb_rd_load_size_o     <= '0;
      wb_rd_load_unsigned_o <= '0;
      wb_rd_load_addr_o     <= '0;
      wb_excp_br_tkn_o      <= '0;
      wb_excp_br_pc_o       <= '0;
      wb_bju_br_tkn_o       <= '0;
      wb_bju_br_pc_o        <= '0;
    end else if (pcu_clear_ex_wb_i) begin
      wb_pc_o               <= '0;
      wb_rd_vld_o           <= '0;
      wb_rd_idx_o           <= '0;
      wb_rd_o               <= '0;
      wb_rd_load_o          <= '0;
      wb_rd_load_size_o     <= '0;
      wb_rd_load_unsigned_o <= '0;
      wb_rd_load_addr_o     <= '0;
      wb_excp_br_tkn_o      <= '0;
      wb_excp_br_pc_o       <= '0;
      wb_bju_br_tkn_o       <= '0;
      wb_bju_br_pc_o        <= '0;
    end else if (pcu_stall_ex_wb_i) begin
      wb_pc_o               <= wb_pc_o;
      wb_rd_vld_o           <= wb_rd_vld_o;
      wb_rd_idx_o           <= wb_rd_idx_o;
      wb_rd_o               <= wb_rd_o;
      wb_rd_load_o          <= wb_rd_load_o;
      wb_rd_load_size_o     <= wb_rd_load_size_o;
      wb_rd_load_unsigned_o <= wb_rd_load_unsigned_o;
      wb_rd_load_addr_o     <= wb_rd_load_addr_o;
      wb_excp_br_tkn_o      <= wb_excp_br_tkn_o;
      wb_excp_br_pc_o       <= wb_excp_br_pc_o;
      wb_bju_br_tkn_o       <= wb_bju_br_tkn_o;
      wb_bju_br_pc_o        <= wb_bju_br_pc_o;
    end else if (ex_stage_vld_i & wb_stage_rdy_i) begin
      wb_pc_o               <= ex_pc_i;
      wb_rd_vld_o           <= ex_rd_vld_i;
      wb_rd_idx_o           <= ex_rd_idx_i;
      wb_rd_o               <= ex_rd_i;
      wb_rd_load_o          <= ex_rd_load_i;
      wb_rd_load_size_o     <= ex_rd_load_size_i;
      wb_rd_load_unsigned_o <= ex_rd_load_unsigned_i;
      wb_rd_load_addr_o     <= ex_rd_load_addr_i;
      wb_excp_br_tkn_o      <= ex_excp_br_tkn_i;
      wb_excp_br_pc_o       <= ex_excp_br_pc_i;
      wb_bju_br_tkn_o       <= ex_bju_br_tkn_i;
      wb_bju_br_pc_o        <= ex_bju_br_pc_i;
    end
  end
  
endmodule
