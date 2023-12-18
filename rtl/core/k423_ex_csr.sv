/*
 * @Design: k423_ex_csr
 * @Author: Zhao Siwei 
 * @Email:  cheems@foxmail.com
 * @Date:   2023-11-27
 * @Description: CSR register
 */
`include "k423_defines.svh"

module k423_ex_csr (
  input                             clk_i,
  input                             rst_n_i,

  // id stage
  input  logic [`CORE_ADDR_W-1:0]   id_pc_i,
  input  logic [`CORE_INST_W-1:0]   id_inst_i,
  input  logic [`INST_GRP_W-1:0]    id_dec_grp_i,
  input  logic [`INST_INFO_W-1:0]   id_dec_info_i,

  input  logic                      id_dec_rs1_vld_i,
  input  logic [`CORE_XLEN-1:0]     id_dec_rs1_i,

  input  logic [`EXCP_TYPE_W-1:0]   id_dec_excp_type_i,
  input  logic [`INT_TYPE_W-1:0]    id_dec_int_type_i,
  input  logic [`INST_CSRADR_W-1:0] id_dec_csr_addr_i,
  input  logic [`INST_ZIMM_W-1:0]   id_dec_csr_zimm_i,
  // csr
  output logic                      csr_mtvec_tkn_o,
  output logic [`CORE_ADDR_W-1:0]   csr_mtvec_o,
  output logic                      csr_mepc_tkn_o,
  output logic [`CORE_ADDR_W-1:0]   csr_mepc_o,
  output logic [`CORE_XLEN-1:0]     csr_rd_o
);
  // ---------------------------------------------------------------------------
  // CSR Address
  // ---------------------------------------------------------------------------
  localparam ADDR_MSTATUS   = 12'h300;
  localparam ADDR_MISA      = 12'h301;
  // localparam ADDR_MEDELEG   = 12'h302;
  // localparam ADDR_MIDELEG   = 12'h303;
  localparam ADDR_MIE       = 12'h304;
  localparam ADDR_MTVEC     = 12'h305;
  localparam ADDR_MSCRATCH  = 12'h340;
  localparam ADDR_MEPC      = 12'h341;
  localparam ADDR_MCAUSE    = 12'h342;
  localparam ADDR_MTVAL     = 12'h343;
  localparam ADDR_MIP       = 12'h344;
  // localparam ADDR_MTINST    = 12'h34A;
  // localparam ADDR_MTVAL2    = 12'h34B;
  localparam ADDR_MCYCLE    = 12'hB00;
  localparam ADDR_MCYCLEH   = 12'hB80;
  // localparam ADDR_MINSTRET  = 12'hB02;
  // localparam ADDR_MINSTRETH = 12'hB82;
  // localparam ADDR_MHARTID   = 12'hF14;
  
  // ---------------------------------------------------------------------------
  // CSR Register
  // ---------------------------------------------------------------------------
  // mstatus
  logic [0:0] mstatus_SD_q        , mstatus_SD_d       ; // SD
  logic [7:0] mstatus_UNDEF0_q    , mstatus_UNDEF0_d   ; // undefined field
  logic [0:0] mstatus_TSR_q       , mstatus_TSR_d      ; // TSR[S]
  logic [0:0] mstatus_TW_q        , mstatus_TW_d       ; // TW[U,S]
  logic [0:0] mstatus_TVM_q       , mstatus_TVM_d      ; // TVM[S]
  logic [0:0] mstatus_MXR_q       , mstatus_MXR_d      ; // MXR[S]
  logic [0:0] mstatus_SUM_q       , mstatus_SUM_d      ; // SUM[S]
  logic [0:0] mstatus_MPRV_q      , mstatus_MPRV_d     ; // MPRV[U]
  logic [1:0] mstatus_XS_q        , mstatus_XS_d       ; // XS[CO]
  logic [1:0] mstatus_FS_q        , mstatus_FS_d       ; // FS[S,FLOAT]
  logic [1:0] mstatus_MPP_q       , mstatus_MPP_d      ; // MPP
  logic [1:0] mstatus_UNDEF1_q    , mstatus_UNDEF1_d   ; // undefined field
  logic [0:0] mstatus_SPP_q       , mstatus_SPP_d      ; // SPP[S]
  logic [0:0] mstatus_MPIE_q      , mstatus_MPIE_d     ; // MPIE
  logic [0:0] mstatus_UBE_q       , mstatus_UBE_d      ; // UBE[U]
  logic [0:0] mstatus_SPIE_q      , mstatus_SPIE_d     ; // SPIE[S]
  logic [0:0] mstatus_UNDEF2_q    , mstatus_UNDEF2_d   ; // undefined field
  logic [0:0] mstatus_MIE_q       , mstatus_MIE_d      ; // MIE
  logic [0:0] mstatus_UNDEF3_q    , mstatus_UNDEF3_d   ; // undefined field
  logic [0:0] mstatus_SIE_q       , mstatus_SIE_d      ; // SIE[S]
  logic [0:0] mstatus_UNDEF4_q    , mstatus_UNDEF4_d   ; // undefined field
  wire  [`CORE_ADDR_W-1:0] mstatus_q = {
              mstatus_SD_q, mstatus_UNDEF0_q, mstatus_TSR_q, mstatus_TW_q, mstatus_TVM_q,
              mstatus_MXR_q, mstatus_SUM_q, mstatus_MPRV_q, mstatus_XS_q, mstatus_FS_q, mstatus_MPP_q,
              mstatus_UNDEF1_q, mstatus_SPP_q, mstatus_MPIE_q, mstatus_UBE_q, mstatus_SPIE_q,
              mstatus_UNDEF2_q, mstatus_MIE_q, mstatus_UNDEF3_q, mstatus_SIE_q, mstatus_UNDEF4_q};
  
  // misa
  logic [1:0] misa_MXL_d          , misa_MXL_q         ; // MXL
  logic [3:0] misa_UNDEF_d        , misa_UNDEF_q       ; // undefined field
  logic [0:0] misa_EXTENSION_A_q  , misa_EXTENSION_A_d ; // Atomic extension
  logic [0:0] misa_EXTENSION_B_q  , misa_EXTENSION_B_d ; // tentatively reserved for Bit-Manipulation extension
  logic [0:0] misa_EXTENSION_C_q  , misa_EXTENSION_C_d ; // Compressed extension
  logic [0:0] misa_EXTENSION_D_q  , misa_EXTENSION_D_d ; // Double-precision floating-point extension
  logic [0:0] misa_EXTENSION_E_q  , misa_EXTENSION_E_d ; // RV32E base ISA
  logic [0:0] misa_EXTENSION_F_q  , misa_EXTENSION_F_d ; // Single-precision floating-point extension
  logic [0:0] misa_EXTENSION_G_q  , misa_EXTENSION_G_d ; // reserved
  logic [0:0] misa_EXTENSION_H_q  , misa_EXTENSION_H_d ; // Hypervisor extension
  logic [0:0] misa_EXTENSION_I_q  , misa_EXTENSION_I_d ; // RV32I/64I/128I base ISA
  logic [0:0] misa_EXTENSION_J_q  , misa_EXTENSION_J_d ; // tentatively reserved for Dynamically Translated Languages extension
  logic [0:0] misa_EXTENSION_K_q  , misa_EXTENSION_K_d ; // reserved
  logic [0:0] misa_EXTENSION_L_q  , misa_EXTENSION_L_d ; // reserved
  logic [0:0] misa_EXTENSION_M_q  , misa_EXTENSION_M_d ; // Integer Multiply/Divide extension
  logic [0:0] misa_EXTENSION_N_q  , misa_EXTENSION_N_d ; // tentatively reserved for User-Level Interrupts extension
  logic [0:0] misa_EXTENSION_O_q  , misa_EXTENSION_O_d ; // reserved
  logic [0:0] misa_EXTENSION_P_q  , misa_EXTENSION_P_d ; // tentatively reserved for Packed-SIMD extension
  logic [0:0] misa_EXTENSION_Q_q  , misa_EXTENSION_Q_d ; // Quad-precision floating-point extension
  logic [0:0] misa_EXTENSION_R_q  , misa_EXTENSION_R_d ; // reserved
  logic [0:0] misa_EXTENSION_S_q  , misa_EXTENSION_S_d ; // Supervisor mode implemented
  logic [0:0] misa_EXTENSION_T_q  , misa_EXTENSION_T_d ; // reserved
  logic [0:0] misa_EXTENSION_U_q  , misa_EXTENSION_U_d ; // User mode implemented
  logic [0:0] misa_EXTENSION_V_q  , misa_EXTENSION_V_d ; // tentatively reserved for Vector extension
  logic [0:0] misa_EXTENSION_W_q  , misa_EXTENSION_W_d ; // reserved
  logic [0:0] misa_EXTENSION_X_q  , misa_EXTENSION_X_d ; // Non-standard extensions present
  logic [0:0] misa_EXTENSION_Y_q  , misa_EXTENSION_Y_d ; // reserved
  logic [0:0] misa_EXTENSION_Z_q  , misa_EXTENSION_Z_d ; // reserved
  wire  [`CORE_ADDR_W-1:0] misa_q = {
              misa_MXL_q, misa_UNDEF_q, misa_EXTENSION_A_q, misa_EXTENSION_B_q, misa_EXTENSION_C_q,
              misa_EXTENSION_D_q, misa_EXTENSION_E_q, misa_EXTENSION_F_q, misa_EXTENSION_G_q, misa_EXTENSION_H_q,
              misa_EXTENSION_I_q, misa_EXTENSION_J_q, misa_EXTENSION_K_q, misa_EXTENSION_L_q, misa_EXTENSION_M_q,
              misa_EXTENSION_N_q, misa_EXTENSION_O_q, misa_EXTENSION_P_q, misa_EXTENSION_Q_q, misa_EXTENSION_R_q,
              misa_EXTENSION_S_q, misa_EXTENSION_T_q, misa_EXTENSION_U_q, misa_EXTENSION_V_q, misa_EXTENSION_W_q,
              misa_EXTENSION_X_q, misa_EXTENSION_Y_q, misa_EXTENSION_Z_q};
  
  // mtvec
  logic [29:0] mtvec_BASE_q       , mtvec_BASE_d       ; // trap base address
  logic [1:0]  mtvec_MODE_q       , mtvec_MODE_d       ; // trap address mode
  wire  [`CORE_ADDR_W-1:0] mtvec_q = {mtvec_BASE_q, mtvec_MODE_q};

  // mepc
  logic [`CORE_ADDR_W-1:0] mepc_q ,     mepc_d         ; // trap return address

  // mcause
  logic [0:0]  mcause_INTERRUPT_q , mcause_INTERRUPT_d ; // interrupt or exception
  logic [30:0] mcause_EXCP_CODE_q , mcause_EXCP_CODE_d ; // exception cause
  wire  [`CORE_ADDR_W-1:0] mcause_q = {mcause_INTERRUPT_q, mcause_EXCP_CODE_q};
  
  // mtval
  logic [`CORE_ADDR_W-1:0] mtval_q, mtval_d            ;
  
  // mie
  logic [15:0] mie_CUSTOM_q       , mie_CUSTOM_d       ; // custom interrupt
  logic [3:0]  mie_UNDEF0_q       , mie_UNDEF0_d       ; // undefined field
  logic [0:0]  mie_MEIE_q         , mie_MEIE_d         ; // MEIE
  logic [0:0]  mie_UNDEF1_q       , mie_UNDEF1_d       ; // undefined field
  logic [0:0]  mie_SEIE_q         , mie_SEIE_d         ; // SEIE[S]
  logic [0:0]  mie_UNDEF2_q       , mie_UNDEF2_d       ; // undefined field
  logic [0:0]  mie_MTIE_q         , mie_MTIE_d         ; // MTIE
  logic [0:0]  mie_UNDEF3_q       , mie_UNDEF3_d       ; // undefined field
  logic [0:0]  mie_STIE_q         , mie_STIE_d         ; // STIE[S]
  logic [0:0]  mie_UNDEF4_q       , mie_UNDEF4_d       ; // undefined field
  logic [0:0]  mie_MSIE_q         , mie_MSIE_d         ; // MSIE
  logic [0:0]  mie_UNDEF5_q       , mie_UNDEF5_d       ; // undefined field
  logic [0:0]  mie_SSIE_q         , mie_SSIE_d         ; // SSIE[S]
  logic [0:0]  mie_UNDEF6_q       , mie_UNDEF6_d       ; // undefined field
  wire  [`CORE_ADDR_W-1:0] mie_q = {
              mie_CUSTOM_q, mie_UNDEF0_q, mie_MEIE_q, mie_UNDEF1_q, mie_SEIE_q,
              mie_UNDEF2_q, mie_MTIE_q, mie_UNDEF3_q, mie_STIE_q, mie_UNDEF4_q,
              mie_MSIE_q, mie_UNDEF5_q, mie_SSIE_q, mie_UNDEF6_q};
  
  // mip
  logic [15:0] mip_CUSTOM_q       , mip_CUSTOM_d       ; // custom interrupt
  logic [3:0]  mip_UNDEF0_q       , mip_UNDEF0_d       ; // undefined field
  logic [0:0]  mip_MEIP_q         , mip_MEIP_d         ; // MEIP
  logic [0:0]  mip_UNDEF1_q       , mip_UNDEF1_d       ; // undefined field
  logic [0:0]  mip_SEIP_q         , mip_SEIP_d         ; // SEIP[S]
  logic [0:0]  mip_UNDEF2_q       , mip_UNDEF2_d       ; // undefined field
  logic [0:0]  mip_MTIP_q         , mip_MTIP_d         ; // MTIP
  logic [0:0]  mip_UNDEF3_q       , mip_UNDEF3_d       ; // undefined field
  logic [0:0]  mip_STIP_q         , mip_STIP_d         ; // STIP[S]
  logic [0:0]  mip_UNDEF4_q       , mip_UNDEF4_d       ; // undefined field
  logic [0:0]  mip_MSIP_q         , mip_MSIP_d         ; // MSIP
  logic [0:0]  mip_UNDEF5_q       , mip_UNDEF5_d       ; // undefined field
  logic [0:0]  mip_SSIP_q         , mip_SSIP_d         ; // SSIP[S]
  logic [0:0]  mip_UNDEF6_q       , mip_UNDEF6_d       ; // undefined field
  wire  [`CORE_ADDR_W-1:0] mip_q = {
              mip_CUSTOM_q, mip_UNDEF0_q, mip_MEIP_q, mip_UNDEF1_q, mip_SEIP_q,
              mip_UNDEF2_q, mip_MTIP_q, mip_UNDEF3_q, mip_STIP_q, mip_UNDEF4_q,
              mip_MSIP_q, mip_UNDEF5_q, mip_SSIP_q, mip_UNDEF6_q};

  // mscratch
  logic [31:0] mscratch_q         , mscratch_d         ;
  
  // mcycle
  logic [`CORE_XLEN*2-1:0] mcycle_data_q, mcycle_data_d;
  wire [`CORE_XLEN-1:0] mcycle_q  = mcycle_data_q[31:0];
  wire [`CORE_XLEN-1:0] mcycleh_q = mcycle_data_q[63:32];

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------
  // write data
  wire [`CORE_XLEN-1:0] zimm_ext = {{(`CORE_XLEN-`INST_ZIMM_W){1'b0}}, id_dec_csr_zimm_i};
  wire [`CORE_XLEN-1:0] csr_wdata = id_dec_info_i[`INST_INFO_CSR_ZIMM] ? zimm_ext : id_dec_rs1_i;
  
  // writable
  always @(*) begin
    mstatus_MPIE_d      = mstatus_MPIE_q;
    mstatus_MIE_d       = mstatus_MIE_q;
    mtvec_BASE_d        = mtvec_BASE_q;
    mtvec_MODE_d        = mtvec_MODE_q;
    mepc_d              = mepc_q;
    mcause_INTERRUPT_d  = mcause_INTERRUPT_q;
    mcause_EXCP_CODE_d  = mcause_EXCP_CODE_q;
    mtval_d             = mtval_q;
    mie_MEIE_d          = mie_MEIE_q;
    mie_MTIE_d          = mie_MTIE_q;
    mie_MSIE_d          = mie_MSIE_q;
    mip_MEIP_d          = mip_MEIP_q;
    mip_MTIP_d          = mip_MTIP_q;
    mip_MSIP_d          = mip_MSIP_q;
    mscratch_d          = mscratch_q;
    mcycle_data_d       = mcycle_data_q;
    
    // mcycle
    // if (ctrl_core_active_i) begin
      mcycle_data_d = mcycle_data_q + 1'b1;
    // end
    
    // MRET
    if (id_dec_excp_type_i[`EXCP_MRET]) begin
        mstatus_MIE_d       = mstatus_MPIE_q;
        mstatus_MPIE_d      = 1'b1;
        mepc_d              = mepc_q;
    // Exception
    end if (id_dec_excp_type_i[`EXCP_FLAG]) begin
        mcause_INTERRUPT_d  = 1'b0;
      if (id_dec_excp_type_i[`EXCP_TYPE_ILLEGAL_INST]) begin
        // illegal instruction
        mcause_EXCP_CODE_d  = `EXCP_CODE_ILLEAGAL_INST;
        mepc_d              = id_pc_i;
        mtval_d             = id_inst_i;
      end else if (id_dec_excp_type_i[`EXCP_TYPE_ECALL_U]) begin
        // ecall from U-mode
        mcause_EXCP_CODE_d  = `EXCP_CODE_ECALL_U;
        mepc_d              = id_pc_i;
      end else if (id_dec_excp_type_i[`EXCP_TYPE_BREAKPOINT]) begin
        // breakpoint
        mcause_EXCP_CODE_d  = `EXCP_CODE_BREAKPOINT;
        mepc_d              = id_pc_i;
      end
    // Interrupt
    // end else if (id_dec_int_type_i[`INT_FLAG]) begin

    // CSR Instruction
    end else begin
      case (id_dec_csr_addr_i)
        ADDR_MTVEC: begin
          if (id_dec_info_i[`INST_INFO_CSR_CSRRW]) begin
            mtvec_BASE_d = csr_wdata[31:2];
            mtvec_MODE_d = csr_wdata[1:0];
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRC]) begin
            mtvec_BASE_d = mtvec_BASE_q & ~csr_wdata[31:2];
            mtvec_MODE_d = mtvec_MODE_q & ~csr_wdata[1:0];
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRS]) begin
            mtvec_BASE_d = mtvec_BASE_q |  csr_wdata[31:2];
            mtvec_MODE_d = mtvec_MODE_q |  csr_wdata[1:0];
          end
        end
        ADDR_MEPC: begin
          if (id_dec_info_i[`INST_INFO_CSR_CSRRW]) begin
            mepc_d = csr_wdata;
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRC]) begin
            mepc_d = mepc_q & ~csr_wdata;
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRS]) begin
            mepc_d = mepc_q |  csr_wdata;
          end
        end
        ADDR_MTVAL: begin
          if (id_dec_info_i[`INST_INFO_CSR_CSRRW]) begin
            mtval_d = csr_wdata;
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRC]) begin
            mtval_d = mtval_q & ~csr_wdata;
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRS]) begin
            mtval_d = mtval_q |  csr_wdata;
          end
        end
        ADDR_MIE: begin
          if (id_dec_info_i[`INST_INFO_CSR_CSRRW]) begin
            mie_MEIE_d = csr_wdata[11];
            mie_MTIE_d = csr_wdata[7];
            mie_MSIE_d = csr_wdata[3];
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRC]) begin
            mie_MEIE_d = mie_MEIE_q & ~csr_wdata[11];
            mie_MTIE_d = mie_MTIE_q & ~csr_wdata[7];
            mie_MSIE_d = mie_MSIE_q & ~csr_wdata[3];
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRS]) begin
            mie_MEIE_d = mie_MEIE_q |  csr_wdata[11];
            mie_MTIE_d = mie_MTIE_q |  csr_wdata[7];
            mie_MSIE_d = mie_MSIE_q |  csr_wdata[3];
          end
        end
        ADDR_MSCRATCH: begin
          if (id_dec_info_i[`INST_INFO_CSR_CSRRW]) begin
            mscratch_d = csr_wdata;
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRC]) begin
            mscratch_d = mscratch_q & ~csr_wdata;
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRS]) begin
            mscratch_d = mscratch_q |  csr_wdata;
          end
        end
        ADDR_MCYCLE: begin
          if (id_dec_info_i[`INST_INFO_CSR_CSRRW]) begin
            mcycle_data_d = {mcycle_data_q[63:32], csr_wdata};
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRC]) begin
            mcycle_data_d = {mcycle_data_q[63:32], mcycle_data_q[31:0] & ~csr_wdata};
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRS]) begin
            mcycle_data_d = {mcycle_data_q[63:32], mcycle_data_q[31:0] |  csr_wdata};
          end
        end
        ADDR_MCYCLEH: begin
          if (id_dec_info_i[`INST_INFO_CSR_CSRRW]) begin
            mcycle_data_d = {csr_wdata, mcycle_data_q[31:0]};
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRC]) begin
            mcycle_data_d = {mcycle_data_q[63:32] & ~csr_wdata, mcycle_data_q[31:0]};
          end else if (id_dec_info_i[`INST_INFO_CSR_CSRRS]) begin
            mcycle_data_d = {mcycle_data_q[63:32] |  csr_wdata, mcycle_data_q[31:0]};
          end
        end
      endcase
    end
  end

  // update
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      mstatus_MPIE_q      <= 1'b1;
      mstatus_MIE_q       <= 1'b0; // global   interrupt off
      mie_MEIE_q          <= 1'b0; // external interrupt off
      mie_MTIE_q          <= 1'b0; // timer    interrupt off
      mie_MSIE_q          <= 1'b0; // software interrupt off
      mtvec_BASE_q        <= `TRAP_BASE;
      mtvec_MODE_q        <= 2'd0; // direct mode
      mscratch_q          <= '0;
      mepc_q              <= '0;
      mcause_INTERRUPT_q  <= '0;
      mcause_EXCP_CODE_q  <= '0;
      mtval_q             <= '0;
      mip_MEIP_q          <= 1'b0; // no external interrupt pending
      mip_MTIP_q          <= 1'b0; // no timer    interrupt pending
      mip_MSIP_q          <= 1'b0; // no software interrupt pending
      mcycle_data_q       <= 'd0;
    end
    else begin
      mstatus_MPIE_q      <= mstatus_MPIE_d;
      mstatus_MIE_q       <= mstatus_MIE_d;
      mie_MEIE_q          <= mie_MEIE_d;
      mie_MTIE_q          <= mie_MTIE_d;
      mie_MSIE_q          <= mie_MSIE_d;
      mtvec_BASE_q        <= mtvec_BASE_d;
      mtvec_MODE_q        <= mtvec_MODE_d;
      mscratch_q          <= mscratch_d;
      mepc_q              <= mepc_d;
      mcause_INTERRUPT_q  <= mcause_INTERRUPT_d;
      mcause_EXCP_CODE_q  <= mcause_EXCP_CODE_d;
      mtval_q             <= mtval_d;
      mip_MEIP_q          <= mip_MEIP_d;
      mip_MTIP_q          <= mip_MTIP_d;
      mip_MSIP_q          <= mip_MSIP_d;
      mcycle_data_q       <= mcycle_data_d;
    end
  end

  // unwritable
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      // mstatus
      mstatus_SD_q       <= 1'b0;
      mstatus_UNDEF0_q   <= 8'd0;
      mstatus_TSR_q      <= 1'b0;
      mstatus_TW_q       <= 1'b0;
      mstatus_TVM_q      <= 1'b0;
      mstatus_MXR_q      <= 1'b0;
      mstatus_SUM_q      <= 1'b0;
      mstatus_MPRV_q     <= 1'b0;
      mstatus_XS_q       <= 2'b00;
      mstatus_FS_q       <= 2'b00;
      mstatus_MPP_q      <= 2'b11; // M-Mode: 2'b11
      mstatus_UNDEF1_q   <= 2'd0;
      mstatus_SPP_q      <= 1'b0;
      // mstatus_MPIE_q     <= 1'b0;
      mstatus_UBE_q      <= 1'b0;
      mstatus_SPIE_q     <= 1'b0;
      mstatus_UNDEF2_q   <= 1'd0;
      // mstatus_MIE_q      <= 1'b0;
      mstatus_UNDEF3_q   <= 1'd0;
      mstatus_SIE_q      <= 1'b0;
      mstatus_UNDEF4_q   <= 1'd0;
      
      // misa
      misa_MXL_q         <= 2'b01; // XLEN: 32
      misa_UNDEF_q       <= 4'd0;
      misa_EXTENSION_A_q <= 1'b0;
      misa_EXTENSION_B_q <= 1'b0;
      misa_EXTENSION_C_q <= 1'b0;
      misa_EXTENSION_D_q <= 1'b0;
      misa_EXTENSION_E_q <= 1'b0;
      misa_EXTENSION_F_q <= 1'b0;
      misa_EXTENSION_G_q <= 1'b0;
      misa_EXTENSION_H_q <= 1'b0;
      misa_EXTENSION_I_q <= 1'b1;  // RV32I
      misa_EXTENSION_J_q <= 1'b0;
      misa_EXTENSION_K_q <= 1'b0;
      misa_EXTENSION_L_q <= 1'b0;
      misa_EXTENSION_M_q <= 1'b0;
      misa_EXTENSION_N_q <= 1'b0;
      misa_EXTENSION_O_q <= 1'b0;
      misa_EXTENSION_P_q <= 1'b0;
      misa_EXTENSION_Q_q <= 1'b0;
      misa_EXTENSION_R_q <= 1'b0;
      misa_EXTENSION_S_q <= 1'b0;
      misa_EXTENSION_T_q <= 1'b0;
      misa_EXTENSION_U_q <= 1'b0;
      misa_EXTENSION_V_q <= 1'b0;
      misa_EXTENSION_W_q <= 1'b0;
      misa_EXTENSION_X_q <= 1'b0;
      misa_EXTENSION_Y_q <= 1'b0;
      misa_EXTENSION_Z_q <= 1'b0;
        
      // mie
      mie_CUSTOM_q       <= 16'd0;
      mie_UNDEF0_q       <= 4'd0;
      mie_UNDEF1_q       <= 1'd0;
      mie_SEIE_q         <= 1'b0;  
      mie_UNDEF2_q       <= 1'd0;
      mie_UNDEF3_q       <= 1'd0;
      mie_STIE_q         <= 1'b0;  
      mie_UNDEF4_q       <= 1'd0;
      mie_UNDEF5_q       <= 1'd0;
      mie_SSIE_q         <= 1'b0;  
      mie_UNDEF6_q       <= 1'd0;

      // mip
      mip_CUSTOM_q       <= 16'd0;
      mip_UNDEF0_q       <= 4'd0;
      mip_UNDEF1_q       <= 1'd0;
      mip_SEIP_q         <= 1'b0;  
      mip_UNDEF2_q       <= 1'd0;
      mip_UNDEF3_q       <= 1'd0;
      mip_STIP_q         <= 1'b0;  
      mip_UNDEF4_q       <= 1'd0;
      mip_UNDEF5_q       <= 1'd0;
      mip_SSIP_q         <= 1'b0;
      mip_UNDEF6_q       <= 1'd0;
    end
  end
    
  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------
  assign csr_rd_o = {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MSTATUS  }} & mstatus_q   |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MISA     }} & misa_q      |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MTVEC    }} & mtvec_q     | 
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MEPC     }} & mepc_q      |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MCAUSE   }} & mcause_q    |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MTVAL    }} & mtval_q     |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MIE      }} & mie_q       |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MIP      }} & mip_q       |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MSCRATCH }} & mscratch_q  |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MCYCLE   }} & mcycle_q    |
                    {`CORE_XLEN{id_dec_csr_addr_i == ADDR_MCYCLEH  }} & mcycleh_q   
                    ;

  // ---------------------------------------------------------------------------
  // Exception Jump
  // ---------------------------------------------------------------------------
  assign csr_mtvec_tkn_o = id_dec_excp_type_i[`EXCP_FLAG];
  assign csr_mtvec_o     = mtvec_q;
  assign csr_mepc_tkn_o  = id_dec_excp_type_i[`EXCP_MRET];
  assign csr_mepc_o      = mepc_q;
  
endmodule
