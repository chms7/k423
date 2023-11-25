/*
 * @Design: k423_pipe_mem_wb
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Pipeline between mem & wb stage
 */
`include "k423_defines.svh"

module k423_pipe_mem_wb (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline control
  input                             pcu_stall_loaduse_i,
  input                             pcu_flush_br_i,
  // pipeline handshake
  input  logic                      mem_stage_vld_i,
  input  logic                      wb_stage_rdy_i,
  output logic                      mem2wb_stage_vld_o,
  // mem stage
  input  logic [`CORE_ADDR_W-1:0]   mem_pc_i,
  input  logic                      mem_rd_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] mem_rd_idx_i,
  input  logic [`CORE_XLEN-1:0]     mem_rd_i,
  // wb stage
  output logic [`CORE_ADDR_W-1:0]   wb_pc_o,
  output logic                      wb_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] wb_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     wb_rd_o
);
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      mem2wb_stage_vld_o <= 1'b0;
    else if (wb_stage_rdy_i)
      mem2wb_stage_vld_o <= mem_stage_vld_i;
  end

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      wb_pc_o     <= '0;
      wb_rd_vld_o <= '0;
      wb_rd_idx_o <= '0;
      wb_rd_o     <= '0;
    end else if (mem_stage_vld_i & wb_stage_rdy_i) begin
      wb_pc_o     <= mem_pc_i;
      wb_rd_vld_o <= mem_rd_vld_i;
      wb_rd_idx_o <= mem_rd_idx_i;
      wb_rd_o     <= mem_rd_i;
    end
  end
  
endmodule
