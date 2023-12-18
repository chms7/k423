/*
 * @Design: k423_if_bpu_ras
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-12-10
 * @Description: Return address stack of bpu
 */
`include "k423_defines.svh"

module k423_if_bpu_ras (
  input                           clk_i,
  input                           rst_n_i,
  // update
  input logic                     upd_vld_i,
  input logic                     upd_tkn_i,
  input logic [`BR_TYPE_W-1:0]    upd_type_i,
  input logic [`CORE_DATA_W-1:0]  upd_src_pc_i,
  input logic [`CORE_DATA_W-1:0]  upd_tgt_pc_i,
  input logic [1:0]               upd_sat_cnt_i,
         
  output logic                    ras_vld_o,
  output logic [`CORE_DATA_W-1:0] ras_ret_pc_o
);
  wire                    ras_full, ras_empty;
  wire                    ras_push      = upd_vld_i & upd_type_i[`BR_TYPE_CALL];
  wire [`CORE_DATA_W-1:0] ras_push_data = upd_src_pc_i + 32'd4;
  wire                    ras_pop       = upd_vld_i & upd_type_i[`BR_TYPE_RET ];
  assign                  ras_vld_o     = ~ras_empty;
  
  // FILO
  utils_filo_sync #(
    .FILO_WIDTH ( `CORE_DATA_W ),
    .FILO_DEPTH ( `RAS_DEPTH   )
  ) u_ras_filo (
    .clk_i         ( clk_i         ),
    .rst_n_i       ( rst_n_i       ),

    .filo_wr_i     ( ras_push      ),
    .filo_wdata_i  ( ras_push_data ),
    .filo_rd_i     ( ras_pop       ),

    .filo_rdata_o  ( ras_ret_pc_o  ),
    .filo_full_o   ( ras_full      ),
    .filo_empty_o  ( ras_empty     )
  );

endmodule
