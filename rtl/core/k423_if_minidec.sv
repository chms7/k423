/*
 * @Design: k423_if_minidec
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-12-10
 * @Description: Mini-decode unit for bpu
 */
`include "k423_defines.svh"

module k423_if_minidec (
  // instruction
  input  logic [`CORE_DATA_W-1:0] inst_i,
  // decode
  output logic                    dec_br_o,
  output logic                    dec_bxx_o,
  output logic                    dec_jal_o,
  output logic                    dec_jalr_o,
  output logic                    dec_call_o,
  output logic                    dec_ret_o,
  output logic [`CORE_XLEN-1:0]   dec_imm_o
);
  // ---------------------------------------------------------------------------
  // Instruction Encode
  // ---------------------------------------------------------------------------
  wire [`INST_OPCODE_W-1:0] inst_opcode  = inst_i[6:0];
  wire [`INST_RSDIDX_W-1:0] inst_rd_idx  = inst_i[11:7];
  wire [`INST_RSDIDX_W-1:0] inst_rs1_idx = inst_i[19:15];
  wire [`INST_RSDIDX_W-1:0] inst_rs2_idx = inst_i[24:20];
  wire [`CORE_XLEN-1:0]     inst_immb    = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
  wire [`CORE_XLEN-1:0]     inst_immj    = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};

  // ---------------------------------------------------------------------------
  // Instruction Decode
  // ---------------------------------------------------------------------------
  wire   dec_rv32   = inst_opcode[1:0] == 2'b11;

  // BXX/JAL/JALR
  assign dec_br_o   = dec_bxx_o | dec_jal_o | dec_jalr_o;
  assign dec_bxx_o  = (inst_opcode[6:2] == 5'b11000) & dec_rv32;
  assign dec_jal_o  = (inst_opcode[6:2] == 5'b11011) & dec_rv32;
  assign dec_jalr_o = (inst_opcode[6:2] == 5'b11001) & dec_rv32;
  
  // CALL: JAL/JALR & rd is x1 or x5
  assign dec_call_o = (dec_jal_o | dec_jalr_o) &
                      ((inst_rd_idx == 5'd1) | (inst_rd_idx == 5'd5));
  // RET:  JALR & rs1 is x1 or x5 & rd is not rs1
  assign dec_ret_o  = dec_jalr_o &
                      (inst_rs1_idx == 5'd1 | inst_rs1_idx == 5'd5) &
                      (inst_rd_idx != inst_rs1_idx);

  // immediate
  assign dec_imm_o = inst_i[3] ? inst_immj : inst_immb;

endmodule
