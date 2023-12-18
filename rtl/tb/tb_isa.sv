/*
 * @Design: tb_core
 * @Author: Zhao Siwei
 * @Email:  cheems@foxmail.com
 * @Description: Testbench of k423_core
 */
`timescale 1ns/10ps

`include "k423_defines.svh"
`include "k423_config.svh"

// Test Options
`define TEST_RV32UI   1
// `define TEST_RV32UM   1
`define TEST_RV32MI   1
// `define DEBUG_INFO_WB 1

module tb_isa;

// Parameters
parameter PERIOD     = 10;            // 100MHz
parameter IMEM_DEPTH = 32'h0000_4000; // 64KB
parameter DMEM_DEPTH = 32'h0000_4000; // 64KB
parameter TCM_DEPTH  = 32'h0000_8000; // 128KB

// Inputs & Outputs
reg                         clk_i   = 0;
reg                         rst_n_i = 0;

wire                        mem_inst_req_vld;
wire                        mem_inst_req_wen;
wire  [`CORE_ADDR_W-1:0]    mem_inst_req_addr;
wire  [`CORE_XLEN-1:0]      mem_inst_req_wdata;
wire                        mem_inst_req_rdy;
wire                        mem_inst_rsp_vld;
wire  [`CORE_FETCH_W-1:0]   mem_inst_rsp_rdata;

wire                        mem_data_req_vld;
wire  [`CORE_XLEN/8-1:0]    mem_data_req_wen;
wire  [`CORE_ADDR_W-1:0]    mem_data_req_addr;
wire  [`CORE_FETCH_W-1:0]   mem_data_req_wdata;
wire                        mem_data_req_rdy;
wire                        mem_data_rsp_vld;
wire  [`CORE_FETCH_W-1:0]   mem_data_rsp_rdata;

logic [`CORE_ADDR_W-1:0]    debug_wb_pc_w;
logic                       debug_wb_rd_vld_w;
logic [`INST_RSDIDX_W-1:0]  debug_wb_rd_idx_w;
logic [`CORE_XLEN-1:0]      debug_wb_rd_w;

// Regfile
wire[`CORE_XLEN-1:0] x3  = u_k423_core.u_k423_id_regfile.regfile[3];
wire[`CORE_XLEN-1:0] x10 = u_k423_core.u_k423_id_regfile.regfile[10];
wire[`CORE_XLEN-1:0] x17 = u_k423_core.u_k423_id_regfile.regfile[17];
wire[`CORE_XLEN-1:0] x26 = u_k423_core.u_k423_id_regfile.regfile[26];
wire[`CORE_XLEN-1:0] x27 = u_k423_core.u_k423_id_regfile.regfile[27];
wire[`CORE_XLEN-1:0] x30 = u_k423_core.u_k423_id_regfile.regfile[30];
wire[`CORE_XLEN-1:0] x31 = u_k423_core.u_k423_id_regfile.regfile[31];

// clk & rst
initial forever #(PERIOD/2) clk_i = ~clk_i;
initial         #(PERIOD*2) rst_n_i = 1;

// Core
k423_core u_k423_core (
  .clk_i                ( clk_i              ),
  .rst_n_i              ( rst_n_i            ),

  .mem_inst_req_vld_o   ( mem_inst_req_vld   ),
  .mem_inst_req_wen_o   ( mem_inst_req_wen   ),
  .mem_inst_req_addr_o  ( mem_inst_req_addr  ),
  .mem_inst_req_wdata_o ( mem_inst_req_wdata ),
  .mem_inst_req_rdy_i   ( 1'b1               ),
  .mem_inst_rsp_vld_i   ( 1'b1               ),
  .mem_inst_rsp_rdata_i ( mem_inst_rsp_rdata ),
                               
  .mem_data_req_vld_o   ( mem_data_req_vld   ),
  .mem_data_req_wen_o   ( mem_data_req_wen   ),
  .mem_data_req_addr_o  ( mem_data_req_addr  ),
  .mem_data_req_wdata_o ( mem_data_req_wdata ),
  .mem_data_req_rdy_i   ( 1'b1               ),
  .mem_data_rsp_vld_i   ( 1'b1               ),
  .mem_data_rsp_rdata_i ( mem_data_rsp_rdata ),

  .debug_wb_pc_o        ( debug_wb_pc_w      ),
  .debug_wb_rd_vld_o    ( debug_wb_rd_vld_w  ),
  .debug_wb_rd_idx_o    ( debug_wb_rd_idx_w  ),
  .debug_wb_rd_o        ( debug_wb_rd_w      )
);

// Debug Information
`ifdef DEBUG_INFO_WB
always @(posedge clk_i) begin
  if (rst_n_i == 1'b1)
    $display("----------------------- WB INFO ------------------------");
    $display("pc: %h,\trd_vld: %b,\trd[%d] = %h\n",
              debug_wb_pc_w, debug_wb_rd_vld_w, debug_wb_rd_idx_w, debug_wb_rd_w);
end
`endif

// Memory
inst_mem #(
  .ADDR_WIDTH ( 32         ),
  .DATA_WIDTH ( 32         ),
  .SRAM_DEPTH ( IMEM_DEPTH )
) u_inst_mem (
  .clk_i       ( clk_i              ),
  .rst_n_i     ( rst_n_i            ),

  .mem_en_i    ( mem_inst_req_vld   ),
  .mem_we_i    ( mem_inst_req_wen   ),
  .mem_addr_i  ( mem_inst_req_addr  ),
  .mem_wdata_i ( mem_inst_req_wdata ),
  .mem_rdata_o ( mem_inst_rsp_rdata )
);

data_mem #(
  .ADDR_WIDTH ( 32         ),
  .DATA_WIDTH ( 32         ),
  .SRAM_DEPTH ( DMEM_DEPTH )
) u_data_mem (
  .clk_i       ( clk_i              ),
  .rst_n_i     ( rst_n_i            ),

  .mem_en_i    ( mem_data_req_vld   ),
  .mem_we_i    ( mem_data_req_wen   ),
  .mem_addr_i  ( mem_data_req_addr  ),
  .mem_wdata_i ( mem_data_req_wdata ),
  .mem_rdata_o ( mem_data_rsp_rdata )
);

// Run Time Counter 
integer file;
integer timer1;
integer timer2;

// Run riscv-tests
initial begin
  file = $fopen("./sim/run_time.txt");

`ifdef TEST_RV32UI
    #PERIOD
      $display("\n\033[43;30m----------------------- TEST RV32UI BEGIN ------------------------\033[0m\n");

    $display("Loading add instructions...");
    $fwrite(file, "\n add \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-add.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-add.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading addi instructions...");
    $fwrite(file, "\n addi \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-addi.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-addi.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading and instructions...");
    $fwrite(file, "\n and \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-and.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-and.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading andi instructions...");
    $fwrite(file, "\n andi \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-andi.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-andi.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading auipc instructions...");
    $fwrite(file, "\n auipc \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-auipc.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-auipc.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading beq instructions...");
    $fwrite(file, "\n beq \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-beq.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-beq.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading bge instructions...");
    $fwrite(file, "\n bge \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bge.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bge.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading bgeu instructions...");
    $fwrite(file, "\n bgeu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bgeu.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bgeu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading blt instructions...");
    $fwrite(file, "\n blt \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-blt.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-blt.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading bltu instructions...");
    $fwrite(file, "\n bltu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bltu.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bltu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading bne instructions...");
    $fwrite(file, "\n bne \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bne.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-bne.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading jal instructions...");
    $fwrite(file, "\n jal \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-jal.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-jal.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading jalr instructions...");
    $fwrite(file, "\n jalr \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-jalr.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-jalr.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading lui instructions...");
    $fwrite(file, "\n lui \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lui.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lui.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading or instructions...");
    $fwrite(file, "\n or \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-or.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-or.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading ori instructions...");
    $fwrite(file, "\n ori \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-ori.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-ori.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading sll instructions...");
    $fwrite(file, "\n sll \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sll.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sll.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading slli instructions...");
    $fwrite(file, "\n slli \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-slli.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-slli.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading slt instructions...");
    $fwrite(file, "\n slt \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-slt.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-slt.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading slti instructions...");
    $fwrite(file, "\n slti \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-slti.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-slti.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading sltiu instructions...");
    $fwrite(file, "\n sltiu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sltiu.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sltiu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading sltu instructions...");
    $fwrite(file, "\n sltu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sltu.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sltu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading sra instructions...");
    $fwrite(file, "\n sra \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sra.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sra.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading srai instructions...");
    $fwrite(file, "\n srai \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-srai.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-srai.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading srl instructions...");
    $fwrite(file, "\n srl \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-srl.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-srl.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading srli instructions...");
    $fwrite(file, "\n srli \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-srli.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-srli.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading sub instructions...");
    $fwrite(file, "\n sub \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sub.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sub.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading xor instructions...");
    $fwrite(file, "\n xor \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-xor.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-xor.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading xori instructions...");
    $fwrite(file, "\n xori \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-xori.verilog", u_inst_mem.ram);
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-xori.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading lb instructions...");
    $fwrite(file, "\n lb \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lb.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lb.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading lbu instructions...");
    $fwrite(file, "\n lbu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lbu.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lbu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading lh instructions...");
    $fwrite(file, "\n lh \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lh.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lh.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading lhu instructions...");
    $fwrite(file, "\n lhu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lhu.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lhu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading lw instructions...");
    $fwrite(file, "\n lw \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lw.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-lw.verilog", u_data_mem.ram);
    inst_test;     
    #PERIOD
    $display("Loading sb instructions...");
    $fwrite(file, "\n sb \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sb.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sb.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading sh instructions...");
    $fwrite(file, "\n sh \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sh.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sh.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading sw instructions...");
    $fwrite(file, "\n sw \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sw.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-sw.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    // $display("Loading fence_i instructions...");
    // $fwrite(file, "\n fence_i \t");
    // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-fence_i.verilog", u_inst_mem.ram);
    // // $readmemh ("./tests/riscv-tests/isa/generated/rv32ui-p-fence_i.verilog", u_data_mem.ram);
    // inst_test;
    // #PERIOD
`endif

`ifdef TEST_RV32UM
    $display("\n\033[43;30m----------------------- TEST RV32UM BEGIN ------------------------\033[0m\n");

    $display("Loading div instructions...");
    $fwrite(file, "\n div \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-div.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-div.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading divu instructions...");
    $fwrite(file, "\n divu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-divu.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-divu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading mul instructions...");
    $fwrite(file, "\n mul \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mul.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mul.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading mulh instructions...");
    $fwrite(file, "\n mulh \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mulh.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mulh.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading mulhsu instructions...");
    $fwrite(file, "\n mulhsu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mulhsu.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mulhsu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading mulhu instructions...");
    $fwrite(file, "\n mulhu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mulhu.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-mulhu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading rem instructions...");
    $fwrite(file, "\n rem \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-rem.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-rem.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading remu instructions...");
    $fwrite(file, "\n remu \t");
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-remu.verilog", u_inst_mem.ram);
    $readmemh ("./tests/riscv-tests/isa/generated/rv32um-p-remu.verilog", u_data_mem.ram);
    inst_test;
    #PERIOD
`endif

`ifdef TEST_RV32MI
    $display("\n\033[43;30m----------------------- TEST RV32MI BEGIN ------------------------\033[0m\n");

    $display("Loading breakpoint instructions...");
    $fwrite(file, "\n breakpoint \t");
    $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-breakpoint.verilog"}, u_inst_mem.ram);
    //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-breakpoint.verilog"}, u_data_mem.ram);
    inst_test;
    #PERIOD
    $display("Loading csr instructions...");
    $fwrite(file, "\n csr \t");
    $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-csr.verilog"}, u_inst_mem.ram);
    //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-csr.verilog"}, u_data_mem.ram);
    inst_test;
    #PERIOD
    // $display("Loading illegal instructions...");
    // $fwrite(file, "\n illegal \t");
    // $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-illegal.verilog"}, u_inst_mem.ram);
    // //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-illegal.verilog"}, u_data_mem.ram);
    // inst_test;
    // #PERIOD
    // $display("Loading ma_addr instructions...");
    // $fwrite(file, "\n ma_addr \t");
    // $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-ma_addr.verilog"}, u_inst_mem.ram);
    // //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-ma_addr.verilog"}, u_data_mem.ram);
    // inst_test;
    // #PERIOD
    // $display("Loading ma_fetch instructions...");
    // $fwrite(file, "\n ma_fetch \t");
    // $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-ma_fetch.verilog"}, u_inst_mem.ram);
    // //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-ma_fetch.verilog"}, u_data_mem.ram);
    // inst_test;
    // #PERIOD
    $display("Loading mcsr instructions...");
    $fwrite(file, "\n mcsr \t");
    $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-mcsr.verilog"}, u_inst_mem.ram);
    //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-mcsr.verilog"}, u_data_mem.ram);
    inst_test;
    #PERIOD
    // $display("Loading sbreak instructions...");
    // $fwrite(file, "\n sbreak \t");
    // $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-sbreak.verilog"}, u_inst_mem.ram);
    // //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-sbreak.verilog"}, u_data_mem.ram);
    // inst_test;
    // #PERIOD
    // $display("Loading scall instructions...");
    // $fwrite(file, "\n scall \t");
    // $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-scall.verilog"}, u_inst_mem.ram);
    // //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-scall.verilog"}, u_data_mem.ram);
    // inst_test;
    // #PERIOD
    $display("Loading shamt instructions...");
    $fwrite(file, "\n shamt \t");
    $readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-shamt.verilog"}, u_inst_mem.ram);
    //$readmemh ({"./tests/riscv-tests/isa/generated/rv32mi-p-shamt.verilog"}, u_data_mem.ram);
    inst_test;
    #PERIOD
`endif

    #(PERIOD*10) $finish;
end

task inst_test;
begin
    #PERIOD
    rst_n_i = 1'b1;
    #(2*PERIOD)
    rst_n_i = 1'b0;
    $display("Start testing...");
    timer1 = $time;
    #PERIOD
    rst_n_i = 1'b1;
    #PERIOD        
    // wait (x26 == 32'd1);
    wait (x17 == 32'd93);
    timer2 = $time;
    $display("test time: %0d cycles", (timer2-timer1)/PERIOD);
    $fwrite(file, "%0d", (timer2-timer1)/PERIOD);
    #(18*PERIOD)
    // if (x27 == 32'd1) begin
    if (x10 == 32'b0) begin
        pass_display;
    end else begin
        fail_display;
    end
end
endtask

task pass_display;
begin
    $display("\033[0;32m----------------------- TEST_PASS ------------------------\033[0m\n");
end

endtask
task fail_display;
begin
    $display("\033[0;31m----------------------- TEST_FAIL ------------------------\033[0m\n");
    $display("fail testnum = %0d", x3);
    $finish;
end
endtask

// Dump Wave
initial begin
  $dumpfile("sim/wave.vcd");
  $dumpvars(0, tb_isa);
end

endmodule

