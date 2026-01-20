`timescale 1ns / 1ps

module PMP_Checker(
    input [7:0] addr,        // Changed to 8-bit address
    input read_enable,
    input write_enable,
    output reg access_granted
);

    // PMP Configuration - 8-bit address ranges
    parameter [7:0] REGION0_START = 8'h00;
    parameter [7:0] REGION0_END   = 8'h3F;  // Region 0: Read/Write/Execute
    parameter [7:0] REGION1_START = 8'h40;  
    parameter [7:0] REGION1_END   = 8'h7F;  // Region 1: Read/Execute only
    parameter [7:0] REGION2_START = 8'h80;
    parameter [7:0] REGION2_END   = 8'hBF;  // Region 2: No access
    
    // Region permissions: [execute, write, read]
    parameter [2:0] REGION0_PERM = 3'b111;  // R/W/X allowed
    parameter [2:0] REGION1_PERM = 3'b101;  // R/X only (no write!)
    parameter [2:0] REGION2_PERM = 3'b000;  // No access
    parameter [2:0] DEFAULT_PERM = 3'b000;  // No access by default

    reg [2:0] current_perm;
    
    always @(*) begin
        // Determine which region the address belongs to
        if (addr >= REGION0_START && addr <= REGION0_END) begin
            current_perm = REGION0_PERM;
        end else if (addr >= REGION1_START && addr <= REGION1_END) begin
            current_perm = REGION1_PERM;
        end else if (addr >= REGION2_START && addr <= REGION2_END) begin
            current_perm = REGION2_PERM;
        end else begin
            current_perm = DEFAULT_PERM;
        end
        
        // Check permissions based on access type
        if (read_enable && !write_enable) begin
            // Memory read or instruction fetch
            access_granted = current_perm[0]; // Read permission
        end else if (!read_enable && write_enable) begin
            // Data write
            access_granted = current_perm[1]; // Write permission
        end else if (read_enable && write_enable) begin
            // Both read and write
            access_granted = current_perm[0] & current_perm[1];
        end else begin
            // No memory access
            access_granted = 1'b1;
        end
        
        // Debug output for violations
        if ((read_enable || write_enable) && !access_granted) begin
            $display("[%0t] PMP CHECK: Addr=0x%h, R=%b, W=%b -> ACCESS DENIED (Perm=3'b%b)", 
                    $time, addr, read_enable, write_enable, current_perm);
        end
    end

endmodule