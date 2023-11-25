/*
 * @Design: utils_shifter
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Barrel shifter
 */

module utils_shifter # (
  parameter SHIFT_MODE  = 0,
  parameter DATA_WIDTH  = 32,
  parameter SHAMT_WIDTH = 5
) (
  input  logic [DATA_WIDTH-1:0]  shift_src_i,
  input  logic [SHAMT_WIDTH-1:0] shift_amount_i,
  output logic [DATA_WIDTH-1:0]  shift_res_o
);
  generate
    if (SHIFT_MODE == 0) begin
      // left shift
      always @ (*) begin
        shift_res_o = shift_amount_i[0] ? {shift_src_i[DATA_WIDTH-1 :1], 1'd0 } : shift_src_i;
        shift_res_o = shift_amount_i[1] ? {shift_res_o[DATA_WIDTH-2 :1], 2'd0 } : shift_res_o;
        shift_res_o = shift_amount_i[2] ? {shift_res_o[DATA_WIDTH-4 :1], 4'd0 } : shift_res_o;
        shift_res_o = shift_amount_i[3] ? {shift_res_o[DATA_WIDTH-8 :1], 8'd0 } : shift_res_o;
        shift_res_o = shift_amount_i[4] ? {shift_res_o[DATA_WIDTH-16:1], 16'd0} : shift_res_o;
      end
    end else if (SHIFT_MODE == 1) begin
      // right shift
      always @ (*) begin
        shift_res_o = shift_amount_i[0] ? {1'd0,  shift_src_i[DATA_WIDTH-1:1 ]} : shift_src_i;
        shift_res_o = shift_amount_i[1] ? {2'd0,  shift_res_o[DATA_WIDTH-1:2 ]} : shift_res_o;
        shift_res_o = shift_amount_i[2] ? {4'd0,  shift_res_o[DATA_WIDTH-1:4 ]} : shift_res_o;
        shift_res_o = shift_amount_i[3] ? {8'd0,  shift_res_o[DATA_WIDTH-1:8 ]} : shift_res_o;
        shift_res_o = shift_amount_i[4] ? {16'd0, shift_res_o[DATA_WIDTH-1:16]} : shift_res_o;
      end
    end else begin
      assign shift_res_o = '0;
    end
  endgenerate
  
endmodule