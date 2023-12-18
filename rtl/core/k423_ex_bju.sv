/*
 * @Design: k423_ex_bju
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: BJU of ex stage
 */
`include "k423_defines.svh"

module k423_ex_bju (
  input                             clk_i,
  input                             rst_n_i,
  // id stage
  input  logic [`CORE_ADDR_W-1:0]   pc_i,
  input  logic [`INST_GRP_W-1:0]    dec_grp_i,
  input  logic [`INST_INFO_W-1:0]   dec_info_i,
  input  logic [`CORE_XLEN-1:0]     dec_rs1_i,
  input  logic [`CORE_XLEN-1:0]     dec_rs2_i,
  input  logic [`CORE_XLEN-1:0]     dec_imm_i,

  input  logic                      bpu_prd_tkn_i,
  input  logic [`CORE_ADDR_W-1:0]   bpu_prd_pc_i,
  input  logic [1:0]                bpu_prd_sat_cnt_i,
  // bju
  output logic                      bju_upd_vld_o,
  output logic                      bju_upd_mis_o,
  output logic                      bju_upd_tkn_o,
  output logic [`BR_TYPE_W-1:0]     bju_upd_type_o,
  output logic [`CORE_XLEN-1:0]     bju_upd_src_pc_o,
  output logic [`CORE_XLEN-1:0]     bju_upd_tgt_pc_o,
  output logic [1:0]                bju_upd_sat_cnt_o,

  output logic                      bju_jal_rd_tkn_o,
  output logic [`CORE_XLEN-1:0]     bju_jal_rd_o
);
  // ---------------------------------------------------------------------------
  // Adder1: BXX  ( cmp = rs1 - rs2 )
  //         JAL  ( pc  = pc  + imm )
  //         JALR ( pc  = rs1 + imm )
  // ---------------------------------------------------------------------------
  wire                  adder_cmp_sub = dec_info_i[`INST_INFO_BJU_BXX];
  wire [`CORE_XLEN-1:0] adder_cmp_op1 = dec_info_i[`INST_INFO_BJU_JAL] ? pc_i       : dec_rs1_i;
  wire [`CORE_XLEN-1:0] adder_cmp_op2 = dec_info_i[`INST_INFO_BJU_BXX] ? ~dec_rs2_i : dec_imm_i;
  wire [`CORE_XLEN-1:0] adder_cmp_res;
  wire                  adder_cmp_cout;

  utils_adder32  u_adder_bju_cmp (
    .a    ( adder_cmp_op1 ),
    .b    ( adder_cmp_op2  ),
    .cin  ( adder_cmp_sub  ),
    .sum  ( adder_cmp_res  ),
    .cout ( adder_cmp_cout )
  );

  // ---------------------------------------------------------------------------
  // Adder2: BXX ( pc = pc + imm )
  //         JXX ( rd = pc + 4   )
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] adder_rd_op1 = pc_i;
  wire [`CORE_XLEN-1:0] adder_rd_op2 = dec_info_i[`INST_INFO_BJU_BXX] ? dec_imm_i : 32'd4;
  wire [`CORE_XLEN-1:0] adder_rd_res;

  utils_adder32  u_adder_bju_rd (
    .a    ( adder_rd_op1 ),
    .b    ( adder_rd_op2 ),
    .cin  ( 1'b0         ),
    .sum  ( adder_rd_res ),
    .cout (              )
  );

  // ---------------------------------------------------------------------------
  // Adder3: Branch prediction miss
  //         pc = pc + 4
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] adder_mis_res;
  
`ifdef BPU_EN

  utils_adder32  u_adder_bju_mis (
    .a    ( pc_i          ),
    .b    ( 32'd4         ),
    .cin  ( 1'b0          ),
    .sum  ( adder_mis_res ),
    .cout (               )
  );
  
`else

  assign adder_mis_res = '0;

`endif
  
  // ---------------------------------------------------------------------------
  // Branch
  // ---------------------------------------------------------------------------
  // bxx compare
  wire cmp_rs1smaller = ( (dec_info_i[`INST_INFO_BJU_UNSIGNED] | (dec_rs1_i[`CORE_XLEN-1] == dec_rs2_i[`CORE_XLEN-1])) & ~adder_cmp_cout) |
                        (~dec_info_i[`INST_INFO_BJU_UNSIGNED] & ((dec_rs1_i[`CORE_XLEN-1] & ~dec_rs2_i[`CORE_XLEN-1])));
  wire cmp_rs2smaller = ( (dec_info_i[`INST_INFO_BJU_UNSIGNED] | (dec_rs1_i[`CORE_XLEN-1] == dec_rs2_i[`CORE_XLEN-1])) &  adder_cmp_cout) |
                        (~dec_info_i[`INST_INFO_BJU_UNSIGNED] & ((~dec_rs1_i[`CORE_XLEN-1] & dec_rs2_i[`CORE_XLEN-1])));
  wire cmp_rs1eqop2   =  ~(|adder_cmp_res);

  // branch taken
  wire br_bxx_tkn =  dec_info_i[`INST_INFO_BJU_BEQ] &  cmp_rs1eqop2   |
                     dec_info_i[`INST_INFO_BJU_BNE] & ~cmp_rs1eqop2   |
                     dec_info_i[`INST_INFO_BJU_BLT] &  cmp_rs1smaller |
                     dec_info_i[`INST_INFO_BJU_BGE] & (cmp_rs2smaller | cmp_rs1eqop2);
  wire bju_br_tkn = (dec_info_i[`INST_INFO_BJU_BXX] & br_bxx_tkn |
                     dec_info_i[`INST_INFO_BJU_JAL]              |
                     dec_info_i[`INST_INFO_BJU_JALR]);
  // branch type
  wire [`BR_TYPE_W-1:0]   bju_br_type = {dec_info_i[`INST_INFO_BJU_RET], dec_info_i[`INST_INFO_BJU_CALL]};
  // branch pc
  wire [`CORE_ADDR_W-1:0] bju_br_pc   = dec_info_i[`INST_INFO_BJU_BXX] ? adder_rd_res : (adder_cmp_res & ~32'd1);
  wire [`CORE_ADDR_W-1:0] bju_mis_pc  = adder_mis_res;
  
`ifdef BPU_EN

  // update
  always @(*) begin
    bju_upd_sat_cnt_o = bpu_prd_sat_cnt_i;

    if (bpu_prd_sat_cnt_i == `PHT_NTKN_STRONG) begin
      if (bju_br_tkn) begin
        bju_upd_sat_cnt_o = `PHT_NTKN_WEAK;
      end else begin
        bju_upd_sat_cnt_o = `PHT_NTKN_STRONG;
      end
    end else if (bpu_prd_sat_cnt_i == `PHT_NTKN_WEAK) begin
      if (bju_br_tkn) begin
        bju_upd_sat_cnt_o = `PHT_TKN_WEAK;
      end else begin
        bju_upd_sat_cnt_o = `PHT_NTKN_WEAK;
      end
    end else if (bpu_prd_sat_cnt_i == `PHT_TKN_WEAK) begin
      if (bju_br_tkn) begin
        bju_upd_sat_cnt_o = `PHT_TKN_STRONG;
      end else begin
        bju_upd_sat_cnt_o = `PHT_NTKN_WEAK;
      end
    end else if (bpu_prd_sat_cnt_i == `PHT_TKN_STRONG) begin
      if (bju_br_tkn) begin
        bju_upd_sat_cnt_o = `PHT_TKN_WEAK;
      end else begin
        bju_upd_sat_cnt_o = `PHT_TKN_STRONG;
      end
    end
  end
  
`else

  assign bju_upd_sat_cnt_o = '0;

`endif

  assign bju_upd_vld_o    = dec_grp_i[`INST_GRP_BJU];
  assign bju_upd_mis_o    = dec_grp_i[`INST_GRP_BJU] & ((bju_br_tkn != bpu_prd_tkn_i) | (bju_br_tkn & (bju_br_pc != bpu_prd_pc_i)));
  assign bju_upd_tkn_o    = bju_br_tkn;
  assign bju_upd_type_o   = bju_br_type;
  assign bju_upd_tgt_pc_o = bju_br_tkn ? bju_br_pc : bju_mis_pc;
  assign bju_upd_src_pc_o = pc_i;
  
  assign bju_jal_rd_tkn_o = dec_grp_i[`INST_GRP_BJU] & (dec_info_i[`INST_INFO_BJU_JAL] | dec_info_i[`INST_INFO_BJU_JALR]);
  assign bju_jal_rd_o     = adder_rd_res;
  
endmodule
