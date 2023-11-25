/*
 * @Design: data_mem
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-11
 * @Description: Data memory
 */

module data_mem # (
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter SRAM_DEPTH = 32'h0000_4000
) (
input                           clk_i,
input                           rst_n_i,

input  wire                     mem_en_i,
input  wire [DATA_WIDTH/8-1:0]  mem_we_i,
input  wire [ADDR_WIDTH-1:0]    mem_addr_i,
input  wire [DATA_WIDTH-1:0]    mem_wdata_i,
output reg  [DATA_WIDTH-1:0]    mem_rdata_o
);

// ram
reg  [DATA_WIDTH/4-1:0] ram [0:SRAM_DEPTH*4-1];

// address conversion
wire [$clog2(SRAM_DEPTH*4)-1:0] wr_addr, read_addr;
assign wr_addr = mem_addr_i[$clog2(SRAM_DEPTH*4)-1:0];
assign read_addr = {mem_addr_i[$clog2(SRAM_DEPTH*4)-1:2], 2'd0};

// read/write
always @ (posedge clk_i) begin
    if(mem_en_i) begin
        if (| mem_we_i) begin
            if (mem_we_i == 4'b0001)
                ram[wr_addr+0] <= mem_wdata_i[7:0];
            else if (mem_we_i == 4'b0011) begin
                ram[wr_addr+0] <= mem_wdata_i[7:0];
                ram[wr_addr+1] <= mem_wdata_i[15:8];
            end else begin
                ram[wr_addr+0] <= mem_wdata_i[7:0];
                ram[wr_addr+1] <= mem_wdata_i[15:8];
                ram[wr_addr+2] <= mem_wdata_i[23:16];
                ram[wr_addr+3] <= mem_wdata_i[31:24];
            end
        end else begin
            mem_rdata_o[7 :0 ] <= ram[read_addr+0];
            mem_rdata_o[15:8 ] <= ram[read_addr+1];
            mem_rdata_o[23:16] <= ram[read_addr+2];
            mem_rdata_o[31:24] <= ram[read_addr+3];
        end
    end
end

endmodule
