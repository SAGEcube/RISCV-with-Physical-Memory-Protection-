module InstrMem(
    input wire [7:0] addr,
    output wire [31:0] instr
);

    reg [31:0] memory [0:63];
    
    integer i;

    initial begin
        // Initialize all with NOPs first
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 32'h00000013; // NOP
            
        // === PROGRAM THAT TESTS PMP WITH 8-BIT ADDRESSES ===
        
        // 1. Set up register values for PMP testing
        memory[0] = 32'h08000293;   // addi x5, x0, 0x80  (x5 = 0x80 - REGION2: NO ACCESS)
        memory[1] = 32'h04000313;   // addi x6, x0, 0x40  (x6 = 0x40 - REGION1: READ/EXECUTE ONLY)
        memory[2] = 32'h00000393;   // addi x7, x0, 0x00  (x7 = 0x00 - REGION0: R/W/X allowed)
        memory[3] = 32'hC0000413;   // addi x8, x0, 0xC0  (x8 = 0xC0 - DEFAULT: NO ACCESS)
        
        // 2. Legal operations first
        memory[4] = 32'h00100093;   // addi x1, x0, 1     (x1 = 1)
        memory[5] = 32'h0003A083;   // lw x1, 0(x7)      - LEGAL: Read from region 0 (0x00)
        
        // === PMP VIOLATION TESTS ===
        
        // VIOLATION 1: Load from NO-ACCESS region (region 2 - 0x80)
        memory[6] = 32'h0002A103;   // lw x2, 0(x5)      - x5 = 0x80 (REGION2 - NO ACCESS)
        
        // VIOLATION 2: Store to READ-ONLY region (region 1 - 0x40)  
        memory[7] = 32'h00132023;   // sw x1, 0(x6)      - x6 = 0x40 (REGION1 - READ ONLY, NO WRITE)
        
        // Some legal instructions
        memory[8] = 32'h003101b3;   // add x3, x2, x3     (legal - register operation)
        
        // VIOLATION 3: Jump to NO-ACCESS region (region 2 - 0x80)
        memory[9] = 32'h000280e7;   // jalr x1, x5, 0    - x5 = 0x80 (REGION2 - NO EXECUTE)
        
        // VIOLATION 4: Load from outside regions (DEFAULT NO ACCESS - 0xC0)
        memory[10] = 32'h00042083;  // lw x1, 0(x8)      - x8 = 0xC0 (DEFAULT - NO ACCESS)
        
        // Legal ending
        memory[11] = 32'h00000013;  // nop
        memory[12] = 32'h00000013;  // nop
        memory[13] = 32'h00000013;  // nop
    end

    assign instr = memory[addr[7:2]];

endmodule