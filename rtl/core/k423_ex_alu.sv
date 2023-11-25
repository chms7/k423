/*
 * @Design: k423_ex_alu
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: ALU of ex stage
 */
`include "k423_defines.svh"

module k423_ex_alu (
  input                             clk_i,
  input                             rst_n_i,
  // id stage
  input  logic [`CORE_ADDR_W-1:0]   pc_i,
  input  logic [`INST_GRP_W-1:0]    dec_grp_i,
  input  logic [`INST_INFO_W-1:0]   dec_info_i,
  input  logic [`INST_RSDIDX_W-1:0] dec_rs1_idx_i,
  input  logic [`INST_RSDIDX_W-1:0] dec_rs2_idx_i,
  input  logic [`CORE_XLEN-1:0]     dec_rs1_i,
  input  logic [`CORE_XLEN-1:0]     dec_rs2_i,
  input  logic [`CORE_XLEN-1:0]     dec_imm_i,
  // alu
  output logic [`CORE_XLEN-1:0]     alu_rd_o
);
  // ---------------------------------------------------------------------------
  // Adder
  // ---------------------------------------------------------------------------
  // when need to subtract, invert the second operand and set cin to 1
  wire alu_adder_sub = dec_info_i[`INST_INFO_ALU_SUB] | dec_info_i[`INST_INFO_ALU_SLT] | dec_info_i[`INST_INFO_ALU_SLTU];
  wire [`CORE_XLEN-1:0] alu_adder_op1 = dec_info_i[`INST_INFO_ALU_AUIPC]  ? pc_i       : dec_rs1_i;
  wire [`CORE_XLEN-1:0] alu_adder_op2 = dec_info_i[`INST_INFO_ALU_RS2IMM] ? (alu_adder_sub ? ~dec_imm_i : dec_imm_i) :
                                                                            (alu_adder_sub ? ~dec_rs2_i : dec_rs2_i);
  wire [`CORE_XLEN-1:0] alu_adder_res;
  wire                  alu_adder_cout;

  utils_adder32  u_adder_alu (
    .a    ( alu_adder_op1  ),
    .b    ( alu_adder_op2  ),
    .cin  ( alu_adder_sub  ),
    .sum  ( alu_adder_res  ),
    .cout ( alu_adder_cout )
  );

  // ---------------------------------------------------------------------------
  // ADD & SUB
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] alu_add_res = alu_adder_res;
  wire [`CORE_XLEN-1:0] alu_sub_res = alu_adder_res;
  
  // ---------------------------------------------------------------------------
  // Compare
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] slt_op1 = alu_adder_op1;
  wire [`CORE_XLEN-1:0] slt_op2 = dec_info_i[`INST_INFO_ALU_RS2IMM] ? dec_imm_i : dec_rs2_i;
  wire slt_rs1smaller = ((dec_info_i[`INST_INFO_ALU_SLTU] | (  slt_op1[`CORE_XLEN-1] == slt_op2[`CORE_XLEN-1])) & ~alu_adder_cout) |
                        (~dec_info_i[`INST_INFO_ALU_SLTU] & (( slt_op1[`CORE_XLEN-1] & ~slt_op2[`CORE_XLEN-1])));
  wire slt_rs2smaller = ((dec_info_i[`INST_INFO_ALU_SLTU] | (  slt_op1[`CORE_XLEN-1] == slt_op2[`CORE_XLEN-1])) &  alu_adder_cout) |
                        (~dec_info_i[`INST_INFO_ALU_SLTU] & ((~slt_op1[`CORE_XLEN-1] &  slt_op2[`CORE_XLEN-1])));
  wire slt_rs1eqop2   =  ~(|alu_adder_res);
  wire [`CORE_XLEN-1:0] alu_slt_res = slt_rs1smaller ? {{`CORE_XLEN-1{1'b0}}, 1'b1} : '0;
  
  // ---------------------------------------------------------------------------
  // Logic Operation
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] alu_and_res = alu_adder_op1 & alu_adder_op2;
  wire [`CORE_XLEN-1:0] alu_or_res  = alu_adder_op1 | alu_adder_op2;
  wire [`CORE_XLEN-1:0] alu_xor_res = alu_adder_op1 ^ alu_adder_op2;
  
  // ---------------------------------------------------------------------------
  // Shift
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] shift_src = dec_info_i[`INST_INFO_ALU_SLL] ? 
                                   {dec_rs1_i[0],  dec_rs1_i[1],  dec_rs1_i[2],  dec_rs1_i[3],
                                    dec_rs1_i[4],  dec_rs1_i[5],  dec_rs1_i[6],  dec_rs1_i[7],
                                    dec_rs1_i[8],  dec_rs1_i[9],  dec_rs1_i[10], dec_rs1_i[11],
                                    dec_rs1_i[12], dec_rs1_i[13], dec_rs1_i[14], dec_rs1_i[15],
                                    dec_rs1_i[16], dec_rs1_i[17], dec_rs1_i[18], dec_rs1_i[19],
                                    dec_rs1_i[20], dec_rs1_i[21], dec_rs1_i[22], dec_rs1_i[23],
                                    dec_rs1_i[24], dec_rs1_i[25], dec_rs1_i[26], dec_rs1_i[27],
                                    dec_rs1_i[28], dec_rs1_i[29], dec_rs1_i[30], dec_rs1_i[31]} :
                                    dec_rs1_i;
  wire [4:0]            shift_amount = dec_info_i[`INST_INFO_ALU_RS2IMM] ? dec_rs2_idx_i : dec_rs2_i[4:0];

  // wire [`CORE_XLEN-1:0] shift_res = shift_src >> shift_amount;
  wire [`CORE_XLEN-1:0] shift_res;
  utils_shifter #(
    .SHIFT_MODE     ( 1            ), // right shift
    .DATA_WIDTH     ( 32           ),
    .SHAMT_WIDTH    ( 5            )
  ) u_shifter_alu (
    .shift_src_i    ( shift_src    ),
    .shift_amount_i ( shift_amount ),
    .shift_res_o    ( shift_res    )
  );

  wire [`CORE_XLEN-1:0] alu_sll_res = {shift_res[0],  shift_res[1],  shift_res[2],  shift_res[3],
                                       shift_res[4],  shift_res[5],  shift_res[6],  shift_res[7],
                                       shift_res[8],  shift_res[9],  shift_res[10], shift_res[11],
                                       shift_res[12], shift_res[13], shift_res[14], shift_res[15],
                                       shift_res[16], shift_res[17], shift_res[18], shift_res[19],
                                       shift_res[20], shift_res[21], shift_res[22], shift_res[23],
                                       shift_res[24], shift_res[25], shift_res[26], shift_res[27],
                                       shift_res[28], shift_res[29], shift_res[30], shift_res[31]};
  wire [`CORE_XLEN-1:0] alu_srl_res = shift_res;
  wire [`CORE_XLEN-1:0] alu_sra_mask = ~({`CORE_XLEN{1'b1}} >> shift_amount);
  wire [`CORE_XLEN-1:0] alu_sra_res = ({`CORE_XLEN{dec_rs1_i[31]}} & alu_sra_mask) | alu_srl_res;

  // ---------------------------------------------------------------------------
  // LUI
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] alu_lui_res = dec_imm_i;

  // ---------------------------------------------------------------------------
  // AUIPC
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] alu_auipc_res = alu_adder_res;
  
  // ---------------------------------------------------------------------------
  // Result Select
  // ---------------------------------------------------------------------------
  assign alu_rd_o = {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_ADD  ]}} & alu_add_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_SUB  ]}} & alu_sub_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_SLT  ]}} & alu_slt_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_SLTU ]}} & alu_slt_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_AND  ]}} & alu_and_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_OR   ]}} & alu_or_res   |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_XOR  ]}} & alu_xor_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_SLL  ]}} & alu_sll_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_SRL  ]}} & alu_srl_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_SRA  ]}} & alu_sra_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_LUI  ]}} & alu_lui_res  |
                    {`CORE_XLEN{dec_info_i[`INST_INFO_ALU_AUIPC]}} & alu_auipc_res;
endmodule
