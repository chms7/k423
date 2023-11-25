module sram16kx32 (
  input         clk_i,
  input         rst_n_i,
  input         mem_en,
  input         mem_wen,
  input  [31:0] mem_addr,
  input  [31:0] mem_wdata,
  output [31:0] mem_rdata
);
  sram16kx8 sram16kx8_0(
    .clka  ( clk_i            ),
    .ena   ( mem_en           ),
    .wea   ( mem_wen          ),
    .addra ( mem_addr [15:2]  ),
    .dina  ( mem_wdata[7:0]   ),
    .douta ( mem_rdata[7:0]   ) 
  );
  sram16kx8 sram16kx8_1(
    .clka  ( clk_i            ),
    .ena   ( mem_en           ),
    .wea   ( mem_wen          ),
    .addra ( mem_addr [15:2]  ),
    .dina  ( mem_wdata[15:8]  ),
    .douta ( mem_rdata[15:8]  ) 
  );
  sram16kx8 sram16kx8_2(
    .clka  ( clk_i            ),
    .ena   ( mem_en           ),
    .wea   ( mem_wen          ),
    .addra ( mem_addr [15:2]  ),
    .dina  ( mem_wdata[23:16] ),
    .douta ( mem_rdata[23:16] ) 
  );
  sram16kx8 sram16kx8_3(
    .clka  ( clk_i            ),
    .ena   ( mem_en           ),
    .wea   ( mem_wen          ),
    .addra ( mem_addr [15:2]  ),
    .dina  ( mem_wdata[31:24] ),
    .douta ( mem_rdata[31:24] ) 
  );
  
endmodule