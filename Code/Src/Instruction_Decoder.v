`timescale 1ns / 1ps

module Instruction_Decoder(
    input wire [31:0] instruction,
    output wire [6:0] opcode,
    output wire [2:0] funct3,
    output wire [6:0] funct7,
    output wire valid
);

    // Direct continuous assignments - no registers
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    // Validity check using function
    function check_opcode;
        input [6:0] opcode_in;
        begin
            case (opcode_in)
                7'b0110111, 7'b0010111, 7'b1101111, 7'b1100111,
                7'b1100011, 7'b0000011, 7'b0100011, 7'b0010011,
                7'b0110011, 7'b0001111, 7'b1110011:
                    check_opcode = 1'b1;
                default:
                    check_opcode = 1'b0;
            endcase
        end
    endfunction
    
    assign valid = check_opcode(opcode);

endmodule