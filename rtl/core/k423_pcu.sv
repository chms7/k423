/*
 * @Design: k423_id_stage
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Instruction-Decode stage of core
 */
`include "k423_defines.svh"

module k423_pcu (
  input                             clk_i,
  input                             rst_n_i,
  // rs in id & rd in ex
  input logic                       id_dec_rs1_vld_i,
  input logic [`INST_RSDIDX_W-1:0]  id_dec_rs1_idx_i,
  input logic                       id_dec_rs2_vld_i,
  input logic [`INST_RSDIDX_W-1:0]  id_dec_rs2_idx_i,
  input logic                       ex_rd_vld_i,
  input logic [`INST_RSDIDX_W-1:0]  ex_rd_idx_i,
  input logic                       ex_rd_mem_i,
  // branch taken
  input logic                       mem_bju_br_tkn_i,
  // pipeline control signals
  output                            pcu_stall_loaduse_o,
  output                            pcu_flush_br_o
);
  // stall pc & if & id stages when load-use hazard occurs
  assign pcu_stall_loaduse_o = (id_dec_rs1_vld_i & ex_rd_vld_i & ex_rd_mem_i & (id_dec_rs1_idx_i == ex_rd_idx_i) & (id_dec_rs1_idx_i != '0)) |
                               (id_dec_rs2_vld_i & ex_rd_vld_i & ex_rd_mem_i & (id_dec_rs2_idx_i == ex_rd_idx_i) & (id_dec_rs2_idx_i != '0));
  // flush pc & if & id stages when branch taken
  assign pcu_flush_br_o = mem_bju_br_tkn_i;
  
endmodule
