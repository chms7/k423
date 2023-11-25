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
  input                           pcu_stall_loaduse_i,
  input                           pcu_flush_br_i,
  // pipeline handshake
  input  logic                    if_stage_vld_i,
  input  logic                    id_stage_rdy_i,
  output logic                    if2id_stage_vld_o,
  // if stage
  input  logic [`CORE_ADDR_W-1:0] if_pc_i,
  input  logic [`CORE_INST_W-1:0] if_inst_i,
  // id stage
  output logic [`CORE_ADDR_W-1:0] id_pc_o,
  output logic [`CORE_INST_W-1:0] id_inst_o
);
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      if2id_stage_vld_o <= 1'b0;
    else if (pcu_flush_br_i)
      if2id_stage_vld_o <= 1'b0;
    else if (id_stage_rdy_i)
      if2id_stage_vld_o <= if_stage_vld_i;
  end

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      id_pc_o    <= '0;
      id_inst_o  <= '0;
    end else if (pcu_flush_br_i) begin
      id_pc_o    <= '0;
      id_inst_o  <= '0;
    end else if (if_stage_vld_i & id_stage_rdy_i & ~pcu_stall_loaduse_i) begin
      id_pc_o    <= if_pc_i;
      id_inst_o  <= if_inst_i;
    end
  end
  
endmodule
