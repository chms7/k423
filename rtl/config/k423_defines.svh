/*
 * @Design: k423_defines
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Defines of k423
 */

`include "k423_config.svh"

// Core
`define CORE_XLEN     32
`define CORE_ADDR_W   `CORE_XLEN
`define CORE_INST_W   `CORE_XLEN
`define CORE_DATA_W   `CORE_XLEN
`define CORE_FETCH_W  `CORE_INST_W

// Inst Encode
`define INST_OPCODE_W 7
`define INST_RSDIDX_W 5

// Rs/Rd Infomration
`define RSD_SIZE_W    2
`define RSD_SIZE_WORD 2'd0
`define RSD_SIZE_HALF 2'd1
`define RSD_SIZE_BYTE 2'd2

// Inst Group
`define INST_GRP_W    5
`define INST_GRP_ALU  0
`define INST_GRP_MDU  1
`define INST_GRP_LSU  2
`define INST_GRP_BJU  3
`define INST_GRP_CSR  4

// Inst Information
`define INST_INFO_W  13 

`define INST_INFO_ALU_W       13
`define INST_INFO_ALU_ADD     0
`define INST_INFO_ALU_SUB     1
`define INST_INFO_ALU_AND     2
`define INST_INFO_ALU_OR      3
`define INST_INFO_ALU_XOR     4
`define INST_INFO_ALU_SLL     5
`define INST_INFO_ALU_SRL     6
`define INST_INFO_ALU_SRA     7
`define INST_INFO_ALU_SLT     8
`define INST_INFO_ALU_SLTU    9
`define INST_INFO_ALU_LUI     10
`define INST_INFO_ALU_AUIPC   11
`define INST_INFO_ALU_RS2IMM  12

`define INST_INFO_LSU_W           6
`define INST_INFO_LSU_LOAD        0
`define INST_INFO_LSU_STORE       1
`define INST_INFO_LSU_SIZE_BYTE   2
`define INST_INFO_LSU_SIZE_HALF   3
`define INST_INFO_LSU_SIZE_WORD   4
`define INST_INFO_LSU_UNSIGNED    5

`define INST_INFO_BJU_W        8
`define INST_INFO_BJU_BXX      0
`define INST_INFO_BJU_BEQ      1
`define INST_INFO_BJU_BNE      2
`define INST_INFO_BJU_BLT      3
`define INST_INFO_BJU_BGE      4
`define INST_INFO_BJU_JAL      5
`define INST_INFO_BJU_JALR     6
`define INST_INFO_BJU_UNSIGNED 7
