`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  n/a
// Engineer: Kirby Burke Jr.
// 
// Create Date: 08/22/2024 02:03:52 PM
// Design Name: Controller
// Module Name: Controller
// Project Name: 32-Bit RISC-V Single-Cycle Processor
// Target Devices: Digilent Cmod A7-35T(xc7z35tcpg236-1)
// Tool Versions: Vivado v2023.2 (64-bit)
// Description: Processees opcode and sends control codes to DataPath submodules
//     RegFile, Datamem, and both Multiplexers.
// 
// Dependencies: Opcode input signal
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module Control_Unit(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg reg_write,
    output reg alu_src,
    output reg [3:0] alu_cc,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg
);

    always @(*) begin
        // Default values - safe state
        reg_write = 1'b0;
        alu_src = 1'b0;
        alu_cc = 4'b0000;  // ADD operation
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;

        case (opcode)
            // R-type instructions (ADD, SUB, AND, OR, etc.)
            7'b0110011: begin
                reg_write = 1'b1;
                alu_src = 1'b0;  // Use register values
                case (funct3)
                    3'b000: alu_cc = (funct7[5]) ? 4'b0001 : 4'b0000; // ADD/SUB
                    3'b111: alu_cc = 4'b0010; // AND
                    default: alu_cc = 4'b0000; // ADD as default
                endcase
            end
            
            // I-type instructions (ADDI, ANDI, etc.)
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src = 1'b1;  // Use immediate value
                alu_cc = 4'b0000; // ADD operation
            end
            
            // Load instructions (LW)
            7'b0000011: begin
                reg_write = 1'b1;
                alu_src = 1'b1;  // Use immediate for address
                mem_read = 1'b1;
                mem_to_reg = 1'b1; // Write back from memory
                alu_cc = 4'b0000; // ADD for address calculation
            end
            
            // Store instructions (SW)
            7'b0100011: begin
                alu_src = 1'b1;  // Use immediate for address
                mem_write = 1'b1;
                alu_cc = 4'b0000; // ADD for address calculation
            end
            
            // LUI (Load Upper Immediate)
            7'b0110111: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_cc = 4'b0011; // Special operation for LUI
            end
            
            // JALR (Jump and Link Register)
            7'b1100111: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_cc = 4'b0000; // ADD for address calculation
            end
            
            // Default: safe NOP-like state
            default: begin
                // All defaults already set
            end
        endcase
    end

endmodule