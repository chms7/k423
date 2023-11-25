/*
 * @Design: k423_mem_stage
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Memory-Access stage of core
 */
`include "k423_defines.svh"

module k423_mem_stage (
  input                             clk_i,
  input                             rst_n_i,
  // pipeline handshake
  input  logic                      ex_stage_vld_i,
  output logic                      mem_stage_vld_o,
  output logic                      mem_stage_rdy_o,
  input  logic                      wb_stage_rdy_i,
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
  // memory response
  input  logic                      mem_data_rsp_vld_i,
  input  logic [`CORE_FETCH_W-1:0]  mem_data_rsp_rdata_i,
  // mem stage
  output logic [`CORE_ADDR_W-1:0]   mem_pc_o,
  output logic                      mem_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] mem_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     mem_rd_o,

  output logic                      mem_bju_br_tkn_o,
  output logic [`CORE_XLEN-1:0]     mem_bju_br_pc_o
);
  // ---------------------------------------------------------------------------
  // Rd Select
  // ---------------------------------------------------------------------------
  assign mem_pc_o = ex_pc_i;
  assign mem_rd_vld_o = ex_rd_vld_i;
  assign mem_rd_idx_o = ex_rd_idx_i;
  
  wire load_unsigned_byte = ex_rd_load_i & (ex_rd_load_size_i == `RSD_SIZE_BYTE) &  ex_rd_load_unsigned_i;
  wire load_signed_byte   = ex_rd_load_i & (ex_rd_load_size_i == `RSD_SIZE_BYTE) & ~ex_rd_load_unsigned_i;
  wire load_unsigned_half = ex_rd_load_i & (ex_rd_load_size_i == `RSD_SIZE_HALF) &  ex_rd_load_unsigned_i;
  wire load_signed_half   = ex_rd_load_i & (ex_rd_load_size_i == `RSD_SIZE_HALF) & ~ex_rd_load_unsigned_i;
  wire load_signed_word   = ex_rd_load_i & (ex_rd_load_size_i == `RSD_SIZE_WORD);
  
  wire [`CORE_XLEN-1:0] data_load_unsigned_byte = {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b00}} & {24'd0, mem_data_rsp_rdata_i[7:0]}  |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b01}} & {24'd0, mem_data_rsp_rdata_i[15:8]} |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b10}} & {24'd0, mem_data_rsp_rdata_i[23:16]}|
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b11}} & {24'd0, mem_data_rsp_rdata_i[31:24]};
  wire [`CORE_XLEN-1:0] data_load_signed_byte   = {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b00}} & {{24{mem_data_rsp_rdata_i[7]}},  mem_data_rsp_rdata_i[7:0]}  |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b01}} & {{24{mem_data_rsp_rdata_i[15]}}, mem_data_rsp_rdata_i[15:8]} |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b10}} & {{24{mem_data_rsp_rdata_i[23]}}, mem_data_rsp_rdata_i[23:16]}|
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b11}} & {{24{mem_data_rsp_rdata_i[31]}}, mem_data_rsp_rdata_i[31:24]};
  wire [`CORE_XLEN-1:0] data_load_unsigned_half = {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b00}} & {16'd0, mem_data_rsp_rdata_i[15:0]} |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b01}} & {16'd0, mem_data_rsp_rdata_i[23:8]} |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b10}} & {16'd0, mem_data_rsp_rdata_i[31:16]}|
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b11}} & {16'd0, mem_data_rsp_rdata_i[31:16]}; // ?
  wire [`CORE_XLEN-1:0] data_load_signed_half   = {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b00}} & {{16{mem_data_rsp_rdata_i[15]}}, mem_data_rsp_rdata_i[15:0]} |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b01}} & {{16{mem_data_rsp_rdata_i[23]}}, mem_data_rsp_rdata_i[23:8]} |
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b10}} & {{16{mem_data_rsp_rdata_i[31]}}, mem_data_rsp_rdata_i[31:16]}|
                                                  {`CORE_XLEN{ex_rd_load_addr_i[1:0] == 2'b11}} & {{16{mem_data_rsp_rdata_i[31]}}, mem_data_rsp_rdata_i[31:16]}; // ?
  wire [`CORE_XLEN-1:0] data_load_word          = mem_data_rsp_rdata_i;
  
  assign mem_rd_o = {`CORE_XLEN{load_unsigned_byte}} & data_load_unsigned_byte |
                    {`CORE_XLEN{load_signed_byte  }} & data_load_signed_byte   |
                    {`CORE_XLEN{load_unsigned_half}} & data_load_unsigned_half |
                    {`CORE_XLEN{load_signed_half  }} & data_load_signed_half   |
                    {`CORE_XLEN{load_signed_word  }} & data_load_word          |
                    {`CORE_XLEN{~ex_rd_load_i     }} & ex_rd_i                 ;
  
  // ---------------------------------------------------------------------------
  // Branch
  // ---------------------------------------------------------------------------
  assign mem_bju_br_tkn_o = ex_bju_br_tkn_i;
  assign mem_bju_br_pc_o  = ex_bju_br_pc_i;

  // ---------------------------------------------------------------------------
  // Pipeline Handshake
  // ---------------------------------------------------------------------------
  wire   mem_stage_done  = 1'b1;
  assign mem_stage_vld_o = ex_stage_vld_i & mem_stage_done;
  assign mem_stage_rdy_o = ~ex_stage_vld_i | mem_stage_done & wb_stage_rdy_i;
  
endmodule
