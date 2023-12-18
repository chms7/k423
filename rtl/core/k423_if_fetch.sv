/*
 * @Design: k423_if_fetch
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Fetch unit of if stage
 */
`include "k423_defines.svh"

module k423_if_fetch (
  input                            clk_i,
  input                            rst_n_i,
  // pipeline control
  input                            pcu_clear_pc_i,
  input                            pcu_stall_pc_i,
  // pipeline handshake
  output logic                     pc_stage_vld_o,
  input  logic                     if_stage_rdy_i,
  // branch
  input logic                      wb_excp_br_tkn_i,
  input logic [`CORE_XLEN-1:0]     wb_excp_br_pc_i,
  input logic                      wb_bju_br_mis_i,
  input logic [`CORE_XLEN-1:0]     wb_bju_br_pc_i,
  input logic                      if_bpu_br_tkn_i,
  input logic [`CORE_XLEN-1:0]     if_bpu_br_pc_i,
  // inst mem request
  output logic                     if_mem_req_vld_o,
  output logic                     if_mem_req_wen_o,
  output logic [`CORE_ADDR_W -1:0] if_mem_req_addr_o,
  output logic [`CORE_XLEN-1:0]    if_mem_req_wdata_o,
  input  logic                     if_mem_req_rdy_i,
  input  logic                     if_mem_rsp_vld_i,
  input  logic [`CORE_FETCH_W-1:0] if_mem_rsp_rdata_i,
  // pc & instruction
  output logic [`CORE_ADDR_W -1:0] pc_o,
  output logic [`CORE_DATA_W -1:0] inst_o
);
  // generate pc
  logic [`CORE_ADDR_W-1:0] pc, next_pc;

  k423_if_pcgen  u_k423_if_pcgen (
    .clk_i                ( clk_i               ),
    .rst_n_i              ( rst_n_i             ),
    
    .pcu_clear_pc_i       ( pcu_clear_pc_i      ),
    .pcu_stall_pc_i       ( pcu_stall_pc_i      ),
    
    .pc_stage_vld_o       ( pc_stage_vld_o      ),
    .if_stage_rdy_i       ( if_stage_rdy_i      ),
                                                
    .excp_br_tkn_i        ( wb_excp_br_tkn_i    ),
    .excp_br_pc_i         ( wb_excp_br_pc_i     ),
    .bju_br_mis_i         ( wb_bju_br_mis_i     ),
    .bju_br_pc_i          ( wb_bju_br_pc_i      ),
    .bpu_br_tkn_i         ( if_bpu_br_tkn_i     ),
    .bpu_br_pc_i          ( if_bpu_br_pc_i      ),

    .pc_o                 ( pc                  ),
    .next_pc_o            ( next_pc             )
  );

  // inst mem request
  // stall fetch from next_pc to hold the last instruction
  assign if_mem_req_vld_o   = ~pcu_stall_pc_i;
  assign if_mem_req_wen_o   = 1'b0;
  assign if_mem_req_addr_o  = next_pc;
  assign if_mem_req_wdata_o = '0;
  
  // pc & instruction
  assign pc_o   = pc;
  assign inst_o = if_mem_rsp_rdata_i;
  
endmodule