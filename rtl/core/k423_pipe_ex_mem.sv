/*
 * @Design: k423_pipe_ex_mem
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Pipeline between ex & mem stage
 */
`include "k423_defines.svh"

module k423_pipe_ex_mem (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline control
  input                             pcu_stall_loaduse_i,
  input                             pcu_flush_br_i,
  // pipeline handshake
  input  logic                      ex_stage_vld_i,
  input  logic                      mem_stage_rdy_i,
  output logic                      ex2mem_stage_vld_o,
  // ex stage
  input  logic [`CORE_ADDR_W-1:0]   ex_pc_i,
  input  logic                      ex_rd_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] ex_rd_idx_i,
  input  logic [`CORE_XLEN-1:0]     ex_rd_i,
  input  logic                      ex_rd_load_i,
  input  logic [`RSD_SIZE_W-1:0]    ex_rd_load_size_i,
  input  logic                      ex_rd_load_unsigned_i,
  input  logic [`CORE_ADDR_W-1:0]   ex_rd_load_addr_i,
  input  logic                      ex_bju_br_tkn_i,
  input  logic [`CORE_XLEN-1:0]     ex_bju_br_pc_i,
  // mem stage
  output logic [`CORE_ADDR_W-1:0]   mem_pc_o,
  output logic                      mem_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] mem_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     mem_rd_o,
  output logic                      mem_rd_load_o,
  output logic [`RSD_SIZE_W-1:0]    mem_rd_load_size_o,
  output logic                      mem_rd_load_unsigned_o,
  output logic [`CORE_ADDR_W-1:0]   mem_rd_load_addr_o,
  output logic                      mem_bju_br_tkn_o,
  output logic [`CORE_XLEN-1:0]     mem_bju_br_pc_o
);
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      ex2mem_stage_vld_o <= 1'b0;
    else if (pcu_flush_br_i)
      ex2mem_stage_vld_o <= 1'b0;
    else if (mem_stage_rdy_i)
      ex2mem_stage_vld_o <= ex_stage_vld_i;
  end

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      mem_pc_o                <= '0;
      mem_rd_vld_o            <= '0;
      mem_rd_idx_o            <= '0;
      mem_rd_o                <= '0;
      mem_rd_load_o           <= '0;
      mem_rd_load_size_o      <= '0;
      mem_rd_load_unsigned_o  <= '0;
      mem_rd_load_addr_o      <= '0;
      mem_bju_br_tkn_o        <= '0;
      mem_bju_br_pc_o         <= '0;
    end else if (pcu_flush_br_i) begin
      mem_pc_o                <= '0;
      mem_rd_vld_o            <= '0;
      mem_rd_idx_o            <= '0;
      mem_rd_o                <= '0;
      mem_rd_load_o           <= '0;
      mem_rd_load_size_o      <= '0;
      mem_rd_load_unsigned_o  <= '0;
      mem_rd_load_addr_o      <= '0;
      mem_bju_br_tkn_o        <= '0;
      mem_bju_br_pc_o         <= '0;
    end else if (ex_stage_vld_i & mem_stage_rdy_i) begin
      mem_pc_o                <= ex_pc_i;
      mem_rd_vld_o            <= ex_rd_vld_i;
      mem_rd_idx_o            <= ex_rd_idx_i;
      mem_rd_o                <= ex_rd_i;
      mem_rd_load_o           <= ex_rd_load_i;
      mem_rd_load_size_o      <= ex_rd_load_size_i;
      mem_rd_load_unsigned_o  <= ex_rd_load_unsigned_i;
      mem_rd_load_addr_o      <= ex_rd_load_addr_i;
      mem_bju_br_tkn_o        <= ex_bju_br_tkn_i;
      mem_bju_br_pc_o         <= ex_bju_br_pc_i;
    end
  end
  
endmodule
