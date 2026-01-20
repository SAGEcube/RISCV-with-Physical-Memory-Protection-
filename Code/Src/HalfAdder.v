`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  n/a
// Engineer: Kirby Burke Jr.
// 
// Create Date: 01/21/2024 11:54:18 AM
// Design Name: Half-Adder
// Module Name: HalfAdder
// Project Name: 32-Bit RISC-V Single-Cycle Processor
// Target Devices: Digilent Cmod A7-35T(xc7z35tcpg236-1)
// Tool Versions: Vivado v2023.2 (64-bit)
// Description: Adds two 8-bit values together. In this project, it's used to add
//     8-bits (1 byte) to the program counter (PC) signal.
// 
// Dependencies: PC input signal and constant value of 8'd4
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HalfAdder(a, b, c_out, sum);

    /** I/O Signals **/
    input [7:0] a;
    input [7:0] b;
    output c_out;
    output [7:0] sum;
        
    /** Module Behavior **/
    assign {c_out, sum} = a + b; 

endmodule // HalfAdder