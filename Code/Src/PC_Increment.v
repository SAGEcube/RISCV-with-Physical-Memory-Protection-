`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 11:31:50 PM
// Design Name: 
// Module Name: PC_Increment
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module PC_Increment(
    input wire [7:0] pc_current,
    output wire [7:0] pc_next
);

    assign pc_next = pc_current + 8'd4;

endmodule