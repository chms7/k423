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
  input logic                       ex_rd_load_i,
  // branch taken
  input logic                       wb_bju_upd_mis_i,
  input logic                       wb_excp_br_tkn_i,
  // pipeline control signals
  output                            pcu_clear_pc_o,
  output                            pcu_clear_if_id_o,
  output                            pcu_clear_id_ex_o,
  output                            pcu_clear_ex_wb_o,

  output                            pcu_stall_pc_o,
  output                            pcu_stall_if_id_o,
  output                            pcu_stall_id_ex_o,
  output                            pcu_stall_ex_wb_o
);
  // when load-use hazard occurs, stall pc & if2id pipe and clear id2ex pipe
  wire pcu_loaduse_w = pcu_branch_w ? 1'b0
                                    : ((id_dec_rs1_vld_i & ex_rd_vld_i & ex_rd_load_i & (id_dec_rs1_idx_i == ex_rd_idx_i) & (id_dec_rs1_idx_i != '0)) |
                                       (id_dec_rs2_vld_i & ex_rd_vld_i & ex_rd_load_i & (id_dec_rs2_idx_i == ex_rd_idx_i) & (id_dec_rs2_idx_i != '0)));
  // when branch taken, clear if2id & id2ex & ex2wb pipe
  wire pcu_branch_w  = wb_bju_upd_mis_i | wb_excp_br_tkn_i;
  
  assign pcu_clear_pc_o    = 1'b0;
  assign pcu_stall_pc_o    = pcu_loaduse_w;
  
  assign pcu_clear_if_id_o = pcu_branch_w;
  assign pcu_stall_if_id_o = pcu_loaduse_w;

  assign pcu_clear_id_ex_o = pcu_branch_w | pcu_loaduse_w;
  assign pcu_stall_id_ex_o = pcu_loaduse_w;
  
  assign pcu_clear_ex_wb_o = pcu_branch_w;
  assign pcu_stall_ex_wb_o = 1'b0;


  
endmodule
