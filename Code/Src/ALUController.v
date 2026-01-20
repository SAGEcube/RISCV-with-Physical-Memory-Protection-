`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  n/a
// Engineer: Kirby Burke Jr.
// 
// Create Date: 03/19/2024 06:35:29 PM
// Design Name: Arithmetic Logic Unit Controller
// Module Name: ALUController
// Project Name: 32-Bit RISC-V Single-Cycle Processor
// Target Devices: Digilent Cmod A7-35T(xc7z35tcpg236-1)
// Tool Versions: Vivado v2023.2 (64-bit)
// Description: Computes ALU operation and function signals to return the
//     corresponding control code to the DataPath ALU.
// 
// Dependencies: 
//     Input Signals: alu_op, funct3, and funct7
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALUController(ALU_Op, Funct3, Funct7, Operation);

    /** I/O Signals **/
    input [1:0] ALU_Op;
    input [2:0] Funct3;
    input [6:0] Funct7;
    output reg [3:0] Operation;

    /** Module Behavior **/
    always @(*) begin
        /* Set bit 0 if Funct3 is '110'                 */
        /* OR if Funct3 is '010' AND bit 0 of ALU_Op is '1' */
        Operation[0] = (Funct3 == 3'b110 || Funct3 == 3'b010 
			    && ALU_Op[0] == 1'b0) ? 1'b1 : 1'b0;

        /* Set bit 1 if first AND bits 0 and 2 of Funct3 are '0' */
        Operation[1] = (Funct3[2] == 1'b0 || Funct3 == 1'b0) ? 1'b1 : 1'b0;

        /* Set bit 2 if Funct3 is '100'                 */
        /* OR if Funct3 is '010' AND bit 0 of ALU_Op is NOT '1' */
        /* OR if bit 5 of Funct7 is '1'                 */
        Operation[2] = (Funct3 == 3'b100 || Funct3 == 3'b010 
			    && ALU_Op[0] != 1'b1 || Funct7[5] == 1'b1) ? 1'b1 : 1'b0;

        /* Set bit 3 if Funct3 is '100' */
        Operation[3] = (Funct3 == 3'b100) ? 1'b1 : 1'b0;

        /* Clear all bits if Funct3 is '111' */
        if (Funct3 == 3'b111) Operation = 4'b0000;
        
    end
endmodule // ALUController