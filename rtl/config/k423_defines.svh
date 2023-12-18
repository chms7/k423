/*
 * @Design: k423_defines
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Defines of k423
 */

`include "k423_config.svh"

// ---------------------------------------------------------------------------
// Core Width
// ---------------------------------------------------------------------------
`define CORE_XLEN                   32
`define CORE_ADDR_W                 `CORE_XLEN
`define CORE_INST_W                 `CORE_XLEN
`define CORE_DATA_W                 `CORE_XLEN
`define CORE_FETCH_W                `CORE_INST_W

// ---------------------------------------------------------------------------
// Decode Information
// ---------------------------------------------------------------------------
// Inst Encode
`define INST_OPCODE_W               7
`define INST_RSDIDX_W               5
`define INST_CSRADR_W               12
`define INST_ZIMM_W                 5

// Load/Store Information
`define LS_SIZE_W                   2
`define LS_SIZE_WORD                2'd0
`define LS_SIZE_HALF                2'd1
`define LS_SIZE_BYTE                2'd2

// Inst Group
`define INST_GRP_W                  5
`define INST_GRP_ALU                0
`define INST_GRP_MDU                1
`define INST_GRP_LSU                2
`define INST_GRP_BJU                3
`define INST_GRP_CSR                4

// Inst Information
`define INST_INFO_W                 13 

`define INST_INFO_ALU_W             13
`define INST_INFO_ALU_ADD           0
`define INST_INFO_ALU_SUB           1
`define INST_INFO_ALU_AND           2
`define INST_INFO_ALU_OR            3
`define INST_INFO_ALU_XOR           4
`define INST_INFO_ALU_SLL           5
`define INST_INFO_ALU_SRL           6
`define INST_INFO_ALU_SRA           7
`define INST_INFO_ALU_SLT           8
`define INST_INFO_ALU_SLTU          9
`define INST_INFO_ALU_LUI           10
`define INST_INFO_ALU_AUIPC         11
`define INST_INFO_ALU_RS2IMM        12

`define INST_INFO_LSU_W             6
`define INST_INFO_LSU_LOAD          0
`define INST_INFO_LSU_STORE         1
`define INST_INFO_LSU_SIZE_BYTE     2
`define INST_INFO_LSU_SIZE_HALF     3
`define INST_INFO_LSU_SIZE_WORD     4
`define INST_INFO_LSU_UNSIGNED      5

`define INST_INFO_BJU_W             10
`define INST_INFO_BJU_BXX           0
`define INST_INFO_BJU_BEQ           1
`define INST_INFO_BJU_BNE           2
`define INST_INFO_BJU_BLT           3
`define INST_INFO_BJU_BGE           4
`define INST_INFO_BJU_JAL           5
`define INST_INFO_BJU_JALR          6
`define INST_INFO_BJU_CALL          7
`define INST_INFO_BJU_RET           8
`define INST_INFO_BJU_UNSIGNED      9

`define INST_INFO_CSR_W             4
`define INST_INFO_CSR_CSRRW         0
`define INST_INFO_CSR_CSRRS         1
`define INST_INFO_CSR_CSRRC         2
`define INST_INFO_CSR_ZIMM          3

// ---------------------------------------------------------------------------
// Exception
// ---------------------------------------------------------------------------
`define EXCP_TYPE_W                 11

`define EXCP_FLAG                   0
`define EXCP_TYPE_INST_MISALIGNED   1
`define EXCP_TYPE_INST_FAULT        2
`define EXCP_TYPE_ILLEGAL_INST      3
`define EXCP_TYPE_BREAKPOINT        4
`define EXCP_TYPE_LOAD_MISALIGNED   5
`define EXCP_TYPE_LOAD_FAULT        6
`define EXCP_TYPE_STORE_MISALIGNED  7
`define EXCP_TYPE_STORE_FAULT       8
`define EXCP_TYPE_ECALL_U           9
`define EXCP_MRET                   10

`define EXCP_CODE_ILLEAGAL_INST     31'd2
`define EXCP_CODE_BREAKPOINT        31'd3
`define EXCP_CODE_ECALL_U           31'd8

// ---------------------------------------------------------------------------
// Interrupt
// ---------------------------------------------------------------------------
`define INT_TYPE_W                  1

`define INT_FLAG                    0
`define INT_TYPE_S_SOFT             1
`define INT_TYPE_M_SOFT             2
`define INT_TYPE_S_TIMER            3
`define INT_TYPE_M_TIMER            4
`define INT_TYPE_S_EXT              5
`define INT_TYPE_M_EXT              6

`define INT_CODE_S_SOFT             1
`define INT_CODE_M_SOFT             3
`define INT_CODE_S_TIMER            5
`define INT_CODE_M_TIMER            7
`define INT_CODE_S_EXT              9
`define INT_CODE_M_EXT              11

// ---------------------------------------------------------------------------
// Branch Prediction
// ---------------------------------------------------------------------------
// PHT
`define PHT_NTKN_STRONG             2'b00
`define PHT_NTKN_WEAK               2'b01
`define PHT_TKN_WEAK                2'b11
`define PHT_TKN_STRONG              2'b10

// BTB
`define BTB_VLD_W                   1
`define BTB_TAG_W                   4
`define BTB_BTA_W                   32
`define BTB_WIDTH                   `BTB_VLD_W+`BTB_TAG_W+`BTB_BTA_W

`define BTB_VLD_BITS                `BTB_VLD_W-1:0
`define BTB_TAG_BITS                `BTB_TAG_W+`BTB_VLD_W-1:`BTB_VLD_W
`define BTB_BTA_BITS                `BTB_BTA_W+`BTB_TAG_W+`BTB_VLD_W-1:`BTB_TAG_W+`BTB_VLD_W

// RAS
`define BR_TYPE_W                   2
`define BR_TYPE_CALL                0
`define BR_TYPE_RET                 1
