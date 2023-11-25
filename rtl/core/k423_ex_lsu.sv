/*
 * @Design: k423_ex_lsu
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: LSU of ex stage
 */
`include "k423_defines.svh"

module k423_ex_lsu (
  input                             clk_i,
  input                             rst_n_i,
  // id stage
  input  logic [`CORE_ADDR_W-1:0]   pc_i,
  input  logic [`INST_GRP_W-1:0]    dec_grp_i,
  input  logic [`INST_INFO_W-1:0]   dec_info_i,
  input  logic [`CORE_XLEN-1:0]     dec_rs1_i,
  input  logic [`CORE_XLEN-1:0]     dec_rs2_i,
  input  logic [`CORE_XLEN-1:0]     dec_imm_i,
  input  logic [`RSD_SIZE_W-1:0]    dec_store_size_i,
  // lsu
  output logic                      lsu_rd_load_o,
  output logic                      lsu_rd_load_unsigned_o,
  // data mem request
  output logic                      lsu_mem_req_vld_o,
  output logic [`CORE_XLEN/8-1:0]   lsu_mem_req_wen_o,
  output logic [`CORE_ADDR_W -1:0]  lsu_mem_req_addr_o,
  output logic [`CORE_FETCH_W-1:0]  lsu_mem_req_wdata_o,
  input  logic                      lsu_mem_req_rdy_i
);
  // generate address
  wire [`CORE_XLEN-1:0] addr_adder_src    = dec_rs1_i;
  wire [`CORE_XLEN-1:0] addr_adder_offset = dec_imm_i;
  wire [`CORE_XLEN-1:0] addr_adder_res;
  
  utils_adder32  u_adder_lsu (
    .a    ( addr_adder_src    ),
    .b    ( addr_adder_offset ),
    .cin  ( 1'b0              ),
    .sum  ( addr_adder_res    ),
    .cout (                   )
  );

  // memory request
  assign lsu_mem_req_vld_o    = dec_grp_i[`INST_GRP_LSU];
  assign lsu_mem_req_wen_o    = {4{dec_info_i[`INST_INFO_LSU_STORE] & (dec_store_size_i == `RSD_SIZE_BYTE)}} & 4'b0001 |
                                {4{dec_info_i[`INST_INFO_LSU_STORE] & (dec_store_size_i == `RSD_SIZE_HALF)}} & 4'b0011 |
                                {4{dec_info_i[`INST_INFO_LSU_STORE] & (dec_store_size_i == `RSD_SIZE_WORD)}} & 4'b1111 ;
  assign lsu_mem_req_addr_o   = addr_adder_res;
  assign lsu_mem_req_wdata_o  = dec_rs2_i;
  
  // rd from load
  assign lsu_rd_load_o           = dec_grp_i[`INST_GRP_LSU] & dec_info_i[`INST_INFO_LSU_LOAD];
  assign lsu_rd_load_unsigned_o  = dec_info_i[`INST_INFO_LSU_UNSIGNED];

endmodule
