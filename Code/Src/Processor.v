`timescale 1ns / 1ps

module Top_Processor_PMP(
    input wire Clock,
    input wire Reset,
    output wire [31:0] ALU_Result_Out,
    output wire [7:0] PC_Out,
    output wire [6:0] Opcode_Out,
    output wire [2:0] Funct3_Out,
    output wire PMP_Violation_Detected
);

    wire Reg_Write;
    wire ALU_Src;
    wire [3:0] ALU_CC;
    wire Mem_Read;
    wire Mem_Write;
    wire Mem_to_Reg;
    wire [2:0] Funct3;
    wire [6:0] Funct7;
    wire [6:0] Opcode;
    wire [31:0] Datapath_Result;
    wire data_pmp_ok;
    wire instr_pmp_ok;

    Control_Unit control_unit (
        .opcode(Opcode),
        .funct3(Funct3),
        .funct7(Funct7),
        .reg_write(Reg_Write),
        .alu_src(ALU_Src),
        .alu_cc(ALU_CC),
        .mem_read(Mem_Read),
        .mem_write(Mem_Write),
        .mem_to_reg(Mem_to_Reg)
    );

    Datapath_PMP datapath (
        .Clock(Clock),
        .Reset(Reset),
        .Reg_Write(Reg_Write),
        .ALU_Src(ALU_Src),
        .ALU_CC(ALU_CC),
        .Mem_Read(Mem_Read),
        .Mem_Write(Mem_Write),
        .Mem_to_Reg(Mem_to_Reg),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .Opcode(Opcode),
        .Datapath_Result(Datapath_Result),
        .data_pmp_ok(data_pmp_ok),
        .instr_pmp_ok(instr_pmp_ok),
        .PC(PC_Out)
    );

    assign ALU_Result_Out = Datapath_Result;
    assign Opcode_Out = Opcode;
    assign Funct3_Out = Funct3;
    assign PMP_Violation_Detected = ~data_pmp_ok | ~instr_pmp_ok;

endmodule