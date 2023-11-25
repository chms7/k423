/*
 * @Design: k423_if_pcgen
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: PC generate unit of if stage
 */
`include "k423_defines.svh"

module k423_if_pcgen (
  input                            clk_i,
  input                            rst_n_i,
  // pipeline control
  input                            pcu_stall_loaduse_i,
  input                            pcu_flush_br_i,
  // pipeline handshake
  output logic                     pc_stage_vld_o,
  input  logic                     if_stage_rdy_i,
  // branch
  input logic                      bju_br_tkn_i,
  input logic [`CORE_XLEN-1:0]     bju_br_pc_i,
  input logic                      bpu_br_tkn_i,
  input logic [`CORE_XLEN-1:0]     bpu_br_pc_i,
  // pc
  output logic [`CORE_ADDR_W -1:0] pc_o,
  output logic [`CORE_DATA_W -1:0] next_pc_o
);
  // generate next pc
  logic [`CORE_ADDR_W-1:0] pc, next_pc;
  logic [`CORE_ADDR_W-1:0] norm_next_pc;

  utils_adder32  u_adder_pcgen(
    .a    ( pc           ),
    .b    ( 32'd4        ),
    .cin  ( 1'b0         ),
    .sum  ( norm_next_pc ),
    .cout (              )
  );

  assign next_pc = bju_br_tkn_i ? bju_br_pc_i : norm_next_pc;

  // update pc
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      pc <= `RST_PC;
    else if (if_stage_rdy_i & ~pcu_stall_loaduse_i)
      pc <= next_pc;
  end
  
  // pipeline handshake
  // ignore RST_PC
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      pc_stage_vld_o <= 1'b0;
    else
      pc_stage_vld_o <= 1'b1;
  end

  assign pc_o      = pc;
  assign next_pc_o = next_pc;
  
endmodule
