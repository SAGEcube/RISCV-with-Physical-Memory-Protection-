`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  n/a
// Engineer: Kirby Burke Jr.
// 
// Create Date: 02/24/2024 04:09:25 PM
// Design Name: Flip Flop
// Module Name: FlipFlop
// Project Name: 32-Bit RISC-V Single-Cycle Processor
// Target Devices: Digilent Cmod A7-35T(xc7z35tcpg236-1)
// Tool Versions: Vivado v2023.2 (64-bit)
// Description: Pushes program counter (PC) value at positive edge of clock signal.
// 
// Dependencies: Clock, Reset, and PC_Next input signals
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FlipFlop(clk, reset, d, q);

    /** I/O Signals **/
    input       clk;
    input       reset;
    input [7:0] d;
	
    output reg [7:0] q;
 
    /** Module Behavior **/
    always @(posedge clk) begin
        if (reset) begin
            q <= 8'b0; // No output if reset signal is active
        end
        else begin
            q <= d;
        end
		
    end
endmodule // FlipFlop
