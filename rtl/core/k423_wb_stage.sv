/*
 * @Design: k423_wb_stage
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Write-Back stage of core
 */
`include "k423_defines.svh"

module k423_wb_stage (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline handshake
  input  logic                      mem_stage_vld_i,
  output logic                      wb_stage_vld_o,
  output logic                      wb_stage_rdy_o,
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
  // ---------------------------------------------------------------------------
  // Rd Write Back
  // ---------------------------------------------------------------------------
  assign wb_pc_o     = mem_pc_i;

  assign wb_rd_o     = mem_rd_i;
  assign wb_rd_vld_o = wb_stage_vld_o & mem_rd_vld_i;
  assign wb_rd_idx_o = mem_rd_idx_i;

  // ---------------------------------------------------------------------------
  // Pipeline Handshake
  // ---------------------------------------------------------------------------
  wire   wb_stage_done  = 1'b1;
  assign wb_stage_vld_o = mem_stage_vld_i & wb_stage_done;
  assign wb_stage_rdy_o = ~mem_stage_vld_i | wb_stage_done;

  
endmodule
