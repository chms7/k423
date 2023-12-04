/*
 * @Design: k423_id_regfile
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Regfile of id stage
 */
`include "k423_defines.svh"

module k423_id_regfile (
  input                             clk_i,
  input                             rst_n_i,
  // forward
  input  logic                      ex_fwd_rd_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] ex_fwd_rd_idx_i,
  input  logic [`CORE_XLEN-1:0]     ex_fwd_rd_data_i,
  input  logic                      wb_fwd_rd_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] wb_fwd_rd_idx_i,
  input  logic [`CORE_XLEN-1:0]     wb_fwd_rd_data_i,
  // write
  input  logic                      wb_rd_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] wb_rd_idx_i,
  input  logic [`CORE_XLEN-1:0]     wb_rd_data_i,
  // read
  input  logic                      id_rs1_vld_i,
  input  logic [`INST_RSDIDX_W-1:0] id_rs1_idx_i,
  input  logic                      id_rs2_vld_i,
  input  logic [`RSD_SIZE_W-1:0]    id_store_size_i,
  input  logic [`INST_RSDIDX_W-1:0] id_rs2_idx_i,
  output logic [`CORE_XLEN-1:0]     id_rs1_data_o,
  output logic [`CORE_XLEN-1:0]     id_rs2_data_o
);
  // regfile x0 - x31
  logic [`CORE_XLEN-1:0] regfile [31:0];
  
  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------
  integer reg_idx;
  always @(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
      for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1)
        regfile[reg_idx ]    <= '0;
    end else if (wb_rd_vld_i && (wb_rd_idx_i != {`INST_RSDIDX_W{1'b0}})) begin
        regfile[wb_rd_idx_i] <= wb_rd_data_i;
    end
  end

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------
  // read from regfile
  // regfile data
  wire [`CORE_XLEN-1:0] regfile_rs1_w = regfile[id_rs1_idx_i];
  wire [`CORE_XLEN-1:0] regfile_rs2_w = regfile[id_rs2_idx_i];
  // sign extend regfile data when store
  wire [`CORE_XLEN-1:0] rs1_reg_data_w = regfile_rs1_w;
  wire [`CORE_XLEN-1:0] rs2_reg_data_w =
                          {`CORE_XLEN{id_rs2_vld_i & (id_store_size_i == `RSD_SIZE_BYTE)}} & {{24{regfile_rs2_w[7]}},  regfile_rs2_w[7:0]} |
                          {`CORE_XLEN{id_rs2_vld_i & (id_store_size_i == `RSD_SIZE_HALF)}} & {{16{regfile_rs2_w[15]}}, regfile_rs2_w[15:0]} |
                          {`CORE_XLEN{id_rs2_vld_i & (id_store_size_i == `RSD_SIZE_WORD)}} & regfile_rs2_w;

  // read from forward
  // forward taken
  wire rs1_ex_fwd_tkn_w  = id_rs1_vld_i & ex_fwd_rd_vld_i  &
                          (id_rs1_idx_i == ex_fwd_rd_idx_i)  & (id_rs1_idx_i  != '0);
  wire rs1_wb_fwd_tkn_w  = id_rs1_vld_i & wb_fwd_rd_vld_i  &
                          (id_rs1_idx_i == wb_fwd_rd_idx_i)  & (id_rs1_idx_i  != '0);

  wire rs2_ex_fwd_tkn_w  = id_rs2_vld_i & ex_fwd_rd_vld_i  &
                          (id_rs2_idx_i == ex_fwd_rd_idx_i)  & (id_rs2_idx_i  != '0);
  wire rs2_wb_fwd_tkn_w  = id_rs2_vld_i & wb_fwd_rd_vld_i  &
                          (id_rs2_idx_i == wb_fwd_rd_idx_i)  & (id_rs2_idx_i  != '0);
  // sign extend forward data when store
  wire [`CORE_XLEN-1:0] rs1_ex_fwd_data_w  = ex_fwd_rd_data_i;
  wire [`CORE_XLEN-1:0] rs1_wb_fwd_data_w  = wb_fwd_rd_data_i;

  wire [`CORE_XLEN-1:0] rs2_ex_fwd_data_w  =
                          {`CORE_XLEN{id_store_size_i == `RSD_SIZE_BYTE}} & {{24{ex_fwd_rd_data_i[7]}},  ex_fwd_rd_data_i[7:0]}  |
                          {`CORE_XLEN{id_store_size_i == `RSD_SIZE_HALF}} & {{16{ex_fwd_rd_data_i[15]}}, ex_fwd_rd_data_i[15:0]} |
                          {`CORE_XLEN{id_store_size_i == `RSD_SIZE_WORD}} & ex_fwd_rd_data_i;
  wire [`CORE_XLEN-1:0] rs2_wb_fwd_data_w  =
                          {`CORE_XLEN{id_store_size_i == `RSD_SIZE_BYTE}} & {{24{wb_fwd_rd_data_i[7]}},  wb_fwd_rd_data_i[7:0]}  |
                          {`CORE_XLEN{id_store_size_i == `RSD_SIZE_HALF}} & {{16{wb_fwd_rd_data_i[15]}}, wb_fwd_rd_data_i[15:0]} |
                          {`CORE_XLEN{id_store_size_i == `RSD_SIZE_WORD}} & wb_fwd_rd_data_i;

  // priority: ex > wb
  assign id_rs1_data_o = rs1_ex_fwd_tkn_w  ? rs1_ex_fwd_data_w  :
                         rs1_wb_fwd_tkn_w  ? rs1_wb_fwd_data_w  :
                                             rs1_reg_data_w     ;
  assign id_rs2_data_o = rs2_ex_fwd_tkn_w  ? rs2_ex_fwd_data_w  :
                         rs2_wb_fwd_tkn_w  ? rs2_wb_fwd_data_w  :
                                             rs2_reg_data_w     ;

  // ---------------------------------------------------------------------------
  // Abbreviation
  // ---------------------------------------------------------------------------
  wire [`CORE_XLEN-1:0] regfile_zero = regfile[0];
  wire [`CORE_XLEN-1:0] regfile_ra   = regfile[1];
  wire [`CORE_XLEN-1:0] regfile_sp   = regfile[2];
  wire [`CORE_XLEN-1:0] regfile_gp   = regfile[3];
  wire [`CORE_XLEN-1:0] regfile_tp   = regfile[4];
  wire [`CORE_XLEN-1:0] regfile_t0   = regfile[5];
  wire [`CORE_XLEN-1:0] regfile_t1   = regfile[6];
  wire [`CORE_XLEN-1:0] regfile_t2   = regfile[7];
  wire [`CORE_XLEN-1:0] regfile_s0   = regfile[8];
  wire [`CORE_XLEN-1:0] regfile_fp   = regfile[8];
  wire [`CORE_XLEN-1:0] regfile_s1   = regfile[9];
  wire [`CORE_XLEN-1:0] regfile_a0   = regfile[10];
  wire [`CORE_XLEN-1:0] regfile_a1   = regfile[11];
  wire [`CORE_XLEN-1:0] regfile_a2   = regfile[12];
  wire [`CORE_XLEN-1:0] regfile_a3   = regfile[13];
  wire [`CORE_XLEN-1:0] regfile_a4   = regfile[14];
  wire [`CORE_XLEN-1:0] regfile_a5   = regfile[15];
  wire [`CORE_XLEN-1:0] regfile_a6   = regfile[16];
  wire [`CORE_XLEN-1:0] regfile_a7   = regfile[17];
  wire [`CORE_XLEN-1:0] regfile_s2   = regfile[18];
  wire [`CORE_XLEN-1:0] regfile_s3   = regfile[19];
  wire [`CORE_XLEN-1:0] regfile_s4   = regfile[20];
  wire [`CORE_XLEN-1:0] regfile_s5   = regfile[21];
  wire [`CORE_XLEN-1:0] regfile_s6   = regfile[22];
  wire [`CORE_XLEN-1:0] regfile_s7   = regfile[23];
  wire [`CORE_XLEN-1:0] regfile_s8   = regfile[24];
  wire [`CORE_XLEN-1:0] regfile_s9   = regfile[25];
  wire [`CORE_XLEN-1:0] regfile_s10  = regfile[26];
  wire [`CORE_XLEN-1:0] regfile_s11  = regfile[27];
  wire [`CORE_XLEN-1:0] regfile_t3   = regfile[28];
  wire [`CORE_XLEN-1:0] regfile_t4   = regfile[29];
  wire [`CORE_XLEN-1:0] regfile_t5   = regfile[30];
  wire [`CORE_XLEN-1:0] regfile_t6   = regfile[31];

  wire [`CORE_XLEN-1:0] regfile_x0  = regfile[0];
  wire [`CORE_XLEN-1:0] regfile_x1  = regfile[1];
  wire [`CORE_XLEN-1:0] regfile_x2  = regfile[2];
  wire [`CORE_XLEN-1:0] regfile_x3  = regfile[3];
  wire [`CORE_XLEN-1:0] regfile_x4  = regfile[4];
  wire [`CORE_XLEN-1:0] regfile_x5  = regfile[5];
  wire [`CORE_XLEN-1:0] regfile_x6  = regfile[6];
  wire [`CORE_XLEN-1:0] regfile_x7  = regfile[7];
  wire [`CORE_XLEN-1:0] regfile_x8  = regfile[8];
  wire [`CORE_XLEN-1:0] regfile_x9  = regfile[9];
  wire [`CORE_XLEN-1:0] regfile_x10 = regfile[10];
  wire [`CORE_XLEN-1:0] regfile_x11 = regfile[11];
  wire [`CORE_XLEN-1:0] regfile_x12 = regfile[12];
  wire [`CORE_XLEN-1:0] regfile_x13 = regfile[13];
  wire [`CORE_XLEN-1:0] regfile_x14 = regfile[14];
  wire [`CORE_XLEN-1:0] regfile_x15 = regfile[15];
  wire [`CORE_XLEN-1:0] regfile_x16 = regfile[16];
  wire [`CORE_XLEN-1:0] regfile_x17 = regfile[17];
  wire [`CORE_XLEN-1:0] regfile_x18 = regfile[18];
  wire [`CORE_XLEN-1:0] regfile_x19 = regfile[19];
  wire [`CORE_XLEN-1:0] regfile_x20 = regfile[20];
  wire [`CORE_XLEN-1:0] regfile_x21 = regfile[21];
  wire [`CORE_XLEN-1:0] regfile_x22 = regfile[22];
  wire [`CORE_XLEN-1:0] regfile_x23 = regfile[23];
  wire [`CORE_XLEN-1:0] regfile_x24 = regfile[24];
  wire [`CORE_XLEN-1:0] regfile_x25 = regfile[25];
  wire [`CORE_XLEN-1:0] regfile_x26 = regfile[26];
  wire [`CORE_XLEN-1:0] regfile_x27 = regfile[27];
  wire [`CORE_XLEN-1:0] regfile_x28 = regfile[28];
  wire [`CORE_XLEN-1:0] regfile_x29 = regfile[29];
  wire [`CORE_XLEN-1:0] regfile_x30 = regfile[30];
  wire [`CORE_XLEN-1:0] regfile_x31 = regfile[31];
  
endmodule
