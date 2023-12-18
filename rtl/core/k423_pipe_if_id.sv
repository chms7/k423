/*
 * @Design: k423_pipe_if_id
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Pipeline between if & id stage
 */
`include "k423_defines.svh"

module k423_pipe_if_id (
  input                           clk_i,
  input                           rst_n_i,
  // pipeline control
  input                           pcu_clear_if_id_i,
  input                           pcu_stall_if_id_i,
  // pipeline handshake
  input  logic                    if_stage_vld_i,
  input  logic                    id_stage_rdy_i,
  output logic                    if2id_stage_vld_o,
  // if stage
  input  logic [`CORE_ADDR_W-1:0] if_pc_i,
  input  logic [`CORE_INST_W-1:0] if_inst_i,
  input  logic                    if_bpu_prd_tkn_i,
  input  logic [`CORE_ADDR_W-1:0] if_bpu_prd_pc_i,
  input  logic [1:0]              if_bpu_prd_sat_cnt_i,
  // id stage
  output logic [`CORE_ADDR_W-1:0] id_pc_o,
  output logic [`CORE_INST_W-1:0] id_inst_o,
  output logic                    id_bpu_prd_tkn_o,
  output logic [`CORE_ADDR_W-1:0] id_bpu_prd_pc_o,
  output logic [1:0]              id_bpu_prd_sat_cnt_o
);
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      if2id_stage_vld_o <= 1'b0;
    else if (pcu_clear_if_id_i)
      if2id_stage_vld_o <= 1'b0;
    else if (id_stage_rdy_i)
      if2id_stage_vld_o <= if_stage_vld_i;
  end

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      id_pc_o              <= '0;
      id_inst_o            <= '0;
      id_bpu_prd_tkn_o     <= '0;
      id_bpu_prd_pc_o      <= '0;
      id_bpu_prd_sat_cnt_o <= '0;
    end else if (pcu_clear_if_id_i) begin
      id_pc_o              <= '0;
      id_inst_o            <= '0;
      id_bpu_prd_tkn_o     <= '0;
      id_bpu_prd_pc_o      <= '0;
      id_bpu_prd_sat_cnt_o <= '0;
    end else if (pcu_stall_if_id_i) begin
      id_pc_o              <= id_pc_o;
      id_inst_o            <= id_inst_o;
      id_bpu_prd_tkn_o     <= id_bpu_prd_tkn_o;
      id_bpu_prd_pc_o      <= id_bpu_prd_pc_o;
      id_bpu_prd_sat_cnt_o <= id_bpu_prd_sat_cnt_o;
    end else if (if_stage_vld_i & id_stage_rdy_i) begin
      id_pc_o              <= if_pc_i;
      id_inst_o            <= if_inst_i;
      id_bpu_prd_tkn_o     <= if_bpu_prd_tkn_i;
      id_bpu_prd_pc_o      <= if_bpu_prd_pc_i;
      id_bpu_prd_sat_cnt_o <= if_bpu_prd_sat_cnt_i;
    end
  end
  
endmodule
