`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  n/a
// Engineer: Kirby Burke Jr.
// 
// Create Date: 02/05/2024 05:55:24 PM
// Design Name: Arithmetic Logic Unit
// Module Name: ALU
// Project Name: 32-Bit RISC-V Single-Cycle Processor
// Target Devices: Digilent Cmod A7-35T(xc7z35tcpg236-1)
// Tool Versions: Vivado v2023.2 (64-bit)
// Description: Executes arithmetic and logical operations based on input and
//   control signals. 
// 
// Dependencies:
//   Input Signals: ALU_CC, Reg1, AND Src_B
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(alu_sel, a_in, b_in, carry_out, overflow, zero, alu_out);
    
    /** I/O Signals **/
    input  [3:0]  alu_sel;
    input  [31:0] a_in, b_in;
    output reg    carry_out; // Flag for carry-out during arithmetric
    output reg    overflow;  // Flag for carry-out from MSB 
    output        zero;      // Flag for empty alu_out             
    output [31:0] alu_out; 

    reg [31:0] alu_result; // Stores calculated result from operation
    reg [32:0] temp;       // 
    reg [32:0] twos_com;   // 2's compliment for b_in
  
    assign alu_out = alu_result; // Assign calculated result to output signal
    assign zero = (alu_result == 0); // Set zero flag if alu_out is 0

    /** Module Behavior **/
    always @(*) begin
        /* Clear Carry-Out and Overflow */
	    overflow = 1'b0;
        carry_out = 1'b0;
	  
	    /* Operations */
        case (alu_sel) 
            4'b0000: // AND
                alu_result = a_in & b_in;
    
            4'b0001 : // OR
                alu_result = a_in | b_in;
    
            4'b0010 : begin// ADD (signed)
                alu_result = $signed(a_in)+$signed(b_in);
                temp = {1'b0 , a_in } + {1'b0 , b_in };
                carry_out = temp [32];

                if ((a_in[31] & b_in[31] & ~alu_out[31]) |
                    (~a_in[31] & ~b_in[31] & alu_out[31]))
                    overflow = 1'b1;
                else
                    overflow = 1'b0;
            end
    
            4'b0110 : begin // SUB (signed)
                alu_result = $signed(a_in) - $signed(b_in);
                twos_com = ~(b_in) + 1'b1;
                if ((a_in[31] & twos_com[31] & ~alu_out[31]) |
                    (~a_in[31] & ~twos_com[31] & alu_out[31]))
                    overflow = 1'b1;
                else
                    overflow = 1'b0;
            end
    
            4'b0111 : // SLT (signed): Set if a_in is less than b_in
                alu_result = ($signed(a_in) < $signed(b_in)) ? 32'd1 : 32'd0;
    
            4'b1100 : // NOR
                alu_result = ~(a_in | b_in);
    
            4'b1111 : // SEQ: Set if a_in and b_in are equal
                alu_result = (a_in == b_in) ? 32'd1 : 32'd0;
    
            default : alu_result = a_in + b_in ; // Default = ADD
          
        endcase
    end
endmodule // ALU
