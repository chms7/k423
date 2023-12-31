/*
 * @Design: k423_id_decode
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Decode unit of id stage
 */
`include "k423_defines.svh"

module k423_id_decode (
  // input instruction
  input  logic [`CORE_INST_W-1:0]   if_inst_i,
  // decode information
  output logic [`INST_GRP_W-1:0]    dec_grp_o,
  output logic [`INST_INFO_W-1:0]   dec_info_o,

  output logic                      dec_rs1_vld_o,
  output logic [`INST_RSDIDX_W-1:0] dec_rs1_idx_o,
  output logic                      dec_rs2_vld_o,
  output logic [`INST_RSDIDX_W-1:0] dec_rs2_idx_o,
  output logic                      dec_rd_vld_o,
  output logic [`INST_RSDIDX_W-1:0] dec_rd_idx_o,
  output logic [`CORE_XLEN-1:0]     dec_imm_o,

  output logic [`LS_SIZE_W-1:0]     dec_load_size_o,
  output logic [`LS_SIZE_W-1:0]     dec_store_size_o,
  
  output logic [`EXCP_TYPE_W-1:0]   dec_excp_type_o,
  output logic [`INT_TYPE_W-1:0]    dec_int_type_o,
  output logic [`INST_CSRADR_W-1:0] dec_csr_addr_o,
  output logic [`INST_ZIMM_W-1:0]   dec_csr_zimm_o
);
  // ---------------------------------------------------------------------------
  // Instruction Encode
  // ---------------------------------------------------------------------------
  wire [`INST_OPCODE_W-1:0] inst_opcode   = if_inst_i[6:0];
  wire [2:0]                inst_funct3   = if_inst_i[14:12];
  wire [6:0]                inst_funct7   = if_inst_i[31:25];
  wire [`INST_RSDIDX_W-1:0] inst_rd_idx   = if_inst_i[11:7];
  wire [`INST_RSDIDX_W-1:0] inst_rs1_idx  = if_inst_i[19:15];
  wire [`INST_RSDIDX_W-1:0] inst_rs2_idx  = if_inst_i[24:20];
  wire [`INST_CSRADR_W-1:0] inst_csr_addr = if_inst_i[31:20];
  
  // opcode
  wire inst_opcode_10_00  = inst_opcode[1:0] == 2'b00;
  wire inst_opcode_10_01  = inst_opcode[1:0] == 2'b01;
  wire inst_opcode_10_10  = inst_opcode[1:0] == 2'b10;
  wire inst_opcode_10_11  = inst_opcode[1:0] == 2'b11;

  wire inst_opcode_42_000 = inst_opcode[4:2] == 3'b000;
  wire inst_opcode_42_011 = inst_opcode[4:2] == 3'b011;
  wire inst_opcode_42_001 = inst_opcode[4:2] == 3'b001;
  wire inst_opcode_42_100 = inst_opcode[4:2] == 3'b100;
  wire inst_opcode_42_101 = inst_opcode[4:2] == 3'b101;

  wire inst_opcode_6_0    = inst_opcode[6] == 1'b0;
  wire inst_opcode_6_1    = inst_opcode[6] == 1'b1;
  wire inst_opcode_5_0    = inst_opcode[5] == 1'b0;
  wire inst_opcode_5_1    = inst_opcode[5] == 1'b1;
  wire inst_opcode_65_00  = inst_opcode_6_0 & inst_opcode_5_0;
  wire inst_opcode_65_01  = inst_opcode_6_0 & inst_opcode_5_1;
  wire inst_opcode_65_10  = inst_opcode_6_1 & inst_opcode_5_0;
  wire inst_opcode_65_11  = inst_opcode_6_1 & inst_opcode_5_1;

  // funct3
  wire inst_funct3_000 = inst_funct3 == 3'b000;
  wire inst_funct3_001 = inst_funct3 == 3'b001;
  wire inst_funct3_010 = inst_funct3 == 3'b010;
  wire inst_funct3_011 = inst_funct3 == 3'b011;
  wire inst_funct3_100 = inst_funct3 == 3'b100;
  wire inst_funct3_101 = inst_funct3 == 3'b101;
  wire inst_funct3_110 = inst_funct3 == 3'b110;
  wire inst_funct3_111 = inst_funct3 == 3'b111;
  
  // funct7
  wire inst_funct7_0000000 = inst_funct7 == 7'b0000000;
  wire inst_funct7_0100000 = inst_funct7 == 7'b0100000;
  wire inst_funct7_0000001 = inst_funct7 == 7'b0000001;
  wire inst_funct7_0011000 = inst_funct7 == 7'b0011000;
  
  // rv32 instruction
  wire dec_rv32 = inst_opcode_10_11;
  
  // ---------------------------------------------------------------------------
  // ALU
  // ---------------------------------------------------------------------------
  wire dec_alu_add    = inst_opcode_42_100 & inst_funct3_000 & (inst_opcode_65_00 | inst_opcode_65_01 & inst_funct7_0000000);
  wire dec_alu_sub    = inst_opcode_42_100 & inst_funct3_000 & inst_funct7_0100000 & inst_opcode_65_01;

  wire dec_alu_and    = inst_opcode_42_100 & inst_funct3_111 & (inst_opcode_65_00 | inst_opcode_65_01 & inst_funct7_0000000);
  wire dec_alu_or     = inst_opcode_42_100 & inst_funct3_110 & (inst_opcode_65_00 | inst_opcode_65_01 & inst_funct7_0000000);
  wire dec_alu_xor    = inst_opcode_42_100 & inst_funct3_100 & (inst_opcode_65_00 | inst_opcode_65_01 & inst_funct7_0000000);

  wire dec_alu_sll    = inst_opcode_42_100 & inst_funct3_001 & inst_funct7_0000000;
  wire dec_alu_srl    = inst_opcode_42_100 & inst_funct3_101 & inst_funct7_0000000;
  wire dec_alu_sra    = inst_opcode_42_100 & inst_funct3_101 & inst_funct7_0100000;

  wire dec_alu_slt    = inst_opcode_42_100 & inst_funct3_010 & (inst_opcode_65_00 | inst_opcode_65_01 & inst_funct7_0000000);
  wire dec_alu_sltu   = inst_opcode_42_100 & inst_funct3_011 & (inst_opcode_65_00 | inst_opcode_65_01 & inst_funct7_0000000);

  wire dec_alu_lui    = inst_opcode_65_01  & inst_opcode_42_101;
  wire dec_alu_auipc  = inst_opcode_65_00  & inst_opcode_42_101;

  wire dec_alu_rs2imm = inst_opcode_65_00;

  // wire                        dec_alu      = (inst_opcode_42_100 & (inst_opcode_65_00 | (inst_opcode_65_01 & ~inst_funct7_0000001))) |
  //                                             dec_alu_lui | dec_alu_auipc;
  wire                        dec_alu      = dec_alu_add | dec_alu_sub | dec_alu_and | dec_alu_or  | dec_alu_xor  |
                                             dec_alu_sll | dec_alu_srl | dec_alu_sra | dec_alu_slt | dec_alu_sltu |
                                             dec_alu_lui | dec_alu_auipc;
  wire [`INST_INFO_ALU_W-1:0] dec_alu_info = {dec_alu_rs2imm, dec_alu_auipc, dec_alu_lui,
                                              dec_alu_sltu, dec_alu_slt, dec_alu_sra, dec_alu_srl, dec_alu_sll,
                                              dec_alu_xor, dec_alu_or, dec_alu_and, dec_alu_sub, dec_alu_add};

  // ---------------------------------------------------------------------------
  // MDU
  // ---------------------------------------------------------------------------
  wire dec_mdu = inst_opcode_65_01 & inst_opcode_42_100 & inst_funct7_0000001;

  // ---------------------------------------------------------------------------
  // LSU
  // ---------------------------------------------------------------------------
  wire dec_lsu_load       = inst_opcode_65_00 & inst_opcode_42_000;
  wire dec_lsu_store      = inst_opcode_65_01 & inst_opcode_42_000;

  wire dec_lsu_size_byte  = inst_funct3_000 | inst_funct3_100;
  wire dec_lsu_size_half  = inst_funct3_001 | inst_funct3_101;
  wire dec_lsu_size_word  = inst_funct3_010;

  wire dec_lsu_unsigned   = inst_funct3[2];
  
  wire                        dec_lsu      = dec_lsu_load | dec_lsu_store;
  wire [`INST_INFO_LSU_W-1:0] dec_lsu_info = {dec_lsu_unsigned, dec_lsu_size_word, dec_lsu_size_half, dec_lsu_size_byte,
                                              dec_lsu_store, dec_lsu_load};

  // ---------------------------------------------------------------------------
  // BJU
  // ---------------------------------------------------------------------------
  wire dec_bju_bxx      = inst_opcode_65_11 & inst_opcode_42_000;
  wire dec_bju_beq      = dec_bju_bxx & inst_funct3_000;
  wire dec_bju_bne      = dec_bju_bxx & inst_funct3_001;
  wire dec_bju_blt      = dec_bju_bxx & (inst_funct3_100 | inst_funct3_110);
  wire dec_bju_bge      = dec_bju_bxx & (inst_funct3_101 | inst_funct3_111);

  wire dec_bju_jal      = inst_opcode_65_11 & inst_opcode_42_011;
  wire dec_bju_jalr     = inst_opcode_65_11 & inst_opcode_42_001 & inst_funct3_000;

  // CALL: JAL/JALR & rd is x1 or x5
  wire dec_bju_call     = (dec_bju_jal | dec_bju_jalr) &
                          ((inst_rd_idx == 5'd1) | (inst_rd_idx == 5'd5));
  // RET:  JALR & rs1 is x1 or x5 & rd is not rs1
  wire dec_bju_ret      = dec_bju_jalr & (inst_rs1_idx == 5'd1 | inst_rs1_idx == 5'd5) &
                          (inst_rd_idx != inst_rs1_idx);

  wire dec_bju_unsigned = inst_funct3[1];

  wire                        dec_bju      = dec_bju_bxx | dec_bju_jal | dec_bju_jalr;
  wire [`INST_INFO_BJU_W-1:0] dec_bju_info = {dec_bju_unsigned, dec_bju_ret, dec_bju_call, dec_bju_jalr,
                                              dec_bju_jal, dec_bju_bge, dec_bju_blt, dec_bju_bne,
                                              dec_bju_beq, dec_bju_bxx};

  // ---------------------------------------------------------------------------
  // CSR
  // ---------------------------------------------------------------------------
  wire dec_csr_csrrw  = inst_opcode_65_11 & inst_opcode_42_100 & (inst_funct3_001 | inst_funct3_101);
  wire dec_csr_csrrs  = inst_opcode_65_11 & inst_opcode_42_100 & (inst_funct3_010 | inst_funct3_110);
  wire dec_csr_csrrc  = inst_opcode_65_11 & inst_opcode_42_100 & (inst_funct3_011 | inst_funct3_111);
  wire dec_csr_zimm   = inst_funct3_101 | inst_funct3_110 | inst_funct3_111;

  // wire                        dec_csr      = (inst_opcode_65_11 & inst_opcode_42_100 & ~inst_funct3_000);
  wire                        dec_csr      = dec_csr_csrrw | dec_csr_csrrs | dec_csr_csrrc;
  wire [`INST_INFO_CSR_W-1:0] dec_csr_info = {dec_csr_zimm, dec_csr_csrrc,  dec_csr_csrrs,  dec_csr_csrrw};

  assign dec_csr_addr_o = inst_csr_addr;
  assign dec_csr_zimm_o = inst_rs1_idx;

  // ---------------------------------------------------------------------------
  // Others
  // ---------------------------------------------------------------------------
  wire dec_inst_all0       = if_inst_i == '0;
  wire dec_inst_fence      = inst_opcode_65_00 & inst_opcode_42_011;
  wire dec_inst_breakpoint = dec_rv32 & inst_opcode_65_11 & inst_opcode_42_100 & inst_funct3_000 & inst_funct7_0000001 &
                            (inst_rs1_idx == '0) & (inst_rd_idx == '0);
  wire dec_inst_ecall      = dec_rv32 & inst_opcode_65_11 & inst_opcode_42_100 & inst_funct3_000 & inst_funct7_0000000 &
                            (inst_rs1_idx == '0) & (inst_rd_idx == '0);
  wire dec_inst_mret       = inst_opcode_65_11 & inst_opcode_42_100 & inst_funct3_000 & inst_funct7_0011000 &
                            (inst_rd_idx == '0) & (inst_rs1_idx == '0) & (inst_rs2_idx == 5'b00010);

  // ---------------------------------------------------------------------------
  // Exception
  // ---------------------------------------------------------------------------
  wire dec_excp_inst_misaligned   = 1'b0;
  wire dec_excp_inst_fault        = 1'b0;
  wire dec_excp_illegal_inst      = ~(dec_alu | dec_mdu | dec_lsu | dec_bju | dec_csr | dec_inst_fence  |
                                      dec_inst_ecall | dec_inst_breakpoint | dec_inst_mret | dec_inst_all0);
  wire dec_excp_breakpoint        = dec_inst_breakpoint;
  wire dec_excp_load_misaligned   = 1'b0;
  wire dec_excp_load_fault        = 1'b0;
  wire dec_excp_store_misaligned  = 1'b0;
  wire dec_excp_store_fault       = 1'b0;
  wire dec_excp_ecall_u           = dec_inst_ecall;

  wire dec_excp_flag = dec_excp_inst_misaligned | dec_excp_inst_fault | dec_excp_illegal_inst     | dec_excp_breakpoint  |
                       dec_excp_load_misaligned | dec_excp_load_fault | dec_excp_store_misaligned | dec_excp_store_fault |
                       dec_excp_ecall_u;

  wire dec_mret      = dec_inst_mret;
  
  assign dec_excp_type_o = {dec_mret, dec_excp_ecall_u, dec_excp_store_fault, dec_excp_store_misaligned,
                            dec_excp_load_fault, dec_excp_load_misaligned, dec_excp_breakpoint,
                            dec_excp_illegal_inst, dec_excp_inst_fault, dec_excp_inst_misaligned, dec_excp_flag};

  // ---------------------------------------------------------------------------
  // Interrupt
  // ---------------------------------------------------------------------------
  wire dec_int_flag = 1'b0;
  
  assign dec_int_type_o = dec_int_flag;
  
  // ---------------------------------------------------------------------------
  // Instruction Group & Information
  // ---------------------------------------------------------------------------
  assign dec_grp_o[`INST_GRP_ALU]  = dec_rv32 & dec_alu;
  assign dec_grp_o[`INST_GRP_MDU]  = dec_rv32 & dec_mdu;
  assign dec_grp_o[`INST_GRP_LSU]  = dec_rv32 & dec_lsu;
  assign dec_grp_o[`INST_GRP_BJU]  = dec_rv32 & dec_bju;
  assign dec_grp_o[`INST_GRP_CSR]  = dec_rv32 & dec_csr;
  assign dec_info_o = {`INST_INFO_W{dec_alu}} & {{(`INST_INFO_W-`INST_INFO_ALU_W){1'b0}}, dec_alu_info} |
                      {`INST_INFO_W{dec_lsu}} & {{(`INST_INFO_W-`INST_INFO_LSU_W){1'b0}}, dec_lsu_info} |
                      {`INST_INFO_W{dec_bju}} & {{(`INST_INFO_W-`INST_INFO_BJU_W){1'b0}}, dec_bju_info} |
                      {`INST_INFO_W{dec_csr}} & {{(`INST_INFO_W-`INST_INFO_CSR_W){1'b0}}, dec_csr_info} ;


  // ---------------------------------------------------------------------------
  // Instruction Operands & Immediate
  // ---------------------------------------------------------------------------
  // rs & rd
  assign dec_rs1_vld_o = inst_opcode_65_00 & (inst_opcode_42_000 | inst_opcode_42_100) |
                         inst_opcode_65_01 & (inst_opcode_42_000 | inst_opcode_42_100) |
                         inst_opcode_65_11 & (inst_opcode_42_001 | inst_opcode_42_100  | inst_opcode_42_000) ;
  assign dec_rs2_vld_o = inst_opcode_65_01 & (inst_opcode_42_000 | inst_opcode_42_100) |
                         // inst_opcode_65_01 & (inst_opcode_42_011 & (inst_funct7[6:2] != 5'b00010)) | // for rva
                         inst_opcode_65_11 &  inst_opcode_42_000;
  assign dec_rd_vld_o  = dec_alu     | dec_mdu      | dec_lsu_load |
                         dec_bju_jal | dec_bju_jalr | dec_csr;

  assign dec_rs1_idx_o = inst_rs1_idx;
  assign dec_rs2_idx_o = inst_rs2_idx;
  assign dec_rd_idx_o  = inst_rd_idx;

  assign dec_store_size_o = (dec_lsu_store & dec_lsu_size_byte) ? `LS_SIZE_BYTE :
                            (dec_lsu_store & dec_lsu_size_half) ? `LS_SIZE_HALF :
                                                                  `LS_SIZE_WORD ;
  assign dec_load_size_o  = (dec_lsu_load  & dec_lsu_size_byte) ? `LS_SIZE_BYTE :
                            (dec_lsu_load  & dec_lsu_size_half) ? `LS_SIZE_HALF :
                                                                  `LS_SIZE_WORD ;
  
  // immediate
  wire [`CORE_XLEN-1:0] inst_immi = {{20{if_inst_i[31]}}, if_inst_i[31:20]};
  wire [`CORE_XLEN-1:0] inst_imms = {{20{if_inst_i[31]}}, if_inst_i[31:25], if_inst_i[11:7]};
  wire [`CORE_XLEN-1:0] inst_immb = {{20{if_inst_i[31]}}, if_inst_i[7], if_inst_i[30:25], if_inst_i[11:8], 1'b0};
  wire [`CORE_XLEN-1:0] inst_immu = {if_inst_i[31:12], 12'b0};
  wire [`CORE_XLEN-1:0] inst_immj = {{12{if_inst_i[31]}}, if_inst_i[19:12], if_inst_i[20], if_inst_i[30:21], 1'b0};
  
  wire dec_sel_immi = dec_alu & ~(dec_alu_lui | dec_alu_auipc) | dec_lsu_load | dec_bju_jalr;
  wire dec_sel_imms = dec_lsu_store;
  wire dec_sel_immb = dec_bju_bxx;
  wire dec_sel_immu = dec_alu_lui | dec_alu_auipc;
  wire dec_sel_immj = dec_bju_jal;

  assign dec_imm_o = {`CORE_XLEN{dec_sel_immi}} & inst_immi |
                     {`CORE_XLEN{dec_sel_imms}} & inst_imms |
                     {`CORE_XLEN{dec_sel_immb}} & inst_immb |
                     {`CORE_XLEN{dec_sel_immu}} & inst_immu |
                     {`CORE_XLEN{dec_sel_immj}} & inst_immj ;
  
  

endmodule