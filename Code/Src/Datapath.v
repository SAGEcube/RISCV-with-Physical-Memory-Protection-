`timescale 1ns / 1ps

module Datapath_PMP #(
    parameter PC_W = 8,
    parameter INSTR_W = 32,
    parameter DATA_W = 32,
    parameter DM_ADDR_W = 9,  // Keep 9-bit for DataMem internal use
    parameter ALU_CC_W = 4
    )(
    input                Clock,
    input                Reset,
    input                Reg_Write,
    input                ALU_Src,
    input [ALU_CC_W-1:0] ALU_CC,
    input                Mem_Read,
    input                Mem_Write,
    input                Mem_to_Reg,
    output        [2:0]  Funct3,
    output        [6:0]  Funct7,
    output        [6:0]  Opcode,
    output [DATA_W-1:0]  Datapath_Result,
    output               data_pmp_ok,
    output               instr_pmp_ok,
    output [PC_W-1:0]    PC
    );

    wire    [PC_W-1:0] PC_Next;
    wire [INSTR_W-1:0] Instruction;
    wire  [DATA_W-1:0] Ext_Imm;
    wire  [DATA_W-1:0] Reg1;
    wire  [DATA_W-1:0] Reg2;
    wire  [DATA_W-1:0] Src_B;
    wire  [DATA_W-1:0] ALU_Result;
    wire  [DATA_W-1:0] DataMem_Read;
    wire  [DATA_W-1:0] Write_Back_Data;
    wire mem_read_gated;
    wire mem_write_gated;

    // Extract 8-bit address for PMP checking (use lower 8 bits of ALU result)
    wire [7:0] data_pmp_addr = ALU_Result[7:0];

    ALU ALU_inst (
        .alu_sel(ALU_CC),
        .a_in(Reg1),
        .b_in(Src_B),
        .alu_out(ALU_Result)
    );

    // Data PMP checker with 8-bit addresses
    PMP_Checker data_pmp_inst (
        .addr(data_pmp_addr),        // 8-bit address
        .read_enable(Mem_Read),
        .write_enable(Mem_Write),
        .access_granted(data_pmp_ok)
    );

    // Instruction PMP checker with 8-bit PC
    PMP_Checker instr_pmp_inst (
        .addr(PC),                   // 8-bit address
        .read_enable(1'b1),
        .write_enable(1'b0),
        .access_granted(instr_pmp_ok)
    );

    assign mem_read_gated  = Mem_Read  & data_pmp_ok;
    assign mem_write_gated = Mem_Write & data_pmp_ok;

    DataMem DataMem_inst (
        .mem_read(mem_read_gated),
        .mem_write(mem_write_gated),
        .addr(ALU_Result[DM_ADDR_W-1:0]),  // Still use 9-bit for DataMem internally
        .write_data(Reg2),
        .read_data(DataMem_Read)
    );

    // ... rest of your datapath code remains the same
    InstrMem InstrMem_inst (
        .addr(PC),
        .instr(Instruction)
    );

    Instruction_Decoder Decoder_inst (
        .instruction(Instruction),
        .opcode(Opcode),
        .funct3(Funct3),
        .funct7(Funct7),
        .valid()
    );

    FlipFlop FlipFlop_inst (
        .clk(Clock),
        .reset(Reset),
        .d(PC_Next),
        .q(PC)
    );

    HalfAdder HalfAdder_inst(
        .a(PC),
        .b(8'd4),
        .sum(PC_Next)
    );

    ImmGen ImmGen_inst (
        .instr_code(Instruction),
        .imm_out(Ext_Imm)
    );

    Mux2_1 Mux_EX (
        .sel(ALU_Src),
        .in0(Reg2),
        .in1(Ext_Imm),
        .out(Src_B)
    );

    Mux2_1 Mux_WB (
        .sel(Mem_to_Reg),
        .in0(ALU_Result),
        .in1(DataMem_Read),
        .out(Write_Back_Data)
    );

    RegFile RegFile_inst (
        .clk(Clock),
        .reset(Reset),
        .rg_wrt_en(Reg_Write),
        .rg_wrt_addr(Instruction[11:7]),
        .rg_rd_addr1(Instruction[19:15]),
        .rg_rd_addr2(Instruction[24:20]),
        .rg_wrt_data(Write_Back_Data),
        .rg_rd_data1(Reg1),
        .rg_rd_data2(Reg2)
    );

    assign Datapath_Result = ALU_Result;

endmodule